const ElectionNFTManager = artifacts.require("ElectionNFTManager");

module.exports = function (deployer) {
  deployer.deploy(ElectionNFTManager, 'Verkiezingen 2021', 'VKNL', 100);
};
