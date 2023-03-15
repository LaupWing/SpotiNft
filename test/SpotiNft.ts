import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

const EVENT_ALBUM_CREATED = "AlbumCreated"
const ALBUM_OBJECT = {
   name: "My First Album",
   symbol: "MFA",
   albumCover: "ipfscoverurl.png",
   songUris: ["ipfssonguri1.mp3", "ipfssonguri2.mp3", "ipfssonguri3.mp3"],
   songPrices: [1, 2, 3],
   albumPrice: 10
}
const ARTIST_1 = {
   profile_pic: "someprofilepic.jpg",
   name: "Lil Dicky"
}

describe.only("SpotiNft", () => {
   const deploySpotiNftFixture = async () => {
      const [owner, account1, account2] = await ethers.getSigners()

      const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
      const spotiNft = await SpotiNft.deploy()

      await spotiNft.deployed()
      
      return {
         owner,
         account1,
         account2,
         spotiNft
      }
   }
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
      const registerFixture = async () => {
         const { spotiNft, owner } = await loadFixture(
            deploySpotiNftFixture
         )  
         const transaction = await spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )
         return {
            spotiNft,
            owner,
            transaction
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
         const { spotiNft, owner, transaction } = await loadFixture(
            registerFixture
         )  
         const transaction_receipt = await transaction.wait()
         const event_args = transaction_receipt.events?.find(x => x.event === event_name)?.args! 
         const token_id = event_args[1].toString() 
         
         await expect(transaction)
            .to
            .emit(spotiNft, event_name)
            .withArgs(owner.address, token_id, ARTIST_1.name)
      })

      it("Should revert with custom error when user is already registerd", async () => {
         const { spotiNft, owner } = await loadFixture(
            deploySpotiNftFixture
         )  
         const transaction = await spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )
         await transaction.wait()
         await expect(spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )).revertedWithCustomError(spotiNft, "SpotiNftMarketplace__AlreadyRegistered")
            .withArgs(owner.address, true)
      })

      it("Should show the information of the artist", async () => {
         const { spotiNft } = await loadFixture(
            deploySpotiNftFixture
         )  
         const transaction = await spotiNft.register(
            ARTIST_1.profile_pic, 
            ARTIST_1.name
         )
         await transaction.wait()
         const artist = await spotiNft.myInfo() 
         
         expect(artist.tokenId.toString()).to.equal("1")
         expect(artist.name).to.equal(ARTIST_1.name)
         expect(await spotiNft.tokenURI(1)).to.equal(ARTIST_1.profile_pic)
      })
   })
})