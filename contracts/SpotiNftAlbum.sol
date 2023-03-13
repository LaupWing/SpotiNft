// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SpotiNftSong.sol";

error SpotiAlbum__NotEoughEthSend();
error SpotiAlbum__OnlyOwner();

contract SpotiAlbum is ERC721{
   using Counters for Counters.Counter;
   Counters.Counter private tokenId;

   string private uri;
   string private name;
   uint256 private mintFee;
   address[] private owners;
   address private owner;
   SpotiNftSong[] private songs;

   modifier onlyOwner(){
      if(msg.sender != owner){
         revert SpotiAlbum__OnlyOwner();
      }
      _;
   }

   constructor(
      string memory _uri,
      string memory _name,
      uint256 _mintFee,
      string[] memory _song_uris,
      string[] memory _song_names,
      uint256[] memory _song_prices
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

   function setSongs(
      string[] memory _song_uris, 
      string[] memory _song_names, 
      uint256 song_price
   ) internal onlyOwner {
      // for(uint256 i = 0; i < song_uris.length; i++){
      //    uint256 id = songIds.current(); 
      //    songs[id] = SpotiSong(
      //       id,
      //       song_prices[i],
      //       song_uris[i],
      //       0,
      //       block.timestamp,
      //       new address[](0)
      //    );
      //    songsArray.push(id);
      //    songIds.increment();
      // }
      // totalSongs._value = song_uris.length;
   }
}