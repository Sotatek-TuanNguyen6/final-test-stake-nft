require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  const PROXY_ADDRESS = process.env.PROXY;
  console.log(PROXY_ADDRESS);
  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MarketV3 = await ethers.getContractFactory("NFTMarketplaceV3");
  const marketV3 = await upgrades.upgradeProxy(PROXY_ADDRESS, MarketV3);

  console.log("Token address:", marketV3.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
