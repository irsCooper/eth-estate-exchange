// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
pragma abicoder v2;

import "./EstNft.sol";
import "./Eston.sol";

contract Contract {
    EstNft public nft;
    Eston  public token;

    address Owner;

    uint PRICE_ESTON = 10000 wei;

    uint estateId = 1;
    
    constructor(address estNft, address eston) {
        nft = EstNft(estNft);
        token = Eston(eston);
        Owner = msg.sender;
    }

    struct Estate { 
        uint Id;
        string Address;
        string Desc;
        string Haracteristic;
    }

    struct Deal {
        uint Id;
        Estate Estate;
        address Arendator;
        uint Mounth;
        uint PriceOneMounth;
        uint MounthPay;
        bool Active;
    }

    struct ArendsEstate {
        uint Id;
        Estate Estate;
        address OwnerEstate;
        uint MinMounth;
        uint MaxMounth;
        uint PriceOneMounth;
    }

    struct RequestRent {
        uint Id;
        address Arendator;
        uint Mounth;
    }


    mapping (uint => Estate) public estate;
    mapping (uint => bool) estateSell;

    mapping (uint => bool) estateRents; //арендуется ли в настоящий момент
    
    mapping (address => Deal[]) public userDeal; //сделки пользователя

    ArendsEstate[] arends;
    mapping (uint => RequestRent[]) requestRent;
    
    mapping (address => uint) userArendsEstate; //число арендованных домов пользователя
    mapping (address => mapping (uint => bool)) public estateArendator; //является ли пользователь арендатором недвижимости 

    mapping (address => mapping (uint => uint)) ownerIdDeal;


    modifier isEstate(uint tokenId) {
        require(estate[tokenId].Id != 0, "invalid token");
        _;
    }

    modifier CheckOwnerOfEstate(uint tokenId)  {
        require(nft.OwnerOf(tokenId) == msg.sender, "this user is not owner for token");
        _;
    }





    function setEstate(string memory _address, string memory _desc, string memory _haract) public {
        uint tokenId = estateId++;

        nft.mint(msg.sender, tokenId);
        estate[tokenId] = Estate(tokenId, _address, _desc, _haract);
    }

    function getUserEstate() public view returns(Estate[] memory) {
        Estate[] memory es = new Estate[](nft.BalanceOf(msg.sender));
        uint p;

        for(uint i = 1; estateId > i; i++) {
            if(nft.OwnerOf(i) == msg.sender) {
                es[p] = estate[i];
                p++;
            }
        }

        return es;
    }

    ///добавить на биржу, с целью арендовать кому-нибудь дом
    function toAdrendsEstate(uint tokenId, uint min, uint max, uint price) public isEstate(tokenId) CheckOwnerOfEstate(tokenId) {
        require(estateRents[tokenId] == false, "this estate already rents");

        requestRent[arends.length].push(RequestRent(0, address(0), 0));

        arends.push(ArendsEstate(
            arends.length,
            estate[tokenId],
            msg.sender,
            min,
            max,
            price
        ));
    }

    function setRequestToRentEstate(uint _id, uint _mounth) public {
        require(arends.length > _id, "invalid id");
        ArendsEstate memory ae = arends[_id];
        require(ae.MinMounth <= _mounth && ae.MaxMounth >= _mounth, "incorrect mounth of arend");
        require(token._BalanceOf(msg.sender) >= ae.PriceOneMounth * _mounth, "not money");

        requestRent[_id].push(RequestRent(requestRent[_id].length, msg.sender, _mounth));
    }

    function getArendsEstate() public view returns(ArendsEstate[] memory) {
        return arends;
    }

    function getRequestToRentEstate(uint id) public view returns(RequestRent[] memory) {
        return requestRent[id];
    }

    function setArendsEstate(uint idRent, uint idRequest) public {
        require(idRequest < requestRent[idRent].length && idRequest > 0, "invalid id");
        ArendsEstate memory ae = arends[idRent];
        RequestRent memory req = requestRent[idRent][idRequest];
        require(ae.OwnerEstate == msg.sender, "you are not owner this request");
        
        setUserArendsEstate(req.Arendator, ae.Estate.Id, true);

        ownerIdDeal[msg.sender][ae.Estate.Id] = userDeal[msg.sender].length;
        userDeal[msg.sender].push(Deal(
            userDeal[msg.sender].length,
            ae.Estate,
            req.Arendator,
            req.Mounth,
            ae.PriceOneMounth,
            0,
            true
        ));


        userDeal[req.Arendator].push(Deal(
            userDeal[req.Arendator].length,
            ae.Estate,
            req.Arendator,
            req.Mounth,
            ae.PriceOneMounth,
            0,
            true
        ));

        delete requestRent[idRent];
        requestRent[idRent] = requestRent[arends.length - 1];
        delete  requestRent[arends.length - 1];

        arends[arends.length - 1].Id = idRent;
        arends[idRent] = arends[arends.length - 1];
        arends.pop();
    }
    

    ///добавить пользователю ареду
    function setUserArendsEstate(address arendator, uint tokenId, bool status) internal CheckOwnerOfEstate(tokenId) {
        userArendsEstate[arendator]++;
        estateArendator[arendator][tokenId] = status;
        estateRents[tokenId] = status;
    }

    function getUserArendsEstate(address owner) public view returns(Estate[] memory) {
        Estate[] memory es = new Estate[](userArendsEstate[owner]);
        uint p;

        for(uint i = 1; estateId > i; i++) {
            if(estateArendator[owner][i] == true) {
                es[p] = estate[i];
                p++;
            }
        }

        return es;
    }


    ///вводится id deal!!!!!!
    function payRent(uint id, uint mounth) public  {
        require(userDeal[msg.sender].length > id, "invalid id");
        Deal storage deal = userDeal[msg.sender][id];
        address owner = nft.OwnerOf(deal.Estate.Id);
        require(token._BalanceOf(msg.sender) >= deal.PriceOneMounth * mounth, "not money");
        require(deal.MounthPay + mounth <= deal.Mounth && deal.MounthPay >= deal.Mounth - deal.MounthPay + mounth, "invalid mounth");

        token._Transfer(msg.sender, owner, deal.PriceOneMounth * mounth);
        deal.MounthPay += mounth;

        if(deal.MounthPay == deal.Mounth) {
            deal.Active = false;
            userDeal[owner][ownerIdDeal[owner][deal.Estate.Id]].Active = false;
        }
    }


    function payToken() public payable {
        token._Transfer(Owner, msg.sender, msg.value / PRICE_ESTON);
        payable(msg.sender).transfer(msg.value % PRICE_ESTON);
    }
}