import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

const EVENT_ALBUM_CREATED = "AlbumCreated"
const ALBUM_OBJECT = {
   name: "My First Album",
   symbol: "MFA",
   album_cover: "ipfscoverurl.png",
   song_uris: ["ipfssonguri1.mp3", "ipfssonguri2.mp3", "ipfssonguri3.mp3"],
   song_names: ["Your mom", "Is fking", "Awesome"],
   song_price: ethers.utils.parseUnits("1", "ether"),
   album_price: ethers.utils.parseUnits("10", "ether")
}
const ARTIST_1 = {
   profile_pic: "someprofilepic.jpg",
   name: "Lil Dicky"
}

const deploySpotiNftFixture = async () => {
   const [owner, account1, account2] = await ethers.getSigners()

   const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
   const spotiNft = await SpotiNft.deploy({
      gasLimit: 30000000
   })

   await spotiNft.deployed()
   
   return {
      owner,
      account1,
      account2,
      spotiNft
   }
}

const deploySpotiAlbumFixture = async () => {
   const { spotiNft, owner, account1, account2 } = await loadFixture(
      deploySpotiNftFixture
   )  
   const transaction = await spotiNft.register(
      ARTIST_1.profile_pic, 
      ARTIST_1.name
   )
   await transaction.wait()

   await spotiNft.createAlbum(
      ALBUM_OBJECT.name,
      ALBUM_OBJECT.album_cover,
      ALBUM_OBJECT.album_price,
      ALBUM_OBJECT.song_uris,
      ALBUM_OBJECT.song_names,
      ALBUM_OBJECT.song_price
   )
   const albums = await spotiNft.getAlbums() 
   const nft_album = await ethers.getContractAt("SpotiNftAlbum", albums[0])
   return {
      spotiNft,
      owner,
      albums,
      nft_album,
      account1,
      account2
   }
}

describe("SpotiNft", () => {

   describe("Deployment", () => {
      it("Should set the right name and symbol", async () => {
         const { owner, spotiNft } = await loadFixture(
            deploySpotiNftFixture
         )
         
         expect(await spotiNft.owner()).equal(owner.address)
         expect(await spotiNft.symbol()).equal("SNFT")
      })
   })

   describe("Artist registration", () => {
      const deploySpotiAlbumFixture = async () => {
         const { spotiNft, owner } = await loadFixture(
            deploySpotiNftFixture
         )  
         const transaction = await spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )
         const transaction_receipt = await transaction.wait()
         return {
            spotiNft,
            owner,
            transaction,
            transaction_receipt
         }
      }
      it("Should register user correctly", async () => {
         const { spotiNft } = await loadFixture(
            deploySpotiNftFixture
         )  
         expect((await spotiNft.getAllArtists()).length).to.equal(0)
         await spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )
         expect((await spotiNft.getAllArtists()).length).to.equal(1)
      })

      it("Should emit an event when register correctly", async () => {
         const event_name = "ArtistCreated"
         const { 
            spotiNft, 
            owner, 
            transaction,
            transaction_receipt 
         } = await loadFixture(
            deploySpotiAlbumFixture
         )
         const event_args = transaction_receipt.events?.find(x => x.event === event_name)?.args! 
         const token_id = event_args[1].toString() 
         
         await expect(transaction)
            .to
            .emit(spotiNft, event_name)
            .withArgs(owner.address, token_id, ARTIST_1.name)
      })

      it("Should revert with custom error when user is already registerd", async () => {
         const { spotiNft, owner } = await loadFixture(
            deploySpotiAlbumFixture
         )
         await expect(spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )).revertedWithCustomError(spotiNft, "SpotiNftMarketplace__AlreadyRegistered")
            .withArgs(owner.address, true)
      })

      it("Should show the information of the artist", async () => {
         const { spotiNft } = await loadFixture(
            deploySpotiAlbumFixture
         )
         const artist = await spotiNft.myInfo() 
         
         expect(artist.tokenId.toString()).to.equal("1")
         expect(artist.name).to.equal(ARTIST_1.name)
         expect(await spotiNft.tokenURI(1)).to.equal(ARTIST_1.profile_pic)
      })
   })

   describe("Albums", () => {
      it("Should allow the artist to create an album", async () => {
         const {
            albums,
            nft_album,
            owner
         } = await loadFixture(deploySpotiAlbumFixture)
         
         expect(albums.length).equal(1)
         expect(await nft_album.getName()).equal(ALBUM_OBJECT.name)
         expect(await nft_album.getCoverUri()).equal(ALBUM_OBJECT.album_cover)
         expect(await nft_album.getMintFee()).equal(ALBUM_OBJECT.album_price)
         expect(await nft_album.getSongMintFee()).equal(ALBUM_OBJECT.song_price)
         expect((await nft_album.getSongs()).length).equal(ALBUM_OBJECT.song_names.length)
         expect(await nft_album.getOwner()).equal(owner.address)
      })

      it("Registers the correct songs", async () => {
         const {
            nft_album
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs()
         const proxies = songs.map(async (song_address, i) => {
            const nft_song = await ethers.getContractAt("SpotiNftSong", song_address)
            expect(await nft_song.getName()).equal(ALBUM_OBJECT.song_names[i])
            expect(await nft_song.getMintFee()).equal(ALBUM_OBJECT.song_price)
            expect(await nft_song.getUri()).equal(ALBUM_OBJECT.song_uris[i])
         })
         await Promise.all(proxies)
      })
      
      it("Should throw an error when an unregistered user wants to create an album" , async () => {
         const { account1, spotiNft } = await loadFixture(deploySpotiAlbumFixture)
         await expect(spotiNft.connect(account1).createAlbum(
            ALBUM_OBJECT.name,
            ALBUM_OBJECT.album_cover,
            ALBUM_OBJECT.album_price,
            ALBUM_OBJECT.song_uris,
            ALBUM_OBJECT.song_names,
            ALBUM_OBJECT.song_price
         ))
            .revertedWithCustomError(spotiNft, "SpotiNftMarketplace__NotRegistered")
            .withArgs(account1.address, false)
      })

      it("Allows the user to add a new song", async () => {
         const new_song = "My new song"
         const { nft_album } = await loadFixture(deploySpotiAlbumFixture)
         expect((await nft_album.getSongs()).length).equal(3)
         await nft_album.addSong("new_song_uri.mp3", new_song)
         expect((await nft_album.getSongs()).length).equal(4)
         expect(await Promise.all((await nft_album.getSongs()).map(async x=> {
            const nft_song = await ethers.getContractAt("SpotiNftSong", x)
            return nft_song.getName()
         }))).includes(new_song)
      })

      it("Reverts when a non owner tries to add a song", async () => {
         const { nft_album, account1 } = await loadFixture(deploySpotiAlbumFixture)
         await expect(
            nft_album.connect(account1).addSong("should_revert.mp3", "reverted song")
         ).revertedWithCustomError(nft_album, "SpotiAlbum__OnlyOwner")
      })

      it("Allows users to buy a ablum", async () => {
         const { nft_album, account1 } = await loadFixture(deploySpotiAlbumFixture)
         
         expect(await nft_album.getTokenId()).equal(0)
         const transaction = await nft_album.connect(account1).mintAlbum({
            value: ALBUM_OBJECT.album_price
         })
         transaction.wait()
         expect(await nft_album.getBalance()).equal(ALBUM_OBJECT.album_price)
         expect(await nft_album.getTokenId()).equal(1)
         await expect(transaction).emit(nft_album, "AlbumMinted").withArgs(
            account1.address,
            1
         )
      })

      it("Allows owner to transfer the balance", async () =>{
         const { nft_album, account1, owner } = await loadFixture(deploySpotiAlbumFixture)
         const startingBalance = await owner.getBalance()
         const transaction = await nft_album.connect(account1).mintAlbum({
            value: ALBUM_OBJECT.album_price
         })
         transaction.wait()
         const transactionTransfer = await nft_album.transferBalanceToOwner()
         const transactionReceipt = await transactionTransfer.wait() 
         const totalGas = transactionReceipt.gasUsed.mul(transactionReceipt.effectiveGasPrice)
         
         const endingBalance = await owner.getBalance()
         expect(startingBalance.sub(totalGas).add(ALBUM_OBJECT.album_price)).equal(endingBalance)
      })
   })

   describe.only("Songs", () => {
      it("Sets up the song nft correctly", async () => {
         const {
            nft_album
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs() 
         const songContract = await ethers.getContractAt("SpotiNftSong", songs[0])
         expect(await songContract.getMintFee()).equal(ALBUM_OBJECT.song_price)
         expect(await songContract.getAlbum()).equal(nft_album.address)
         expect(await songContract.getName()).equal(ALBUM_OBJECT.song_names[0])
         expect(await songContract.getUri()).equal(ALBUM_OBJECT.song_uris[0])
      })
      it("Allows the user to mint a song", async () => {
         const {
            nft_album,
            account1
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs()
         const songContract = await ethers.getContractAt("SpotiNftSong", songs[0])
         await nft_album.connect(account1).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         expect((await songContract.getOwners())[0]).equal(account1.address)
         expect(await songContract.ownerOf(1)).equal(account1.address)
         expect(await songContract.getLatestTokenId()).equal(1)
         expect(await nft_album.getBalance()).equal(ALBUM_OBJECT.song_price)
      })

      it("Increments the tokenID correctly of a bought song", async () => {
         const {
            nft_album,
            account1,
            account2
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs()
         const songContract = await ethers.getContractAt("SpotiNftSong", songs[0])
         await nft_album.connect(account1).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         await nft_album.connect(account2).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         expect(await songContract.getLatestTokenId()).equal(2)
      })

      it("Registers the bought song of account1 account2", async () => {
         const {
            nft_album,
            account1,
            account2
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs()
         const songContract = await ethers.getContractAt("SpotiNftSong", songs[0])
         await nft_album.connect(account1).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         await nft_album.connect(account2).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         expect(await songContract.ownerOf(1)).equal(account1.address)
         expect(await songContract.ownerOf(2)).equal(account2.address)
         expect(await songContract.getOwners())
            .includes(account1.address, account2.address)
         expect(await nft_album.getBalance()).equal(ALBUM_OBJECT.song_price.mul(2))
      })

      it("Doesnt add duplicates to the ownersList when acount1 buys a song twice", async () => {
         const {
            nft_album,
            account1
         } = await loadFixture(deploySpotiAlbumFixture)
         const songs = await nft_album.getSongs()
         const songContract = await ethers.getContractAt("SpotiNftSong", songs[0])
         await nft_album.connect(account1).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })
         await nft_album.connect(account1).buySong(songs[0], {
            value: ALBUM_OBJECT.song_price
         })

         expect(await songContract.getLatestTokenId()).equal(2)
         expect(await songContract.getOwners()).lengthOf(1)
      })

      it.only("Allows owner to add a new song to the album", async () => {
         const newSongUri = "new_song_ipfs_uri.mp3"
         const newSongTitle = "My new song"

         const {
            nft_album
         } = await loadFixture(deploySpotiAlbumFixture)
         const songsBefore = await nft_album.getSongs()
         
         await nft_album.addSong(newSongUri, newSongTitle)
         const songsAfter = await nft_album.getSongs()
         expect(songsAfter.length).to.be.above(songsBefore.length)
         const songContract = await ethers.getContractAt("SpotiNftSong", songsAfter[songsAfter.length - 1])

         console.log(await songContract.getName())
      })
   })
})