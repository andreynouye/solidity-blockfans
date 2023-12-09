const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // deploy Lockeek
    Lockeek = await ethers.getContractFactory("Lockeek");
    Lockeek = await Lockeek.deploy();
    await Lockeek.deployed();
    console.log("Lockeek deployed to:", Lockeek.address);

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

    // deploy CreatorsKeys
    CreatorsKeys = await ethers.getContractFactory("CreatorsKeys");
    creatorsKeys = await CreatorsKeys.deploy();
    await creatorsKeys.deployed();
    console.log("CreatorsKeys deployed to:", creatorsKeys.address);

    // configuration
    await Lockeek.setCompanyAddress(deployer.address);
    console.log("Lockeek.setCompanyAddress: ", deployer.address);

    await creators.setLockeek(Lockeek.address);
    console.log("creators.setLockeek: ", Lockeek.address);

    await creators.setCreatorsNFT(creatorsNFT.address);
    console.log("creators.setCreatorsNFT: ", creatorsNFT.address);

    await creatorsNFT.setLockeek(Lockeek.address);
    console.log("creatorsNFT.setLockeek: ", Lockeek.address);

    await creatorsNFT.setCreators(creators.address);
    console.log("creatorsNFT.setCreators: ", creators.address);

    await creatorsKeys.setLockeek(Lockeek.address);
    console.log("creatorsKeys.setLockeek: ", Lockeek.address);

    await creatorsKeys.setCreators(creators.address);
    console.log("creatorsKeys.setCreators: ", creators.address);

    // Distribuir tokens para os endereços selecionados
    const [account1, account2, account3] = await ethers.getSigners();
    const holders = [account1.address, account2.address, account3.address];

    const totalTokens = ethers.utils.parseUnits("100000");
    for (let i = 0; i < holders.length; i++) {
        await Lockeek.transfer(holders[i], totalTokens);

        // mock creators list
        await creators.addCreator(holders[i], "Creator " + [i], "Description", "Brazil", 4, 2);
        console.log("creators.addCreator: ", holders[i] + " - Creator.Status.Active");
    }

    console.log("Token airdrop");
    console.log("Selected addresses:", holders);

    // Shortcuts
    console.log("Start ENV:");
    console.log(`        const LockeekAddress = '${Lockeek.address}';`);
    console.log(`        const CreatorsAddress = '${creators.address}';`);
    console.log(`        const CreatorsNFTAddress = '${creatorsNFT.address}';`);
    console.log(`        const CreatorsKeysAddress = '${creatorsKeys.address}';`);
    console.log("End ENV.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
