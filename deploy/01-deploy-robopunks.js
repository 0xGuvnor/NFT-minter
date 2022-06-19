const { developmentChains, BLOCK_CONFIRMATIONS } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async ({ deployments, getNamedAccounts }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	log("====================================================================");

	const args = [];
	const waitConfirmations = developmentChains.includes(network.name) ? 1 : BLOCK_CONFIRMATIONS;
	const roboPunks = await deploy("RoboPunksNFT", {
		from: deployer,
		args,
		log: true,
		waitConfirmations,
	});

	if (!developmentChains.includes(network.name)) {
		await verify(roboPunks.address, args);
	}
};

module.exports.tags = ["all", "rp"];
