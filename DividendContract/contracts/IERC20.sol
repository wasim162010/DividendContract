// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface IERC20 {
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256);
}
