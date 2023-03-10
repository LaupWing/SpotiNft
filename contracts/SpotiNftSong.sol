// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SpotiNftSong is ERC721{
   Counters.Counter private songBoughtId;

   string private uri;
   string private name;
   address album;

   constructor(
      string memory _uri,
      string memory _name
   ) ERC721("SpotiSong", "SONG"){
      album = msg.sender;
      uri = _uri;
      name = _name;
   }
}