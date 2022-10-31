// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IPoLido {
    struct RequestWithdraw {
        uint256 amount2WithdrawFromStMATIC;
        uint256 validatorNonce;
        uint256 requestEpoch;
        address validatorAddress;
    }

    function getMaticFromTokenId(uint256 _tokenId)
        external
        view
        returns (uint256);

    function submit(uint256 _amount) external returns (uint256);

    function requestWithdraw(uint256 _amount) external;

    function claimTokens(uint256 _tokenId) external;

    function getTotalStakeAcrossAllValidators() external view returns (uint256);

    function getTotalPooledMatic() external view returns (uint256);

    function convertStMaticToMatic(uint256 _balance)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function convertMaticToStMatic(uint256 _balance)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function token() external view returns (address);

    function claimTotalDelegated2StMatic(uint256 _index) external;

    function lastWithdrawnValidatorId() external view returns (uint256);

    function totalBuffered() external view returns (uint256);

    function version() external view returns (string memory);

    function poLidoNFT() external view returns (IPoLidoNFT);
}

interface ERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function decimals() external view returns (uint);

    function transfer(address _to, uint256 _value) external returns (bool);
}

interface IPoLidoNFT {
    function tokenIdIndex() external view returns (uint256);
}

contract LidoFinance {
    IPoLido public LidoAddress;
    IPoLidoNFT public polidoNft;
    uint256 public tokenID;
    uint256 public amountStaked;

    constructor(address _lidoAddress, address _poLidoNft) {
        LidoAddress = IPoLido(_lidoAddress);
        polidoNft = IPoLidoNFT(_poLidoNft);
    }

    function stakeMatic(uint256 _amount) public {
        address maticAddress = LidoAddress.token();
        ERC20(maticAddress).approve(address(LidoAddress), _amount);
        uint256 amountMatic = LidoAddress.submit(_amount);
        amountStaked += amountMatic;
        ERC20(address(LidoAddress)).transfer(msg.sender, amountMatic);
    }

    function unStakeAndClaim(uint256 _amount) public {
        require(amountStaked >= _amount, "More than amount staked");
        LidoAddress.requestWithdraw(_amount);
        amountStaked -= _amount;
        uint256 tokenId = polidoNft.tokenIdIndex();
        LidoAddress.claimTokens(tokenId);
        address maticAddress = LidoAddress.token();
        ERC20(maticAddress).transfer(msg.sender, _amount);
    }

    function unStakeToken(uint256 _amount) public {
        LidoAddress.requestWithdraw(_amount);
        uint256 tokenId = polidoNft.tokenIdIndex();
        tokenID = tokenId;
    }

    function claimToken() public {
        // uint256 tokenId = polidoNft.tokenIdIndex();
        LidoAddress.claimTokens(tokenID);
    }

    function getNoOfMatic(uint256 _stMatic)
        public
        view
        returns (
            uint256 _totalAmount2WithdrawInMatic,
            uint256 _totalShares,
            uint256 _totalPooledMATIC
        )
    {
        (
            uint256 totalAmount2WithdrawInMatic,
            uint256 totalShares,
            uint256 totalPooledMATIC
        ) = LidoAddress.convertStMaticToMatic(_stMatic);

        return (totalAmount2WithdrawInMatic, totalShares, totalPooledMATIC);
    }

    function getNoOfstMatic(uint256 _Matic)
        public
        view
        returns (
            uint256 totalAmount2WithdrawInMatic,
            uint256 totalShares,
            uint256 totalPooledMATIC
        )
    {
        (
            uint256 _totalAmount2WithdrawInMatic,
            uint256 _totalShares,
            uint256 _totalPooledMATIC
        ) = LidoAddress.convertMaticToStMatic(_Matic);

        return (_totalAmount2WithdrawInMatic, _totalShares, _totalPooledMATIC);
    }

    function getDecimal() public view returns (uint) {
        address tokenAddress = LidoAddress.token();
        uint256 decimal = ERC20(tokenAddress).decimals();
        return decimal;
    }

    function getTotalPooledMATIC() public view returns (uint) {
        return LidoAddress.getTotalPooledMatic();
    }

    function getMaticFromTokenID() public view returns (uint) {
        uint256 tokenId = polidoNft.tokenIdIndex();
        uint256 amountOfMatic = LidoAddress.getMaticFromTokenId(tokenId);
        return amountOfMatic;
    }

    function maticToken() public view returns (address) {
        return LidoAddress.token();
    }
}
