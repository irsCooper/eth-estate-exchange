// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
pragma abicoder v2;

import "./standart_token//token/ERC20/ERC20.sol";

contract Eston is ERC20("Eston", "ESTON") {
    constructor(address account, uint totalSupply) {
        _mint(account, totalSupply);
    }

    function _Transfer(address from, address to, uint value) public {
        _transfer(from, to, value);
    }

    function _BalanceOf(address from) public view returns(uint) {
        return balanceOf(from);
    }
}