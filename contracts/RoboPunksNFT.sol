// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RoboPunksNFT__TokenIdDoesNotExist();
error RoboPunksNFT__WithdrawFailed();
error RoboPunksNFT__ExceededMaxPerWallet();
error RoboPunksNFT__PublicMintNotLive();
error RoboPunksNFT__IncorrectMintFee();
error RoboPunksNFT__MaxSupplyReached();

contract RoboPunksNFT is ERC721, Ownable {
	using Strings for uint256;

	uint256 private s_mintPrice;
	uint256 private s_totalSupply;
	uint256 private s_maxSupply;
	uint256 private s_maxPerWallet;
	bool private s_isPublicMintEnabled;
	string internal s_baseTokenURI;
	address payable private s_withdrawWallet;
	mapping(address => uint256) private s_walletMints;

	constructor() ERC721("RoboPunks", "RP") {
		s_mintPrice = 0.0001 ether;
		s_totalSupply = 0;
		s_maxSupply = 420;
		s_maxPerWallet = 3;
		s_withdrawWallet = payable(msg.sender);
	}

	function setIsPublicMintEnabled(bool isPublicMintEnabled) external onlyOwner {
		s_isPublicMintEnabled = isPublicMintEnabled;
	}

	function setBaseTokenURI(string calldata baseTokenURI) external onlyOwner {
		s_baseTokenURI = baseTokenURI;
	}

	function tokenURI(uint256 tokenId) public view override returns (string memory) {
		if (!_exists(tokenId)) revert RoboPunksNFT__TokenIdDoesNotExist();

		return string(abi.encodePacked(s_baseTokenURI, tokenId.toString(), ".json"));
	}

	function withdraw() external onlyOwner {
		(bool success, ) = s_withdrawWallet.call{value: address(this).balance}("");
		if (!success) revert RoboPunksNFT__WithdrawFailed();
	}

	function mint(uint256 quantity) external payable {
		if (!s_isPublicMintEnabled) revert RoboPunksNFT__PublicMintNotLive();
		if (msg.value < quantity * s_mintPrice) revert RoboPunksNFT__IncorrectMintFee();
		if (s_totalSupply + quantity > s_maxSupply) revert RoboPunksNFT__MaxSupplyReached();
		if (s_walletMints[msg.sender] + quantity >= s_maxPerWallet)
			revert RoboPunksNFT__ExceededMaxPerWallet();

		for (uint256 i = 0; i < quantity; i++) {
			uint256 tokenId = s_totalSupply + 1;
			s_walletMints[msg.sender]++;
			s_totalSupply++;

			_safeMint(msg.sender, tokenId);
		}
	}

	// Getter functions
	function getMintPrice() external view returns (uint256) {
		return s_mintPrice;
	}

	function getTotalSupply() external view returns (uint256) {
		return s_totalSupply;
	}

	function getMaxSupply() external view returns (uint256) {
		return s_maxSupply;
	}

	function getMaxPerWallet() external view returns (uint256) {
		return s_maxPerWallet;
	}

	function getIsPublicMintEnabled() external view returns (bool) {
		return s_isPublicMintEnabled;
	}
}
