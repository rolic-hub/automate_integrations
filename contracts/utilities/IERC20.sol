// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function decimals() external view returns (uint);

    function transfer(address _to, uint256 _value) external returns (bool);
}
