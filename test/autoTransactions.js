const { expect, assert } = require("chai");
const { deployments, network, ethers } = require("hardhat");
const { networkConfig } = require("../helper_hardhat");
const ERCabi = require("../constants/ERC20Abi.json");

describe("Automating test", () => {
  let autoContract, signer, interval;
  const chain = network.config.chainId;
  const LINK_Token = networkConfig[chain].LINK_Token;
  const linkUpkeep = ethers.utils.parseEther("7");
  const amountLINK = ethers.utils.parseEther("100");
  const impersonate = networkConfig[chain].Impersonate;
  //const Myaddress = "0x9353CdB9598937A9a9DD1D792A4D822EE8415E8D";
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
    await deployments.fixture(["AutoTransactions"]);
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [impersonate],
    });
    signer = await ethers.getSigner(impersonate);
    autoContract = await ethers.getContract("AutoTransactions", signer);
    interval = await autoContract.interval();
  });

  describe("Supply Function", () => {
    beforeEach(async () => {
      const Erc20 = await erc20(LINK_Token, signer);

      await Erc20.transfer(autoContract.address, amountLINK);
    });
    it("should check if supply works", async () => {
      console.log(interval.toString());
      await autoContract.approval(LINK_Token, amountLINK);
      await autoContract.supply(LINK_Token, amountLINK);
      const ERc20 = await getBalance(LINK_Token, signer, autoContract.address);
      assert.equal(ERc20.toString(), 0);
    });
  });
  describe("Register and performUpkeep", () => {
    beforeEach(async () => {
      const Erc20 = await erc20(LINK_Token, signer);
      const total = ethers.utils.parseEther("107");
      await Erc20.transfer(autoContract.address, total);
    });
    it("should register and performUpkeep", async () => {
      await autoContract.approval(LINK_Token, amountLINK);
      await autoContract.setAddress(LINK_Token, amountLINK);
      await autoContract.registerAndPredictID(linkUpkeep);
      await network.provider.send("evm_increaseTime", [
        interval.toNumber() + 100,
      ]);
      await network.provider.request({ method: "evm_mine", params: [] });
      await autoContract.performUpkeep([]);
      const conBalance = await getBalance(
        LINK_Token,
        signer,
        autoContract.address
      );
      assert.equal(conBalance.toString(), 0);
    });
    it("should not call the supply Function", async () => {
      await autoContract.approval(LINK_Token, amountLINK);
      await autoContract.setAddress(LINK_Token, amountLINK);
      await autoContract.registerAndPredictID(linkUpkeep);
      await network.provider.send("evm_increaseTime", [
        interval.toNumber() - 200,
      ]);
      await network.provider.request({ method: "evm_mine", params: [] });
      await autoContract.performUpkeep([]);
      const conBalance = await getBalance(
        LINK_Token,
        signer,
        autoContract.address
      );

      assert.equal(conBalance.toString(), amountLINK);
    });
  });
});
