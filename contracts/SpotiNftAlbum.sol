// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error SpotiAlbum__NotEoughEthSend();

contract SpotiAlbum is ERC721{
   using Counters for Counters.Counter;
   Counters.Counter private tokenId;

   string private uri;
   string private name;
   uint256 private mintFee;
   address[] private owners;
   address private owner;

   constructor(
      string memory _uri,
      string memory _name,
      uint256 _mintFee
   ) ERC721("SpotiAlbum", "ALBUM"){
      owner = msg.sender;
      uri = _uri;
      name = _name;
      mintFee = _mintFee;
   }

   function mintAlbum() public payable {
      if(msg.value < mintFee){
         revert SpotiAlbum__NotEoughEthSend();
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

   function getOwner() public view returns(address){
      return owner;
   }

   function getName() public view returns(string memory){
      return name;
   }

   function getMintFee() public view returns(uint256){
      return mintFee;
   }
}