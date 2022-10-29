const { expect, assert } = require("chai");
const { deployments, network, ethers } = require("hardhat");
const { networkConfig } = require("../helper_hardhat");
const ERCabi = require("../constants/ERC20Abi.json");

describe("Automating test", () => {
  let autoContract, signer, interval;
  const chain = network.config.chainId;
  const LINK_Token = networkConfig[chain].LINK_Token;
  const linkUpkeep = ethers.utils.parseEther("7");
  const impersonate = networkConfig[chain].Impersonate;
  const Myaddress = "0x9353CdB9598937A9a9DD1D792A4D822EE8415E8D";
  const erc20 = async (erc20TokenAddress, signerERC) => {
    const erc20Token = await ethers.getContractAt(
      ERCabi,
      erc20TokenAddress,
      signerERC
    );
    return erc20Token;
  };
  const getBalance = async (erc20TokenAddress, signerERC, user) => {
    const erc20Contract = await erc20(erc20TokenAddress, signerERC);
    const balance = await erc20Contract.balanceOf(user);
    console.log("Current Balance is:", balance.toString());
    return balance;
  };
  beforeEach(async () => {
    await deployments.fixture(["AutomateTest"]);
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [impersonate],
    });
    signer = await ethers.getSigner(impersonate);
    autoContract = await ethers.getContract("AutomateTest", signer);
    interval = await autoContract.interval();
  });

  describe("test upkeep", () => {
    beforeEach(async () => {
      const Erc20 = await erc20(LINK_Token, signer);
      await Erc20.transfer(autoContract.address, linkUpkeep);
    });
    it("register and check upkeep", async () => {
      console.log(interval.toString());
      await autoContract.registerAndPredictID(linkUpkeep);
      const counter = await autoContract.counter();
      const upKeepId = await autoContract.getUpkeep(counter.toString());
      console.log(upKeepId.toString());
      console.log(counter.toString());
      await network.provider.send("evm_increaseTime", [
        interval.toNumber() + 100,
      ]);
      await network.provider.request({ method: "evm_mine", params: [] });
      await autoContract.performUpkeep([]);
      const _counter = await autoContract.counter();
      const _upKeepId = await autoContract.getUpkeep(_counter.toString());
      console.log(_upKeepId.toString());
      console.log(_counter.toString());
      assert.equal(_counter.toString(), 1);
    });
    it("should be reverted", async () => {
      console.log(interval.toString());
      await autoContract.registerAndPredictID(linkUpkeep);
      const counter = await autoContract.counter();
      const upKeepId = await autoContract.getUpkeep(counter.toString());
      console.log(upKeepId.toString());
      console.log(counter.toString());
      await network.provider.send("evm_increaseTime", [
        interval.toNumber() - 100,
      ]);
      await network.provider.request({ method: "evm_mine", params: [] });
      await autoContract.performUpkeep([]);
      // const _counter = await autoContract.counter();
      // const _upKeepId = await autoContract.getUpkeep(_counter.toString());
      // console.log(_upKeepId.toString());
      // console.log(_counter.toString());
    });
  });
});
