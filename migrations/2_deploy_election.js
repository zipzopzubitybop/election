var Election = artifacts.require("Election");

module.exports = function(deployer) {
  deployer.deploy(Election,"Presidential Election 2020", "PersonA", "PersonB");
};
