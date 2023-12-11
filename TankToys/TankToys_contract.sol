// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "TankToys/TKC_ERC20.sol";
import "TankToys/Tank_Players.sol";
import "TankToys/Tank_Partidas.sol";

/*
@title: Administrador de pagos
@author: David Castellanos, Eduardo Rojas
@notice: Administra las compras y las recompensas
@dev: Administra el transform
*/
contract TankToys {
    string username;
    string userpass;
    address[] private staff;

    /*
    @dev: Variables de los otros contracts
    */
    TankCoin tkc;
    TankToys_Players usuarios;
    TankToys_Partidas partidas;


    /*
    @dev: Modifier que comprueba si el sender es de los staff
    */
    modifier isStaff() {
        bool flag = false;
        for (uint i = 0; i < staff.length && !flag; i++) 
        {
            if (staff[i] == msg.sender) {
                flag = true;
            }
        }
        require(flag, "Sorry staff only");
        _;
    }

    /*
    @dev: Inicializa las variables de los otros contratos 
    */
    constructor(address _partidas, address _usuarios, address _tkc) {
        staff.push(msg.sender);
        staff.push(0xc07921125b826D28453C6d4512bb7e41E0326Aa2);
        //staff.push(address edu);
        tkc = TankCoin(_tkc);
        usuarios = TankToys_Players(_usuarios);
        partidas = TankToys_Partidas(_partidas);
    }

    /*
    @dev: Estructura de un usuario
    */
    struct user {
        address[] friends;
        address direction;
        partida ultima;
    }

    /*
    @dev: Estructura de una partida
    */
    struct partida {
        address[] players;
        address[] winners;
        bool win;
        uint kills;
        uint assist;
        uint deaths;
    }

    /*
    @dev: Evento que se llama a la hora de transferir las recompensas
    */
    event rewardsClaimed(address player, uint nCoins, string message);

    /*
    @dev: Transferfrom de los tokens y moifica la ultima partida y la añade al mappins de partidas
    @notice: Transfiere los TankCoins y actualiza la ultima partida
    @inherit: Utiliza funciones de Tank_PLayers y Tank_Partidas
    */
    function afterMatchRewards(
        uint nCoins, 
        address direction, 
        address[] memory players, 
        address[] memory winners, 
        bool win, 
        uint kills, 
        uint deaths, 
        uint assist 
    ) 
        public isStaff
    {
        this.paySomething(direction, nCoins);
        usuarios.updateLastMatch(direction, players, winners, win, kills, deaths, assist);
        partidas.addPartida(direction, players, winners, win, kills, deaths, assist);
        emit rewardsClaimed(direction, nCoins, "Recompensas de la partida transferida");
    }

    /*
    @dev: Approve y transferfrom
    @inherit: Utiliza funciones de TKC_ERC20
    */
    function paySomething(address player, uint nCoins) external isStaff payable {
        require(nCoins > 0, "No has pagado nada");
        tkc.aprobar(staff[0], player, nCoins);
        tkc.transferFrom(player, staff[0], nCoins);
    }

}