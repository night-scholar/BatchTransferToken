// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract TestERC721 is ERC721, Ownable {
    string private nftName;
    string private nftSymbol;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(string memory name_,string memory symbol_,string memory _uri) ERC721(name_, symbol_) {
        nftName = name_;
        nftSymbol = symbol_;
        _setBaseURI(_uri);
    }

  function mint(address _to, string calldata _uri) external onlyOwner  {
    uint256 _tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    super._mint(_to, _tokenId);
    super._setTokenURI(_tokenId, _uri);
  }

  function setURI(string memory _uri) external onlyOwner{
    super._setBaseURI(_uri);
  }
}