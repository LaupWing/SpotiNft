// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SpotiNftSong.sol";

error SpotiAlbum__NotEoughEthSend();
error SpotiAlbum__OnlyOwner();

contract SpotiNftAlbum is ERC721{
   using Counters for Counters.Counter;
   Counters.Counter private tokenId;

   string private cover_uri;
   uint256 private mint_fee;
   address[] private owners;
   address private owner;
   SpotiNftSong[] private song_nfts;
   mapping(address => SpotiNftSong ) address_to_song;

   modifier onlyOwner(){
      if(msg.sender != owner){
         revert SpotiAlbum__OnlyOwner();
      }
      _;
   }

   constructor(
      string memory _name,
      string memory _cover_uri,
      uint256 _mint_fee,
      string[] memory _song_uris,
      string[] memory _song_names,
      uint256 _song_price
   ) ERC721(_name, "ALBUM"){
      owner = msg.sender;
      cover_uri = _cover_uri;
      mint_fee = _mint_fee;
      setSongs(_song_uris, _song_names, _song_price);
   }

   function mintAlbum() public payable {
      if(msg.value < mint_fee){
         revert SpotiAlbum__NotEoughEthSend();
      }
      tokenId.increment();
      uint256 newTokenId = tokenId.current();
      _safeMint(msg.sender, newTokenId);
      owners.push(msg.sender);
   }

   function getCoverUri() public view returns(string memory){
      return cover_uri;
   }

   function getOwners() public view returns(address[] memory){
      return owners;
   }

   function getOwner() public view returns(address){
      return owner;
   }

   function getName() public view returns(string memory){
      return name();
   }

   function getSongs() public view returns(SpotiNftSong[] memory){
      return song_nfts;
   }

   function getMintFee() public view returns(uint256){
      return mint_fee;
   }

   function setSongs(
      string[] memory _song_uris, 
      string[] memory _song_names, 
      uint256 _song_price
   ) internal onlyOwner {
      for(uint256 i = 0; i < _song_uris.length; i++){
         SpotiNftSong newSpotiNFtSong = new SpotiNftSong(
            _song_uris[i],
            _song_names[i],
            _song_price
         );
         address new_address = address(newSpotiNFtSong);
         address_to_song[new_address] = newSpotiNFtSong;
         song_nfts.push(newSpotiNFtSong);
      }
   }

   function setSong(string memory _song_uri, string memory _song_name) public{

   }

   function buySong(
      address _spotiNftAddress
   ) public payable{
      SpotiNftSong song = address_to_song[_spotiNftAddress];
      song.mintSong(msg.sender, msg.value);
   }

   function getSongsAddresses() public view returns(address[] memory){
      address[] memory _songs = new address[](song_nfts.length);

      for(uint256 i = 0; i < song_nfts.length; i++){
         _songs[i] = address(song_nfts[i]);
      }
      return _songs;
   }
}