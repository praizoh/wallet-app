const hre = require("hardhat");

const main = async () => {
  const walletContractFactory = await hre.ethers.getContractFactory("WalletApp");
  const walletContract = await walletContractFactory.deploy();
  await walletContract.deployed();
  console.log("Contract deployed to:", walletContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();