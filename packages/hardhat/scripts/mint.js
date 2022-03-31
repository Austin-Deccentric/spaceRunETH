/* eslint no-use-before-define: "warn" */
const fs = require("fs");
const chalk = require("chalk");
const { config, ethers } = require("hardhat");
const { utils } = require("ethers");
const R = require("ramda");
const ipfsAPI = require("ipfs-http-client");

const ipfs = ipfsAPI({
  host: "ipfs.infura.io",
  port: "5001",
  protocol: "https",
});

const delayMS = 1000; // sometimes xDAI needs a 6000ms break lol 😅

const main = async () => {
  // ADDRESS TO MINT TO:
  const toAddress = "YOUR_FRONTEND_ADDRESS";

  console.log("\n\n 🎫 Minting to " + toAddress + "...\n");

  const { deployer } = await getNamedAccounts();
  const Bohemia = await ethers.getContract("Bohemia", deployer);

  let metadata = require('./metadata.json');

  const boho_1 = metadata[0];

  console.log("Uploading Bohemian 01...");
  const uploaded = await ipfs.add(JSON.stringify(boho_1));

  console.log("Minting Bohomian 01 with IPFS hash (" + uploaded.path + ")");
  await Bohemia.mintItem(toAddress, uploaded.path, {
    gasLimit: 400000,
  });

  await sleep(delayMS);

  const boho_2 = metadata[1];

  console.log("Uploading Bohemian 02...");
  const uploaded_2 = await ipfs.add(JSON.stringify(boho_2));

  console.log("Minting Bohemian 02 with IPFS hash (" + uploaded_2.path + ")");
  await Bohemia.mintItem(toAddress, uploaded_2.path, {
    gasLimit: 400000,
  });

  await sleep(delayMS);

  
  console.log(
    "Transferring Ownership of Bohemia to " + toAddress + "..."
  );

  await Bohemia.transferOwnership(toAddress, { gasLimit: 400000 });

  await sleep(delayMS);

  /*


  console.log("Minting zebra...")
  await Bohemia.mintItem("0xD75b0609ed51307E13bae0F9394b5f63A7f8b6A1","zebra.jpg")

  */

  // const secondContract = await deploy("SecondContract")

  // const exampleToken = await deploy("ExampleToken")
  // const examplePriceOracle = await deploy("ExamplePriceOracle")
  // const smartContractWallet = await deploy("SmartContractWallet",[exampleToken.address,examplePriceOracle.address])

  /*
  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const yourContract = await deploy("YourContract", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/scaffold-eth/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const yourContract = await deploy("YourContract", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
