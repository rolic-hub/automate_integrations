const { network, getNamedAccounts, deployments } = require("hardhat");
const { networkConfig } = require("../helper_hardhat");

const { ethers } = require("ethers");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chain = network.config.chainId;
  let arguments = [
    networkConfig[chain].Comet,
    networkConfig[chain].LINK_Token,
    networkConfig[chain].Registrar_Address,
    networkConfig[chain].Registry_Address
  ];

  log(
    "----------------------------------------------------------------------------"
  );

  await deploy("AutoTransactions", {
    from: deployer,
    args: arguments,
    log: true,
  });

  log(
    "----------------------------------deployed Aave Protocol ---------------------------"
  );
};
module.exports.tags = ["AutoTransactions"];
