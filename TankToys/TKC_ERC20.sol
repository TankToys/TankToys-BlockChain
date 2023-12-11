// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TankCoin is ERC20, ERC20Permit {
    constructor()
        ERC20("TankCoin", "TKC")

        ERC20Permit("TankCoin")
    {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }

    function aprobar(address propietario, address spender, uint value) public  {
        _approve(propietario, spender, value);
    }
}