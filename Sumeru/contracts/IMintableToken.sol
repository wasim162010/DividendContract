// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.22 <0.9.0;
pragma solidity 0.8.4;

interface IMintableToken {
  /**
   * @dev Deposit ETH and mint equal no. of tokens to the caller's balance.
   *
   * Throws error if no ETH is supplied.
   */
  function mint() external payable;

  /**
   * @dev Burn caller's token balance and send the equivalent amount of ETH to given destination address.
   */
  function burn(address  dest) external;
}