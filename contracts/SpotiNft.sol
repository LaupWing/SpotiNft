// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SpotiNftMarketplace {
   address payable public owner;

   constructor() payable {
      owner = payable(msg.sender);
   }
}


contract 