var Token = artifacts.require("./Token.sol");

module.exports = function(deployer) {
  deployer.deploy(Token, "TrigID", "ID", 0, 2000000000);
};