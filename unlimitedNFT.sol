//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract DNCT2 is Ownable, ERC721A, ERC721ABurnable, ERC721AQueryable {

    string public _tokenUri = ""; // Initial base URI
    uint256 public _currentMaxSupply = 500;
    uint256 public _currentPriceWei = 10000000000000000000; // 10USD

    struct TokenInfo {
        IERC20 paytoken;
    }

    TokenInfo[] public AllowedCrypto;

    constructor() ERC721A("UnlimitedNFT", "UnlimitedNFT") {}

    function addCurrency(IERC20 _paytoken) public onlyOwner {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken,
            })
        );
    }

    function changeBaseUri(string memory _newUri) public onlyOwner {
        _tokenUri = _newUri;
    }

    function increaseMaxSupplyAndPrice(uint256 _newMaxSupply, uint256 _newPriceWei) public onlyOwner {
        _currentMaxSupply = _newMaxSupply;
        _currentPriceWei = _newPriceWei;
    }

    function publicMint(address _to, uint256 _quantity, uint256 _pid) external payable {
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 paytoken;
        paytoken = tokens.paytoken;

        require(totalSupply() + _quantity <= _currentMaxSupply, "Cannot exceed current total supply");
        require(msg.value == _quantity * _currentPriceWei, "Not enough balance to complete transaction.");

        paytoken.transferFrom(msg.sender, address(this), _quantity * _currentPriceWei);
        _mint(_to, _quantity);
    }

    function withdraw(address payable _to, uint256 _pid) public payable onlyOwner() {
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(_to, paytoken.balanceOf(address(this)));
    }

    function withdrawMoneyTo(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
}
