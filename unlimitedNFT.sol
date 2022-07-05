//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract DNC3 is Ownable, ERC721A, ERC721ABurnable, ERC721AQueryable {

    string public tokenUri = "https://nft.trvcdn.com/dnc/"; // Initial base URI
    uint256 public currentMaxSupply = 500;
    uint256 public currentPriceWei = 10000000000000000000; // 10USD

    IERC20[16] public stablecoins = [
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), // USDC Ethereum
        IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174), // USDC Polygon
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7), // USDT Ethereum
        IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F)  // USDT Polygon
    ];

    bool public activeMintUSD = true;
    bool public activeMintETH = false;

    constructor() ERC721A("Digital Nomads Club", "DNC") {}

    function setActiveMintUSD(bool active) external onlyOwner {
        activeMintUSD = active;
    }

    function setActiveMintETH(bool active) external onlyOwner {
        activeMintETH = active;
    }

    function addCurrency(uint i, IERC20 paytoken) external onlyOwner {
        stablecoins[i] = paytoken;
    }

    function removeCurrency(uint i) external onlyOwner {
        delete stablecoins[i];
    }

    function changeBaseUri(string calldata newUri) external onlyOwner {
        tokenUri = newUri;
    }

    function increaseMaxSupplyAndPrice(uint256 newMaxSupply, uint256 newPriceWei) external onlyOwner {
        currentMaxSupply = newMaxSupply;
        currentPriceWei = newPriceWei;
    }

    function publicMintUSD(address to, uint256 quantity, uint256 pid) external payable {
        uint256 totalPrice = quantity * currentPriceWei;
        require(activeMintUSD && totalSupply() + quantity <= currentMaxSupply && msg.value == totalPrice);
        stablecoins[pid].transferFrom(msg.sender, address(this), totalPrice);
        _mint(to, quantity);
    }

    function publicMintETH(address to, uint256 quantity) external payable {
        require(activeMintETH && totalSupply() + quantity <= currentMaxSupply && msg.value == quantity * currentPriceWei);
        _mint(to, quantity);
    }

    function withdrawUSD(address payable to, uint256 pid) external payable onlyOwner() {
        stablecoins[pid].transfer(to, paytoken.balanceOf(address(this)));
    }

    function withdrawETH(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }
}
