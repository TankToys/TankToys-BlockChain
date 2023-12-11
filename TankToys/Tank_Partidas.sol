// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
@title: Administrador de partidas
@author: David Castellanos, Eduardo Rojas
@notice: Administra todas las partidas de los jugadores
@dev: Administra el mapping de las partidas de los jugadores
*/
contract TankToys_Partidas {

    address[] private staff;

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
    @dev: Inicializa a los staff
    */
    constructor() {
        staff.push(msg.sender);
        staff.push(0xc07921125b826D28453C6d4512bb7e41E0326Aa2);
        //staff.push(address edu);
    }

    /*
    @dev: Estructura en la que se basan las parrtidas
    */
    struct partida {
        address[] players;
        address[] winners;
        bool win;
        uint kills;
        uint deaths;
        uint assist;
    }

    /*
    @dev: Mapping de las partidas le introduces el addres y te todas las partidas de mas antigua a mas reciente
    */
    mapping (address => partida[]) partidas;

    /*
    @dev: Evento que salta al añadir una partida
    */
    event partidaPushed(address player, partida p, string message);

    /*
    @notice: Devuelve todas las partidas de un usuario
    @return: Array del struct partida
    */
    function getMatches(address player) public view returns (partida[] memory){
        require(partidas[player].length > 0, "Este usuario no ha jugado ninguna partida");
        return partidas[player];
    }

    /*
    @dev: Retorna las ultimas 10 sino las ultimas que haya 
    @notice: Devuelve las ultimas 10 partidas
    @return: Array del struct partida
    */
    function getLast10Matches(address player) public view returns (partida[] memory) {
        require(partidas[player].length > 0, "El usuario no ha jugado ninguna partida");
        partida[] memory arr = new partida[](10);
        uint cont = 0;
        uint condicion = 0;
        if (partidas[player].length > 10) {
            condicion = partidas[player].length - 9;
        }
        for (uint i = partidas[player].length-1; i >= condicion; i--) 
        {
            arr[cont] = partidas[player][i];
            cont++;
        }   

        return  arr;
    }

    /*
    @dev: Pushea otra partida al maping de partidas
    @notice: Añade otra partida
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
        emit partidaPushed(player, partida(players,winners,win,kills,deaths,assists), "Partida anadida con exito");
        
    }

    


}