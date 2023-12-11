// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TankCoin is ERC20 {
    constructor()
        ERC20("TankCoin", "TKC")

    {
        _mint(address(this), 10000);
    }

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }

    function aprobar(address propietario, address spender, uint value) public  {
        _approve(propietario, spender, value);
        _transfer(propietario, spender, value);
    }
}