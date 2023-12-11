// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
@title: Administrador de jugadores
@author: David Castellanos, Eduardo Rojas
@notice: Administra los jugadores
@dev: Administra el mapping de los jugadores
*/
contract TankToys_Players {
    
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
    @dev: Modifier que comprueba si ya tiene esa address como amigo
    */
    modifier includeFriend(address player, address newfriend) {
        bool flag = false;
        for (uint i = 0; i < usuarios[player].friends.length && !flag; i++) 
        {
            if (newfriend == usuarios[player].friends[i]) {
                flag = true;
            }
        }
        require(!flag, "Sorry staff only");
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
    @dev: Estructura de un usuario
    */
    struct user {
        address[] friends;
        bool created;
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
        uint deaths;
        uint assist;
    }

    /*
    @dev: Eventos que se llaman a la hora de añadir un amigo o un jugador
    */
    event friendPushed(address player, address friend, string message);
    event newPlayer(address player, string message);

    /*
    @dev: Mapping donde se guardan los usuarios
    */
    mapping  (address => user) usuarios;

    /*
    @dev: Retorna el struct de la ultima partida del jugador
    @notice: Devuelve la ultima partida
    @return: Struct partida
    */
    function getLastMathch(address player) public view returns (partida memory p) {
        return usuarios[player].ultima;
    }

    /*
    @dev: Retorna array con las address de los amigos
    @notice: Devuelve las direcciones de los amigos
    @return: Array de address
    */
    function getFriends(address player) public view returns (address[] memory friends) {
        return  usuarios[player].friends;
    }

    /*
    @dev: Pushea una address al array del mapping de usuarios
    @notice: Añade un amigo a una address
    */
    function addFriend(address player, address newfriend) public isStaff includeFriend(player, newfriend) {
        require(usuarios[player].created, "No puedes anadir amigos si no eres usuario");
        require(usuarios[newfriend].created);
        require(newfriend != player, "No te puedes anadir a ti mismo como amigo");
        require(abi.encodePacked(newfriend).length == 20, "Addres de amigo no valida");
        
        usuarios[player].friends.push(newfriend);
        emit friendPushed(player, newfriend, "Amigo anadido con exito");
    }

    /*
    @dev: Añade una nueva address al mapping
    @notice: Añade un jugador
    */
    function addPlayer(address player) public isStaff {
        require(abi.encodePacked(player).length > 0, "Addres del jugador no valida");
        address[] memory players;
        usuarios[player] = user(players, true, partida(players,players,false,0,0,0));
        emit newPlayer(player, "Jugador anadido con exito");
    }

    /*
    @dev: Modifica la ultima partida de un addres
    @notice: Actualiza la ultima partida de un jugador
    */
    function updateLastMatch(
        address player, 
        address[] memory players, 
        address[] memory winners, 
        bool win, 
        uint kills, 
        uint deaths, 
        uint assist
    ) 
        public isStaff
    {
        if (players.length > 0) {
            usuarios[player].ultima = partida(players,winners,win,kills,deaths,assist);
        } else {
            revert("Partida sin jugadores");
        }
        
    }

}