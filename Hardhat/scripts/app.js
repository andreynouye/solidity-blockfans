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

    // configuration
    await blockFans.setCompanyAddress(deployer.address);
    console.log("blockFans.setCompanyAddress: ", deployer.address);

    await creatorsNFT.setBlockFans(blockFans.address);
    console.log("creatorsNFT.setBlockFans: ", blockFans.address);

    await creatorsNFT.setCreators(creators.address);
    console.log("creatorsNFT.setCreators: ", creators.address);

    // Distribuir tokens para os endereços selecionados
    const [account1, account2, account3, account4] = await ethers.getSigners();
    const holders = [account1.address, account2.address, account3.address, account4.address];

    const totalTokens = ethers.utils.parseUnits("100000");
    for (let i = 0; i < holders.length; i++) {
        await blockFans.transfer(holders[i], totalTokens);
    }

    console.log("Token airdrop");
    console.log("Selected addresses:", holders);

    // Shortcuts
    console.log("Start ENV:");
    console.log(`        const BlockfansAddress = '${blockFans.address}';`);
    console.log(`        const CreatorsAddress = '${creators.address}';`);
    console.log(`        const CreatorsNFTAddress = '${creatorsNFT.address}';`);
    console.log("End ENV.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
