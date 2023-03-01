import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

describe.only("SpotiNft", () => {
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
   describe("Deployment", function () {
      it("Should set the right name and symbol", async function () {
         const { owner, spotiNft } = await loadFixture(
            deploySpotiNftFixture
         )
         
         expect(await spotiNft.owner()).equal(owner.address)
         expect(await spotiNft.symbol()).equal("SNFT")
      })
   })
})