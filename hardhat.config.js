//require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-deploy");
require("hardhat-gas-reporter");
require("dotenv").config();

const POLYGON_MAINNET_API = process.env.POLYGON_ALCHEMY_API;
const MUMBAI_API = process.env.MUMBAI_ALCHEMY_API;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETH_MAINNET = process.env.ETH_MAINNET_ALCHEMY_API;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 10000,
          },
        },
      },
      {
        version: "0.6.12",
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      saveDeployments: true,
      forking: {
        url: ETH_MAINNET,
        blockNumber: 15763176,
      },
    },
    localhost: {
      chainId: 31337,
      saveDeployments: true,
    },
    // goerli : {
    //   url: ,
    //   chainId: 5,
    //   accounts:,
    // },
    mumbai: {
      url: MUMBAI_API,
      chainId: 80001,
      saveDeployments: true,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    },
    polygonMainnet: {
      url: POLYGON_MAINNET_API,
      chainId: 137,
      saveDeployments: true,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {},
  },
  gasReporter: {
    enabled: false,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
  },
  mocha: {
    timeout: 500000,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
};
