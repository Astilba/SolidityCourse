// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Lottery {
    mapping(address => mapping(uint256 => uint256[])) public s_playerTickets;
}
