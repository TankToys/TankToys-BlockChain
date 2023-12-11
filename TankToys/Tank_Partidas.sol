// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TankToys_Partidas
 * @notice Administra todas las partidas de los jugadores
 * @dev Administra el mapping de las partidas de los jugadores
 * @author David Castellanos, Eduardo Rojas
 */
contract TankToys_Partidas {

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
     * @dev Inicializa a los staff
     */
    constructor() {
        staff.push(msg.sender);
        staff.push(0xc07921125b826D28453C6d4512bb7e41E0326Aa2); // David wallet address
        staff.push(0xb6BeC91C4c773Fb84071152A212394786A7a31Ef); // Edu wallet address
    }

    /**
     * @dev Estructura en la que se basan las partidas
     */
    struct partida {
        address[] players;
        address[] winners;
        bool win;
        uint kills;
        uint deaths;
        uint assist;
    }

    /**
     * @dev Mapping de las partidas le introduces el address y te devuelve todas las partidas de más antigua a más reciente
     */
    mapping (address => partida[]) partidas;

    /**
     * @dev Evento que salta al añadir una partida
     */
    event partidaPushed(address player, partida p, string message);

    /**
     * @notice Devuelve todas las partidas de un usuario
     * @param player La dirección del jugador
     * @return Array del struct partida
     */
    function getMatches(address player) public view returns (partida[] memory){
        require(partidas[player].length > 0, "Este usuario no ha jugado ninguna partida");
        return partidas[player];
    }

    /**
     * @dev Retorna las últimas 10 sino las últimas que haya
     * @notice Devuelve las últimas 10 partidas
     * @param player La dirección del jugador
     * @return Array del struct partida
     */
    function getLast10Matches(address player) public view returns (partida[] memory) {
        require(partidas[player].length > 0, "El usuario no ha jugado ninguna partida");
        partida[] memory arr = new partida[](10);
        uint cont = 0;
        uint condicion = 0;
        if (partidas[player].length > 10) {
            condicion = partidas[player].length - 9;
        }
        for (uint i = partidas[player].length-1; i >= condicion; i--) {
            arr[cont] = partidas[player][i];
            cont++;
        }   
        return  arr;
    }

    /**
     * @dev Pushea otra partida al mapping de partidas
     * @notice Añade otra partida
     * @param player La dirección del jugador
     * @param players Los jugadores en la partida
     * @param winners Los jugadores ganadores
     * @param win Si la partida fue ganada o no
     * @param kills Número de asesinatos
     * @param deaths Número de muertes
     * @param assists Número de asistencias
     */
    function addPartida(
        address player, 
        address[] memory players, 
        address[] memory winners, 
        bool win, 
        uint kills, 
        uint deaths, 
        uint assists
    ) 
        public isStaff
    {
        if (players.length > 0) {
            partidas[player].push(partida(players,winners,win,kills,deaths,assists));
        } else {
            revert("Partida sin jugadores");
        }
        emit partidaPushed(player, partida(players,winners,win,kills,deaths,assists), "Partida añadida con éxito");
    }
}
