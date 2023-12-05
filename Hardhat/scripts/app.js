const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // deploy Blockfans
    Blockfans = await ethers.getContractFactory("Blockfans");
    blockFans = await Blockfans.deploy();
    await blockFans.deployed();
    console.log("Blockfans deployed to:", blockFans.address);

    // deploy Creators
    Creators = await ethers.getContractFactory("Creators");
    creators = await Creators.deploy();
    await creators.deployed();
    console.log("Creators deployed to:", creators.address);

    // deploy CreatorsNFT
    CreatorsNFT = await ethers.getContractFactory("CreatorsNFT");
    creatorsNFT = await CreatorsNFT.deploy();
    await creatorsNFT.deployed();
    console.log("CreatorsNFT deployed to:", creatorsNFT.address);

    // Shortcuts
    console.log("Start ENV:");
    console.log(`        const BlockfansAddress = '${blockFans.address}';`);
    console.log(`        const CreatorsAddress = '${creators.address}';`);
    console.log(`        const creatorsNFTAddress = '${creatorsNFT.address}';`);
    console.log("End ENV.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
