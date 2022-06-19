const fs = require("fs");
const { ethers, network } = require("hardhat");

const frontendAbiLocation = "../nft-minter-frontend/constants/";
const frontendContractsFile = "../nft-minter-frontend//constants/networkMapping.json";

module.exports = async () => {
	if (process.env.UPDATE_FRONTEND) {
		console.log("Updating frontend");
		await updateContractAddresses();
		await updateABI();
	}
};

async function updateABI() {
	const roboPunks = await ethers.getContract("RoboPunksNFT");
	fs.writeFileSync(
		`${frontendAbiLocation}RoboPunksNFT.json`,
		roboPunks.interface.format(ethers.utils.FormatTypes.json)
	);
}

async function updateContractAddresses() {
	const roboPunks = await ethers.getContract("RoboPunksNFT");
	const chainId = network.config.chainId.toString();
	const contractAddresses = JSON.parse(fs.readFileSync(frontendContractsFile, "utf8"));

	if (chainId in contractAddresses) {
		if (!contractAddresses[chainId]["RoboPunksNFT"].includes(roboPunks.address)) {
			contractAddresses[chainId]["RoboPunksNFT"].push(roboPunks.address);
		}
	} else {
		contractAddresses[chainId] = { RoboPunksNFT: [roboPunks.address] };
	}

	fs.writeFileSync(frontendContractsFile, JSON.stringify(contractAddresses));
}

module.exports.tags = ["all", "fe"];
