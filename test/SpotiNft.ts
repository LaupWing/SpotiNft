import { ethers } from "hardhat"


describe("SpotiNft", () => {
   const deploySpotiNftFixture = async () => {
      const [owner, otherAccount] = await ethers.getSigners()

      const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
      const spotiNft = await SpotiNft.deploy()

      return {
         owner,
         otherAccount,
         spotiNft
      }
   }
})