require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  const PROXY_ADDRESS = process.env.PROXY;
  console.log(PROXY_ADDRESS);
  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MarketV2 = await ethers.getContractFactory("NFTMarketplaceV2");
  const marketV2 = await upgrades.upgradeProxy(PROXY_ADDRESS, MarketV2);

  console.log("Token address:", marketV2.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
