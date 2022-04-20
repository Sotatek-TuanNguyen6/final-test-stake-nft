async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MarketV1 = await ethers.getContractFactory("NFTMarketplaceV1");
  const marketV1 = await upgrades.deployProxy(MarketV1);

  console.log("Token address:", marketV1.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
