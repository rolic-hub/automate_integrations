// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "./utilities/IERC20.sol";
import "./integrations/LidoFinance.sol";
import "./integrations/AaveProtocol.sol";
import "./integrations/CompoundIntegration.sol";
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

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

contract Defiverse is AaveProtocol, CompoundIntegration, LidoFinance {
    /*
     *  Aave contracts main methods from the AaveProtocol contract
     */
        struct AaveDeposit {
            address asset,
            uint256 amount
        }
        struct AaveBorrow {
            address asset,
            uint256 amount,
            uint256 interestRateMode
        }
        struct AaveRepay {
            address asset,
            uint256 amount
            uint256 interestRateMode
        }
         struct AaveWithdraw {
            address asset,
            uint256 amount
        }

        mapping (bool => AaveDeposit) isDeposit;
        

    /*
     * Compound contracts main methods from the CompoundIntegration contract
     */
       struct compound {
        address asset,
        uint256 amount 
       }

    /*
     * Lido finance contracts main methods form the LidoFinance contract
     */
    struct Lido {
        address token,
        uint256 amount
    }

    constructor() AaveProtocol() CompoundIntegration() LidoFinance() {

    }

    function chooseFunction() public {
        if(isDeposit){
            AaveDeposit.asset = 
        }
    }

    function registerAndPredictID(uint256 amount) public {
        (State memory state, Config memory _c, address[] memory _k) = i_registry
            .getState();
        uint256 oldNonce = state.nonce;
        //bytes memory checkData = abi.encode(assest, assetAmount);
        bytes memory payload = abi.encode(
            "Defiverse",
            "0x",
            address(this),
            999999,
            address(msg.sender),
            "0x", // checkData
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
            //counterToUpkeepID = upkeepID;
        } else {
            revert("auto-approve disabled");
        }
    }

    function approveFunction(
        address assest,
        uint256 amount,
        address approvee
    ) public {
        IERC20(assest).approve(approvee, amount);
    }

    function transferFunction(
        address assest,
        uint256 amount,
        address to
    ) public {
        IERC20(assest).transfer(to, amount);
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData)
    {}

    function performUpkeep(bytes calldata performData) external {}

    function checkDataInfo() internal pure returns (bytes memory checkData) {

    }
}
