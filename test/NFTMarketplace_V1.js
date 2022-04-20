const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers, upgrades } = require("hardhat");

let NFTMarketplaceV1;
let nftMarketplaceV1;
let NFTFactory;
let nftFactory;
let Token;
let token;
const metaDataURI =
  "https://docs.docker.com/compose/compose-file/compose-file-v3/#volume-configuration-reference";
const priceOrder = BigNumber.from("90000000000000").toBigInt();

describe("NFTMarketplaceV1", function () {
  beforeEach(async () => {
    NFTMarketplaceV1 = await ethers.getContractFactory("NFTMarketplaceV1");
    nftMarketplaceV1 = await upgrades.deployProxy(NFTMarketplaceV1);

    NFTFactory = await ethers.getContractFactory("NFTFactory");
    nftFactory = await NFTFactory.deploy();
    await nftFactory.deployed();

    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(
      "TUAN TOKEN",
      "TNT",
      18,
      BigInt("9000000000000000000000")
    );
    await token.deployed();
  });

  it("getCounterOrder returns 0 when initialize", async function () {
    expect(await nftMarketplaceV1.getCountOrder()).to.equal(0);
  });

  it("add an order to market place", async function () {
    const [owner] = await ethers.getSigners();

    await nftFactory.mintNFT(owner.address, metaDataURI);
    await nftFactory.setApprovalForAll(nftMarketplaceV1.address, true);
    await nftMarketplaceV1.createOrder(
      nftFactory.address,
      1,
      token.address,
      priceOrder
    );
    expect(await nftMarketplaceV1.getCountOrder()).to.equal(1);
  });
});
