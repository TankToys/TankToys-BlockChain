/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TankCoin
 * @dev TankCoin is a simple ERC20 token with additional minting functionality.
 */
contract TankCoin is ERC20 {

    address[] private staff;

    /**
     * @dev Modifier que comprueba si el sender es de los staff
     */
    modifier isStaff() {
        bool flag = false;
        for (uint i = 0; i < staff.length && !flag; i++) {
            if (staff[i] == msg.sender) {
                flag = true;
            }
        }
        require(flag, "Sorry staff only");
        _;
    }

    /**
     * @dev Constructor function to initialize the TankCoin contract.
     */
    constructor() ERC20("TankCoin", "TKC") {
        staff.push(msg.sender);
        staff.push(0xc07921125b826D28453C6d4512bb7e41E0326Aa2); // David wallet address
        staff.push(0xb6BeC91C4c773Fb84071152A212394786A7a31Ef); // Edu wallet address
        _mint(address(this), 10000);
    }

    /**
     * @dev Mint new tokens and assign them to the specified address.
     * @param to The address to which the new tokens will be minted.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public isStaff {
        _mint(to, amount);
    }

    /**
     * @dev Approve and transfer tokens between two addresses.
     * @param propietario The owner's address.
     * @param spender The address allowed to spend the owner's tokens.
     * @param value The amount of tokens to be approved and transferred.
     */
    function aprobar(address propietario, address spender, uint value) public {
        _approve(propietario, spender, value);
        _transfer(propietario, spender, value);
    }
}
