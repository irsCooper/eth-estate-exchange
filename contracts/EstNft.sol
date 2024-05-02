// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EstNft is ERC721("EsExNft", "ESEXN") {

    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }

    function transfer(address from, address to, uint tokenId) public {
        _transfer(from, to, tokenId);
    }

    function BalanceOf(address owner) public view returns(uint) {
        return balanceOf(owner);
    }

    function OwnerOf(uint tokenId) public view returns(address) {
        return ownerOf(tokenId);
    } 
}
