// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Lottery {

    address s_owner;
    uint256 public s_currentRound;
    uint256 public s_ticketSupply;

    mapping(address => mapping(uint256 => uint256[])) private s_playerTickets;
    mapping(uint256 => address) public s_ticketsOwner;

    event BuyTickets(address user, uint256 initialTicketSupply, uint256 ticketsAmount);
    event UpdateOwner(address newOwner);

    constructor() {
        s_owner = msg.sender;
    }

    function updateOwner(address _newOwner) external {
        require(msg.sender == s_owner);
        s_owner = _newOwner;
        emit UpdateOwner(_newOwner);
    }

    function buyTickets(uint256 _ticketsAmount) external {
        for(uint256 i = 1; i <= _ticketsAmount; i++) {
            s_ticketsOwner[s_ticketSupply + i] = msg.sender;
            s_playerTickets[msg.sender][s_currentRound].push(s_ticketSupply + i);
        }
        emit BuyTickets(msg.sender, s_ticketSupply, _ticketsAmount);
        s_ticketSupply += _ticketsAmount;
    }

    function getTicketsCount() external view returns(uint256) {
        return s_playerTickets[msg.sender][s_currentRound].length;
    }

    function getTickets() external view returns(uint256[]) {
        return s_playerTickets[msg.sender][s_currentRound];
    }
}
