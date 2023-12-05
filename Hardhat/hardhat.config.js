require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",  // substitua pela sua versão do Solidity
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
        details: {
          "peephole": true,
          "inliner": true,
          "jumpdestRemover": true,
          yulDetails: {
            optimizerSteps: "u",
          },
        },
      },
      viaIR: true,
    },
  },
  paths: {
    sources: "./contracts",
    artifacts: "./artifacts",
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    arbitrumGoerli: {
      url: "https://goerli-rollup.arbitrum.io/rpc",
      chainId: 421613,
      accounts: ['96c4a30b2a590336b529821674826a18df4b4611c9af3fe485ec8556ff2d07fb']
    },
    optimismGoerli: {
      url: "https://opt-goerli.g.alchemy.com/v2/rooBi-LG4kw0UQXph9XVLPfnRyiP-BcI",
      accounts: ['96c4a30b2a590336b529821674826a18df4b4611c9af3fe485ec8556ff2d07fb']
    }
  }
};
