// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error SpotiNftSong__NotEoughEthSend();

contract SpotiNftSong is ERC721{
   using Counters for Counters.Counter;
   Counters.Counter private tokenId;

   string private uri;
   string private name;
   uint256 private mintFee;
   address[] private owners;
   address private album;

   constructor(
      string memory _uri,
      string memory _name,
      uint256 _mintFee
   ) ERC721("SpotiSong", "SONG"){
      album = msg.sender;
      uri = _uri;
      name = _name;
      mintFee = _mintFee;
   }

   function mintSong() public payable {
      if(msg.value < mintFee){
         revert SpotiNftSong__NotEoughEthSend();
      }
      tokenId.increment();
      uint256 newTokenId = tokenId.current();
      _safeMint(msg.sender, newTokenId);
      owners.push(msg.sender);
   }

   function getUri() public view returns(string memory){
      return uri;
   }

   function getOwners() public view returns(address[] memory){
      return owners;
   }

   function getAlbum() public view returns(address){
      return album;
   }

   function getName() public view returns(string memory){
      return name;
   }

   function getMintFee() public view returns(uint256){
      return mintFee;
   }
}