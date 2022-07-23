//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DNCT is ERC721Enumerable, Ownable {

    string public tokenUri = "https://nft.trvcdn.com/dnc/info/"; // Initial base URI

    uint256 public counter;
    uint256 public maxSupply;
    uint256 public priceMatic;
    uint256 public priceUSD;

    IERC20 public stablecoin = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174); // USDC Polygon

    bool public isActiveMatic = false;
    bool public isActiveUSD = false;

    event currentPriceUSD(uint256 indexed _newPriceUSD);
    event currentPriceMatic(uint256 indexed _newPriceMatic);
    event currentMaxSupply(uint256 indexed _newMaxSupply);

    constructor() ERC721("Digital Nomads Club", "DNC") {}

    function setActiveMatic(bool active) external onlyOwner {
        isActiveMatic = active;
    }

    function setActiveUSD(bool active) external onlyOwner {
        isActiveUSD = active;
    }

    function changeStablecoin(IERC20 newStablecoin) external onlyOwner {
        stablecoin = newStablecoin;
    }

    function changeTokenUri(string calldata newUri) external onlyOwner {
        tokenUri = newUri;
    }

    function changePriceMatic(uint256 newPriceMatic) external onlyOwner {
        priceMatic = newPriceMatic;
        emit currentPriceMatic(newPriceMatic);
    }

    function changePriceUSD(uint256 newPriceUSD) external onlyOwner {
        priceUSD = newPriceUSD;
        emit currentPriceUSD(newPriceUSD);
    }

    function changeMaxSupply(uint256 newMaxSupply) external onlyOwner {
        maxSupply = newMaxSupply;
        emit currentMaxSupply(newMaxSupply);
    }

    function fixCounter(uint256 c) external onlyOwner {
        counter = c;
    }

    function privateMint(address to, uint256 quantity) external onlyOwner {
        uint256 tmpCounter = counter;
        counter += quantity;
        for(uint256 i = 1; i <= quantity; i++) {
            _mint(to, tmpCounter + i);
        }
    }

    function publicMintUSD(address to, uint256 quantity) external {
        uint256 totalPrice = quantity * priceUSD;
        require(isActiveUSD, "Public sale not active (USD)!");
        require(counter + quantity <= maxSupply, "Cannot mint more than current max supply!");
        require(stablecoin.transferFrom(msg.sender, address(this), totalPrice), "Cannot send stablecoins!");
        uint256 tmpCounter = counter;
        counter += quantity;
        for(uint256 i = 1; i <= quantity; i++) {
            _mint(to, tmpCounter + i);
        }
    }

    function publicMintMatic(address to, uint256 quantity) external payable {
        require(isActiveMatic, "Public sale not active (matic)!");
        require(counter + quantity <= maxSupply, "Cannot mint more than current max supply!");
        require(msg.value == quantity * priceMatic, "Incorrect amount sent!");
        uint256 tmpCounter = counter;
        counter += quantity;
        for(uint256 i = 1; i <= quantity; i++) {
            _mint(to, tmpCounter + i);
        }
    }

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokensId;
    }

    function withdrawUSD(address payable to) external onlyOwner {
        stablecoin.transfer(to, stablecoin.balanceOf(address(this)));
    }

    function withdrawMatic(address payable to) external payable onlyOwner {
        to.transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return tokenUri;
    }
}
