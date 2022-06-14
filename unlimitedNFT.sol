//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UnlimitedNFT is ERC721, ERC721Enumerable, ERC2981, Ownable {
    string public _tokenUri = ""; // Initial base URI

    constructor() ERC721("UnlimitedNFT", "UnlimitedNFT") {}

    function changeBaseUri(string memory _newUri) public onlyOwner {
        _tokenUri = _newUri;
    }

    function mintMany(address _to, uint256 _n) public onlyOwner {
        uint256 ts = totalSupply();
        for (uint256 i = 1; i <= _n; i++) {
            _mint(_to, ts + i);
        }
    }

    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) public onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    /** OVERRIDES */
    function _baseURI() internal view override returns (string memory) {
        return _tokenUri;
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
