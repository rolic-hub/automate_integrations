// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import {IPriceOracle} from "@aave/protocol-v2/contracts/interfaces/IPriceOracle.sol";
import {DataTypes} from "@aave/protocol-v2/contracts/protocol/libraries/types/DataTypes.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address _to, uint256 _value) external returns (bool);
}

contract AaveProtocol {
    ILendingPool public poolAddress;
    IPriceOracle public oracleAddress;

    constructor(address _poolAddress, address _oracleAddress) public {
        poolAddress = ILendingPool(_poolAddress);
        oracleAddress = IPriceOracle(_oracleAddress);
    }

    function depositToken(address tokenAddress, uint256 amount) public {
        IERC20(tokenAddress).approve(address(poolAddress), amount);
        poolAddress.deposit(tokenAddress, amount, msg.sender, 0);
    }

    function withdrawToken(address tokenAddress, uint256 totalAmount) public returns(uint256) {
       uint amountWit =  poolAddress.withdraw(tokenAddress, totalAmount, msg.sender);
       return amountWit;
    }

    function borrowToken(
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) public {
        poolAddress.borrow(asset, amount, interestRateMode, 0, msg.sender);
    }

    function repayBorrowed(
        address tokenBorrowed,
        uint256 amountRepaid,
        uint256 interestRate
    ) public {
        IERC20(tokenBorrowed).approve(address(poolAddress), amountRepaid);
        poolAddress.repay(
            tokenBorrowed,
            amountRepaid,
            interestRate,
            address(this)
        );
    }

    function swapBorrowRate(address asset, uint256 currentInterestRate) public {
        poolAddress.swapBorrowRateMode(asset, currentInterestRate);
    }

    function useReserveAsCollateral(address assest, bool useAsCollateral)
        public
    {
        poolAddress.setUserUseReserveAsCollateral(assest, useAsCollateral);
    }

    function _supplyCollateralAndBorrow(
        address tokenToBorrow,
        uint256 unitsToBorrow,
        address collateralAddress,
        uint256 userCollateral
    ) public {
        IERC20(collateralAddress).approve(address(poolAddress), userCollateral);

        poolAddress.deposit(
            collateralAddress,
            userCollateral,
            address(this),
            0
        );
        useReserveAsCollateral(collateralAddress, true);
        poolAddress.borrow(tokenToBorrow, unitsToBorrow, 2, 0, address(this));
    }

    function _repayAndWithdrawCollateral(
        address tokenBorrowed,
        uint256 units,
        address collateralAddress
    ) public {
        IERC20(tokenBorrowed).approve(address(poolAddress), units);
        poolAddress.repay(tokenBorrowed, units, 2, address(this));
        poolAddress.withdraw(collateralAddress, units, address(this));
        IERC20(collateralAddress).transfer(msg.sender, units);
    }

    function getPoolAddress() public view {
        poolAddress.getAddressesProvider();
    }

    function getUserData(address user)
        public
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        (
            uint256 totalCollateral,
            uint256 totalDebt,
            uint256 availableBorrows,
            uint256 currentLiquidation,
            uint256 ltvM,
            uint256 healthFactorM
        ) = poolAddress.getUserAccountData(user);

        return (
            totalCollateral,
            totalDebt,
            availableBorrows,
            currentLiquidation,
            ltvM,
            healthFactorM
        );
    }

    function getPrice(address assest) public view returns (uint256) {
        uint256 _price = oracleAddress.getAssetPrice(assest);
        return _price;
    }

    function _getConfiguration(address assest)
        public
        view
        returns (DataTypes.ReserveConfigurationMap memory)
    {
        return poolAddress.getConfiguration(assest);
    }

    function _getUserConfiguration()
        public
        view
        returns (DataTypes.UserConfigurationMap memory)
    {
        return poolAddress.getUserConfiguration(address(this));
    }

    function _getReserveData(address asset)
        public
        view
        returns (DataTypes.ReserveData memory)
    {
        return poolAddress.getReserveData(asset);
    }

    function _getReserveNormalizedIncome(address assest)
        public
        view
        returns (uint)
    {
        uint reserveIncome = poolAddress.getReserveNormalizedIncome(assest);
        return reserveIncome;
    }

    function _getReserveNormalizedDebt(address assest)
        public
        view
        returns (uint)
    {
        uint reserveDebt = poolAddress.getReserveNormalizedVariableDebt(assest);
        return reserveDebt;
    }

    function _reserveList() public view returns (address[] memory) {
        return poolAddress.getReservesList();
    }

    // function _maxpercentStable() public view {
    //     poolAddress.MAX_STABLE_RATE_BORROW_SIZE_PERCENT();
    // }
}
