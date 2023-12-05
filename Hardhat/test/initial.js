const { expect } = require("chai");
const { ethers } = require("hardhat");

// Test General Variables
const gameFee = 1000;
const totalCost = 10000;
const scoreWinner = 250;
const scoreLoser = 10;

const minNumber = 1;
const maxNumber = 1000;
const minstrength = 50;
const maxstrength = 500;
const mindefense = 10;
const maxdefense = 200;
const minpower = 5;
const maxpower = 50;
const minhealthIncrease = 1;
const maxhealthIncrease = 5;
//Prod: const pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
const pancakeSwapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

describe("GameCard Contract", function() {
    let GameCard, gameCard;
    let Titillion, titillion;
    let SuperTrunfo, superTrunfo;
    let LiquidityPool, liquidityPool;
    let accounts;
    let CardTransferredFilter;
        
    before(async () => {
        // get signers
        accounts = await ethers.getSigners();

        // deploy Titillion
        Titillion = await ethers.getContractFactory("Titillion");
        titillion = await Titillion.deploy();
        await titillion.deployed();
        console.log("Titillion deployed to:", titillion.address);

        // deploy LiquidityPool
        LiquidityPool = await ethers.getContractFactory("LiquidityPool");
        liquidityPool = await LiquidityPool.deploy();
        await liquidityPool.deployed();
        console.log("LiquidityPool deployed to:", liquidityPool.address);

        // deploy PrizePool
        PrizePool = await ethers.getContractFactory("PrizePool");
        prizePool = await PrizePool.deploy();
        await prizePool.deployed();
        console.log("PrizePool deployed to:", prizePool.address);

        // deploy Company
        Company = await ethers.getContractFactory("Company");
        company = await Company.deploy();
        await company.deployed();
        console.log("Company deployed to:", company.address);

        // Deploy GameCardUtils
        GameCardUtils = await hre.ethers.getContractFactory("GameCardUtils");
        gameCardUtils = await GameCardUtils.deploy(titillion.address);
        await gameCardUtils.deployed();
        console.log("GameCardUtils deployed to:", gameCardUtils.address);

        // deploy GameCard
        GameCard = await ethers.getContractFactory("GameCard");
        gameCard = await GameCard.deploy(titillion.address, titillion.address, gameCardUtils.address);
        await gameCard.deployed();
        console.log("GameCard deployed to:", gameCard.address);
        
        // deploy SuperTrunfo
        SuperTrunfo = await ethers.getContractFactory("SuperTrunfo");
        superTrunfo = await SuperTrunfo.deploy(titillion.address, gameCard.address, gameCardUtils.address, prizePool.address);
        await superTrunfo.deployed();
        console.log("SuperTrunfo deployed to:", superTrunfo.address);

        // Update Contract: Titillion
        await titillion.setGameCard(gameCard.address);
        console.log("Titillion's gameCardAddress updated: ", gameCard.address);
        
        await titillion.setGameCardUtils(gameCardUtils.address);
        console.log("Titillion's gameCardUtilsAddress updated: ", gameCardUtils.address);

        await titillion.setSuperTrunfo(superTrunfo.address);
        console.log("Titillion's superTrunfoAddress updated: ", superTrunfo.address);

        await titillion.setCompanyAddress(company.address);
        console.log("Titillion's CompanyAddress updated: ", company.address);

        await titillion.setLiquidityPool(liquidityPool.address);
        console.log("Titillion's LiquidityPool updated: ", liquidityPool.address);

        // Update Contract: GameCard
        await gameCard.setSuperTrunfo(superTrunfo.address);
        console.log("GameCard's superTrunfoAddress updated: ", superTrunfo.address);

        await gameCard.setTotalCost(totalCost);
        console.log("GameCard's totalCost updated: ", totalCost);

        // Update Contract: GameCardUtils
        await gameCardUtils.setGameCard(gameCard.address);
        console.log("GameCardUtils's gameCardAddress updated: ", gameCard.address);

        // Update Contract: SuperTrunfo
        await superTrunfo.setGameFee(gameFee);
        console.log("SuperTrunfo's gamefee updated: ", gameFee);

        await superTrunfo.setScoreWinner(scoreWinner);
        console.log("SuperTrunfo's winner score points updated: ", scoreWinner);

        await superTrunfo.setScoreLoser(scoreLoser);
        console.log("SuperTrunfo's loser score points updated: ", scoreLoser);

        // Distribuir tokens para os endereços selecionados
        const [account1, account2, account3, account4] = await ethers.getSigners();
        const holders = [account1.address, account2.address, account3.address, account4.address];

        const totalTokens = ethers.utils.parseUnits('100000');
        for (let i = 0; i < holders.length; i++) {
        await titillion.transfer(holders[i], totalTokens);
        }

        console.log("Token airdrop");
        console.log("Selected addresses:", holders);

    });

    it("Should mint and distribute cards", async function() {
        const [deployer, ...accounts] = await ethers.getSigners();
        
        for (let i = 0; i < 25; i++) {
            let sku, rarity, card_type, strength, defense, power, healthIncrease, generation, tokenURI;
        
            const cardType = ["fighter", "land", "special", "weapon"][Math.floor(Math.random() * 4)];
        
            if (cardType == "fighter") {
                const skuRandom = "FIGHTER" + generateRandomNumber(minNumber, maxNumber);
                sku = skuRandom;
                rarity = ["common", "uncommon", "rare", "ultra", "secret"][Math.floor(Math.random() * 5)];
                card_type = cardType;
                strength = generateRandomNumber(minstrength, maxstrength);
                defense = generateRandomNumber(mindefense, maxdefense);
                power = generateRandomNumber(minpower, maxpower);
                healthIncrease = generateRandomNumber(minhealthIncrease, maxhealthIncrease) + 1;
                generation = 1;
                tokenURI = 'https://nft.titillion.com/metadata-' + skuRandom + '.json';
            } else if (cardType == "land") {
                const skuRandom = "LAND" + generateRandomNumber(minNumber, maxNumber);
                sku = skuRandom;
                rarity = ["common", "uncommon", "rare", "ultra", "secret"][Math.floor(Math.random() * 5)];
                card_type = cardType;
                strength = 0;
                defense = generateRandomNumber(mindefense, maxdefense);
                power = 0;
                healthIncrease = generateRandomNumber(minhealthIncrease, maxhealthIncrease) + 1;
                generation = 1;
                tokenURI = 'https://nft.titillion.com/metadata-' + skuRandom + '.json';
            } else if (cardType == "special") {
                const skuRandom = "SPECIAL" + generateRandomNumber(minNumber, maxNumber);
                sku = skuRandom;
                rarity = ["common", "uncommon", "rare", "ultra", "secret"][Math.floor(Math.random() * 5)];
                card_type = cardType;
                strength = generateRandomNumber(minstrength, maxstrength);
                defense = generateRandomNumber(mindefense, maxdefense);
                power = generateRandomNumber(minpower, maxpower);
                healthIncrease = generateRandomNumber(minhealthIncrease, maxhealthIncrease) + 1;
                generation = 1;
                tokenURI = 'https://nft.titillion.com/metadata-' + skuRandom + '.json';
            } else if (cardType == "weapon") {
                const skuRandom = "WEAPON" + generateRandomNumber(minNumber, maxNumber);
                sku = skuRandom;
                rarity = ["common", "uncommon", "rare", "ultra", "secret"][Math.floor(Math.random() * 5)];
                card_type = cardType;
                strength = 0;
                defense = 0;
                power = generateRandomNumber(minpower, maxpower);
                healthIncrease = 0;
                generation = 1;
                tokenURI = 'https://nft.titillion.com/metadata-' + skuRandom + '.json';
            }
        
            // Mint the card
            console.log(sku, rarity, card_type, strength, defense, power, healthIncrease, generation, tokenURI);
            await gameCard.connect(deployer).mintCard(sku, rarity, card_type, strength, defense, power, healthIncrease, generation, tokenURI);
        }
    });

    it("Should buy card packs", async function() {
        const [account1, account2, account3, account4] = await ethers.getSigners();
        const signers = [account1, account2, account3, account4];
    
        // Let's buy packs for the first 3 accounts
        for (let i = 0; i < signers.length; i++) {
            const buyerSigner = signers[i];
    
            // Approve the spending
            await titillion.connect(buyerSigner).approve(gameCard.address, ethers.utils.parseUnits('10000'));
    
            // Buy the card pack
            const buyCardPackTx = await gameCard.connect(buyerSigner).buyCardPack();
    
            // Wait for the transaction to be mined
            await buyCardPackTx.wait();
    
            // Fetch CardTransferred events
            const cardsTransferredEvents = await gameCard.queryFilter(CardsTransferredFilter, buyCardPackTx.blockNumber);
    
            for(let event of cardsTransferredEvents) {
                console.log("Card transferred:");
                console.log("  To:", event.args.to);
                console.log("  Cards:", event.args.cardIds);
            }
        }
    });
    
    
    it("Should set the deck", async function() {
        const [account1, account2, account3, account4] = await ethers.getSigners();
        const signers = [account1, account2, account3, account4];
    
        for (const holder of signers) {
            console.log('Deck of: ', holder.address)
            const nfts = await gameCardUtils.getAllNFTsWithID(holder.address);
            let totalAvailableCards = nfts.length;
            let cardIds = [];
    
            console.log('Total of cards: ', totalAvailableCards);
            if (totalAvailableCards > 1) {
                let selectedTokenIds = {};
                for (let i = 0; i < 5 && i < totalAvailableCards; i++) {
                    let randomIndex, tokenId;
                    do {
                        randomIndex = Math.floor(Math.random() * totalAvailableCards);
                        tokenId = nfts[randomIndex].tokenId;
                    } while(selectedTokenIds[tokenId]);
            
                    console.log('NFTs: ', tokenId);
                    selectedTokenIds[tokenId] = true;
    
                    // Adicionando cada tokenId ao array cardIds
                    cardIds.push(tokenId);
                    const card = await gameCard.getCardDetails(tokenId);
                    console.log(card.sku, card.rarity, card.card_type, card.strength.toNumber(), card.defense.toNumber(), card.power.toNumber(), card.healthIncrease.toNumber(), card.generation.toNumber(), card.tokenURI);
                }
            }
            
            await superTrunfo.connect(holder).setPlayerDeck(cardIds);
            totalAvailableCards = 0;
        }
    });
    
    it("Should start the 1st game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account1;
        const accounts = [account2, account3, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[0].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[0].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[0].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[0].args.gameWinner);

    });
    
    it("Should start the 2nd game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account2;
        const accounts = [account1, account3, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[1].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[1].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[1].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[1].args.gameWinner);

    });
    
    it("Should start the 3rd game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account3;
        const accounts = [account2, account1, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[2].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[2].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[2].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[2].args.gameWinner);

    });
    
    it("Should start the 4th game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account4;
        const accounts = [account2, account1, account3];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[3].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[3].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[3].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[3].args.gameWinner);

    });

    it("Should start the 5th game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account1;
        const accounts = [account2, account3, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[4].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[4].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[4].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[4].args.gameWinner);

    });
    
    it("Should start the 6th game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account2;
        const accounts = [account1, account3, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[5].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[5].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[5].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[5].args.gameWinner);

    });
    
    it("Should start the 7th game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account3;
        const accounts = [account2, account1, account4];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[6].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[6].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[6].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[6].args.gameWinner);

    });
    
    it("Should start the 8th game", async function () {    
        const [account1, account2, account3, account4] = await ethers.getSigners();

        const player1 = account4;
        const accounts = [account2, account1, account3];
        const player2 = accounts[Math.floor(Math.random() * accounts.length)];

        await titillion.connect(player1).approve(superTrunfo.address, ethers.utils.parseUnits(gameFee.toString()));
        const startGameTx = await superTrunfo.connect(player1).startGame(player2.address);
        await startGameTx.wait();

        const gameStartedEvents = await superTrunfo.queryFilter("GameStarted");
        const gameEndedEvents = await superTrunfo.queryFilter("GameEnded");

        console.log("Game ID:", gameStartedEvents[7].args.gameId.toString());
        console.log("Attacker:", gameStartedEvents[7].args.attacker.toString());
        console.log("Defender:", gameStartedEvents[7].args.defender.toString());
        console.log("Game Winner:", gameEndedEvents[7].args.gameWinner);

    });
    
    it("Should get contract fees balance", async function () {
        let liquidityPoolBalance = await titillion.balanceOf(liquidityPool.address);
        console.log("Balance of Liquidity Pool tokens: ", liquidityPoolBalance.toString());
        
        let companyBalance = await titillion.balanceOf(company.address);
        console.log("Balance of Company Wallet tokens: ", companyBalance.toString());
        
        let titillionBalance = await titillion.balanceOf(titillion.address);
        console.log("Balance of Titillion tokens: ", titillionBalance.toString());
        
        let gameCardBalance = await titillion.balanceOf(gameCard.address);
        console.log("Balance of GameCard tokens: ", gameCardBalance.toString());
        
        let gameCardUtilsBalance = await titillion.balanceOf(gameCardUtils.address);
        console.log("Balance of GameCardUtils tokens: ", gameCardUtilsBalance.toString());
        
        let superTrunfoBalance = await titillion.balanceOf(superTrunfo.address);
        console.log("Balance of SuperTrunfo tokens: ", superTrunfoBalance.toString());
    });
    
    it("Should players score", async function () {
        const [account1, account2, account3, account4] = await ethers.getSigners();
        const signers = [account1, account2, account3, account4];
    
        for (const holder of signers) {
            console.log('Score of: ', holder.address)
            const totalScore = await superTrunfo.getPlayerScore(holder.address);
            console.log('Total points: ', totalScore)
        }
    });
    
});

function generateRandomNumber(min, max) {
    let randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;
    
    // Validar o número gerado
    while (randomNumber === 0 || randomNumber === generateRandomNumber.lastNumber) {
      randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;
    }
    
    // Armazenar o número gerado para comparação na próxima iteração
    generateRandomNumber.lastNumber = randomNumber;
    
    return randomNumber;
}