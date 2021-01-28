const ElectionFTManager = artifacts.require("ElectionFTManager");

module.exports = function (deployer) {
  deployer.deploy(ElectionFTManager, 'Verkiezingen 2021', 'VKNL', 100);
};
