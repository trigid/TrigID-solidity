var Auction = artifacts.require("./Auction.sol");

module.exports = function(deployer, network, accounts) {
  const wallet = accounts[1];
  const priceFactor = 10.55;
  deployer.deploy(Auction, wallet, priceFactor);
};