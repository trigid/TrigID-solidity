var TokenBank = artifacts.require("./TokenBank.sol");

module.exports = function(deployer) {
  deployer.deploy(TokenBank);
};