// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import {ERC20} from "../integrations/CompoundIntegration.sol";
import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import {DataTypes} from "@aave/protocol-v2/contracts/protocol/libraries/types/DataTypes.sol";
//import {ILendingPoolAddressesProvider} from "@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
// 0x326C977E6efc84E512bB9C30f76E30c160eD06FB -- link token
// 0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210 -- aave goerli
// 0x02777053d6764996e594c3E88AF1D58D5363a2e6 -- registry goerli
// 0x9806cf6fBc89aBF286e8140C42174B94836e36F2. -- registrar goerli
interface KeeperRegistrarInterface {
    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}

contract AutoTransactions {
    LinkTokenInterface public immutable i_link;
    address public immutable registrar;
    AutomationRegistryInterface public immutable i_registry;
    bytes4 registerSig = KeeperRegistrarInterface.register.selector;
    uint256 public immutable interval;
    uint256 public lastTimeStamp;
    uint256 public upkeepId;
    address public poolAddress;
    event Response(bool sucess, bytes data);

    constructor(
        address _poolAddress,
        LinkTokenInterface _link,
        address _registrar,
        AutomationRegistryInterface _registry
    ) {
        i_link = _link;
        registrar = _registrar;
        i_registry = _registry;
        interval = 240;
        lastTimeStamp = block.timestamp;
        poolAddress = _poolAddress;
    }

    function registerAndPredictID(
        uint256 amount,
        address assest,
        uint256 assetAmount
    ) public {
        (State memory state, Config memory _c, address[] memory _k) = i_registry
            .getState();
        uint256 oldNonce = state.nonce;
        bytes memory checkData = abi.encode(assest, assetAmount);
        bytes memory payload = abi.encode(
            "self-Automate",
            "0x",
            address(this),
            2000000,
            address(msg.sender),
            checkData,
            amount,
            0,
            address(this)
        );

        i_link.transferAndCall(
            registrar,
            amount,
            bytes.concat(registerSig, payload)
        );
        (state, _c, _k) = i_registry.getState();
        uint256 newNonce = state.nonce;
        if (newNonce == oldNonce + 1) {
            uint256 upkeepID = uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        address(i_registry),
                        uint32(oldNonce)
                    )
                )
            );
            upkeepId = upkeepID;
        } else {
            revert("auto-approve disabled");
        }
    }

    function approve(address assest, uint256 amount) public {
        ERC20(assest).approve(poolAddress, amount);
    }

   

    function depositToken(address tokenAddress, uint256 amount) public {
        ILendingPool(poolAddress).deposit(
            tokenAddress,   
            amount,
            address(this),
            0
        );
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (address asset, uint256 amount) = abi.decode(
            checkData,
            (address, uint256)
        );
        bool timePassed = (block.timestamp - lastTimeStamp) > interval;
        upkeepNeeded = (timePassed && asset != address(0) && amount != 0);

        performData = checkData;

    }

    function performUpkeep(bytes calldata performData) external {
        (address asset, uint256 amount) = abi.decode(
            performData,
            (address, uint256)
        );
        
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            ILendingPool(poolAddress).deposit(asset, amount, address(this), 0);
        }
    }
}
