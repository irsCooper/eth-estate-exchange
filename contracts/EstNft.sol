// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EstNft is ERC721("EsExNft", "ESEXN") {

    address Owner;

    constructor(address owner) {
        Owner = owner;
    }
    
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


    uint estateId;

    struct Estate { 
        uint Id;
        string Address;
        string Desc;
        string Haracteristic;
    }

    mapping (uint => Estate) public estate;



    function setEstate(string memory _address, string memory _desc, string memory _haract) public {
        estate[estateId] = Estate(estateId, _address, _desc, _haract);
        estateId++;
    }

    function getUserEstate() public view returns(Estate[] memory) {
        Estate[] memory es = new Estate[](BalanceOf(msg.sender));
        uint p;

        for(uint i = 0; estateId > i; i++) {
            if(OwnerOf(i) == msg.sender) {
                es[p] = estate[i];
                p++;
            }
        }

        return es;
    }
}