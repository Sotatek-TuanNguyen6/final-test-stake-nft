const { expect } = require("chai");
const { ethers } = require("hardhat");

let NFTFactory;
let myNFT;

describe("NFTFactory", function () {
  beforeEach(async () => {
    NFTFactory = await ethers.getContractFactory("NFTFactory");
    myNFT = await NFTFactory.deploy();
    await myNFT.deployed();
  });

  it("test mintNFT", async function () {
    const [owner] = await ethers.getSigners();
    await myNFT.mintNFT(
      owner.address,
      "https://be.api.paceart.sotatek.works/api/v1/nfts/metadata/pace/31"
    );
    await expect(await myNFT.balanceOf(owner.address)).to.equal(1);
  });
});
