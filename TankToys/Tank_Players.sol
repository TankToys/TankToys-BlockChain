// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Administrador de jugadores
 * @notice Administra los jugadores
 * @dev Administra el mapping de los jugadores
 * @author David Castellanos, Eduardo Rojas
 */
contract TankToys_Players {

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
     * @dev Modifier que comprueba si ya tiene esa address como amigo
     */
    modifier includeFriend(address player, address newfriend) {
        bool flag = false;
        for (uint i = 0; i < usuarios[player].friends.length && !flag; i++) {
            if (newfriend == usuarios[player].friends[i]) {
                flag = true;
            }
        }
        require(!flag, "Friend already added");
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
     * @dev Estructura de un usuario
     */
    struct user {
        address[] friends;
        bool created;
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
        uint deaths;
        uint assist;
    }

    /**
     * @dev Eventos que se llaman a la hora de añadir un amigo o un jugador
     */
    event friendPushed(address player, address friend, string message);
    event newPlayer(address player, string message);

    /**
     * @dev Mapping donde se guardan los usuarios
     */
    mapping (address => user) usuarios;

    /**
     * @dev Retorna el struct de la ultima partida del jugador
     * @notice Devuelve la ultima partida
     * @param player La dirección del jugador
     * @return p Struct partida
     */
    function getLastMathch(address player) public view returns (partida memory p) {
        return usuarios[player].ultima;
    }

    /**
     * @dev Retorna array con las address de los amigos
     * @notice Devuelve las direcciones de los amigos
     * @param player La dirección del jugador
     * @return friends Array de address
     */
    function getFriends(address player) public view returns (address[] memory friends) {
        return usuarios[player].friends;
    }

    /**
     * @dev Pushea una address al array del mapping de usuarios
     * @notice Añade un amigo a una address
     * @param player La dirección del jugador
     * @param newfriend La dirección del nuevo amigo
     */
    function addFriend(address player, address newfriend) public isStaff includeFriend(player, newfriend) {
        require(usuarios[player].created, "Cannot add friends if not a user");
        require(usuarios[newfriend].created, "Friend must be a user");
        require(newfriend != player, "Cannot add yourself as a friend");
        require(abi.encodePacked(newfriend).length == 20, "Invalid friend address");

        usuarios[player].friends.push(newfriend);
        emit friendPushed(player, newfriend, "Friend added successfully");
    }

    /**
     * @dev Añade una nueva address al mapping
     * @notice Añade un jugador
     * @param player La dirección del nuevo jugador
     */
    function addPlayer(address player) public isStaff {
        require(abi.encodePacked(player).length > 0, "Invalid player address");
        address[] memory players;
        usuarios[player] = user(players, true, partida(players, players, false, 0, 0, 0));
        emit newPlayer(player, "Player added successfully");
    }

    /**
     * @dev Modifica la ultima partida de un address
     * @notice Actualiza la ultima partida de un jugador
     * @param player La dirección del jugador
     * @param players Array de jugadores en la partida
     * @param winners Array de ganadores de la partida
     * @param win Indica si la partida fue ganada
     * @param kills Número de kills en la partida
     * @param deaths Número de muertes en la partida
     * @param assist Número de asistencias en la partida
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
        require(players.length > 0, "Partida sin jugadores");
        usuarios[player].ultima = partida(players, winners, win, kills, deaths, assist);
    }

}
