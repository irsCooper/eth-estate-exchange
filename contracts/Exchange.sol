// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
pragma abicoder v2;

import "./EstNft.sol";
import "./Eston.sol";

contract Contract {
    EstNft public nft;
    Eston  public token;

    address Owner;

    constructor(address estNft, address eston) {
        nft = EstNft(estNft);
        token = Eston(eston);
        owner = msg.sender;
    }



    struct Deal {
        uint Id;
        uint EstateId;
        address OwnerEstate;
        address Arendator;
        uint Mounth;
        uint PriceOneMounth;
        bool Active;
    }

    mapping (address => Deal) userDeal; //сделки пользователя

    struct ArendsEstate {
        uint Id;
        uint EstateId;
        address OwnerEstate;
        uint MinMounth;
        uint MaxMounth;
        uint PriceOneMounth;
    }

    ArendsEstate[] arends;
    mapping (uint => Deal) delFromArends; // заявки на аренду

    


    mapping (uint => bool) public estateSell;
    mapping (address => mapping (uint => bool)) public estateArendator; //является ли пользователь арендатором недвижимости

    mapping (address => uint) userArendsEstate; //число арендованных домов пользователя

    function changeSellEstate(address owner, uint tokenId, bool status) public {
        require(estateOwner[tokenId] == owner, "you are not owner this token");
        estateSell[tokenId] = status;
    }

    function getUserArendsEstate() public view returns(Estate[] memory) {
        Estate[] memory es = new Estate[](userArendsEstate[msg.sender]);
        uint p;

        for(uint i = 0; estateId > i; i++) {
            if(estateArendator[msg.sender][i] == true) {
                es[p] = estate[i];
                p++;
            }
        }

        return es;
    }
}