const Shrinkify = artifacts.require("Shrinkify");
module.exports = function(deployer) {
  deployer.deploy(Shrinkify);
};
