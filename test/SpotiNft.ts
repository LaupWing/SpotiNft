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
})