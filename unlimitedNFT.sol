//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DNCPOL is ERC721Enumerable, ERC721URIStorage, Ownable {

    string public tokenUri = "https://nft.trvcdn.com/dnc/"; // Initial base URI

    uint256 public counter = 0;
    uint256 public currentMaxSupply = 500;
    uint256 public currentPriceWei = 10000000000000000000; // 10USD

    IERC20[16] public stablecoins = [
        IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174), // USDC Polygon
        IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F),  // USDT Polygon
    ];

    bool public activeMintUSD = true;
    bool public activeMintETH = false;

    constructor() ERC721("Digital Nomads Club", "DNC") {}

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

    function fixCounter(uint256 c) external onlyOwner {
        counter = c;
    }

    function publicMintUSD(address to, uint256 quantity, uint256 pid) external payable {
        uint256 totalPrice = quantity * currentPriceWei;
        require(activeMintUSD && counter + quantity <= currentMaxSupply && msg.value == totalPrice);
        stablecoins[pid].transferFrom(msg.sender, address(this), totalPrice);
        uint256 tmpCounter = counter;
        counter += quantity;
        for(uint256 i = 1; i <= quantity; i++) {
            _mint(to, tmpCounter + i);
        }        
    }

    function publicMintETH(address to, uint256 quantity) external payable {
        require(activeMintETH && counter + quantity <= currentMaxSupply && msg.value == quantity * currentPriceWei);
        uint256 tmpCounter = counter;
        counter += quantity;
        for(uint256 i = 1; i <= quantity; i++) {
            _mint(to, tmpCounter + i);
        }
    }

    function withdrawUSD(address payable to, uint256 pid) external payable onlyOwner() {
        IERC20 paytoken = stablecoins[pid];
        paytoken.transfer(to, paytoken.balanceOf(address(this)));
    }

    function withdrawETH(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
