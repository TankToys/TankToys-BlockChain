// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "TankToys/TKC_ERC20.sol";
import "TankToys/Tank_Players.sol";
import "TankToys/Tank_Partidas.sol";

/**
 * @title Administrador de pagos
 * @notice Administra las compras y las recompensas
 * @dev Administra el transform
 * @author David Castellanos, Eduardo Rojas
 */
contract TankToys {
    string username;
    string userpass;
    address[] private staff;

    /**
     * @dev Variables de los otros contracts
     */
    TankCoin tkc;
    TankToys_Players usuarios;
    TankToys_Partidas partidas;

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
     * @dev Inicializa las variables de los otros contratos 
     * @param _partidas Dirección del contrato de partidas
     * @param _usuarios Dirección del contrato de usuarios
     * @param _tkc Dirección del contrato de TankCoin
     */
    constructor(address _partidas, address _usuarios, address _tkc) {
        staff.push(msg.sender);
        staff.push(0xc07921125b826D28453C6d4512bb7e41E0326Aa2); // David wallet address
        staff.push(0xb6BeC91C4c773Fb84071152A212394786A7a31Ef); // Edu wallet address
        tkc = TankCoin(_tkc);
        usuarios = TankToys_Players(_usuarios);
        partidas = TankToys_Partidas(_partidas);
    }

    /**
     * @dev Estructura de un usuario
     */
    struct user {
        address[] friends;
        address direction;
        partida ultima;
    }

    /**
     * @dev Estructura de una partida
     */
    struct partida {
        address[] players;
        address[] winners;
        bool win;
        uint kills;
        uint assist;
        uint deaths;
    }

    /**
     * @dev Evento que se llama a la hora de transferir las recompensas
     */
    event rewardsClaimed(address player, uint nCoins, string message);

    /**
     * @dev Transferfrom de los tokens y moifica la ultima partida y la añade al mappins de partidas
     * @notice Transfiere los TankCoins y actualiza la ultima partida
     * @param nCoins Número de TankCoins a transferir
     * @param direction Dirección del jugador
     * @param players Direcciones de los jugadores en la partida
     * @param winners Direcciones de los ganadores de la partida
     * @param win Indica si la partida fue ganada
     * @param kills Número de asesinatos en la partida
     * @param deaths Número de muertes en la partida
     * @param assist Número de asistencias en la partida
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
        public
        isStaff
    {
        this.contractPaySomething(direction, nCoins);
        usuarios.updateLastMatch(direction, players, winners, win, kills, deaths, assist);
        partidas.addPartida(direction, players, winners, win, kills, deaths, assist);
        emit rewardsClaimed(direction, nCoins, "Recompensas de la partida transferida");
    }

    /**
     * @dev Approve y transferfrom
     * @param player Dirección del jugador al que se le transfiere
     * @param nCoins Número de TankCoins a transferir
     */
    function userPaySomething(address player, uint nCoins) external isStaff {
        require(nCoins > 0, "No has pagado nada");
        tkc.aprobar(player, address(tkc), nCoins);
    }

    /**
     * @dev Approve y transferfrom
     * @param player Dirección del jugador que realiza el pago
     * @param nCoins Número de TankCoins a transferir
     */
    function contractPaySomething(address player, uint nCoins) external isStaff {
        require(nCoins > 0, "No has pagado nada");
        tkc.aprobar(address(tkc), player, nCoins);
    }
}
