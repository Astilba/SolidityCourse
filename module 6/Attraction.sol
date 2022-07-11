// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./AmusementPark.sol";

error Attraction__TheStatusIsAlreadySet();

contract Attraction {

    AmusementPark immutable i_park;
    string s_name;
    uint256 s_price;
    bool s_status;

    event NameSetted(string indexed _name);
    event PriceSetted(uint256 _price);
    event StatusSetted(bool _status);

    constructor(string _name, uint256 _price, bool _status, address _park) {
        i_park = AmusementPark(_park);
        s_name = _name;
        s_price = _price;
        s_status = s_status;

        emit NameSetted(_name);
        emit PriceSetted(_price);
        emit StatusSetted(_status);
    }

    modifier onlyPark {
        require(msg.sender == address(i_park),
            "You do not have permission to run this function. Only the park allowed.");
        _;
    }

    function setStatus(bool _newStatus) external onlyPark {
        if (s_status == _newStatus) {
            revert Attraction__TheStatusIsAlreadySet();
        }
        s_status = _newStatus;
        emit StatusSetted(_newStatus);
    }
}
