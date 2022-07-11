// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./Attraction.sol";
import "./Food.sol";
import "./DisneyToken.sol";
import "./IDisneyPark.sol";

error AmusementPark__NewOwnerAddressIsIncorrect();
error AmusementPark__TheAttractionAlreadyExists();
error AmusementPark__TheAttractionDoesNotExist();
error AmusementPark__TheFoodAlreadyExists();
error AmusementPark__TheFoodDoesNotExist();

contract AmusementPark is IDisneyPark {
    DisneyToken immutable i_token;
    address public s_owner;
    string[] private s_attractionNames;
    mapping(string => address) private s_attractions;
    string[] private s_foodNames;
    mapping(string => address) private s_food;

    event OwnerSetted(address indexed _owner);
    event AttractionAdded(string indexed _name, address indexed _attraction);
    event FoodAdded(string indexed _name, address indexed _food);

    constructor(address _token) {
        i_token = DisneyToken(_token);
        s_owner = msg.sender;
        emit OwnerSetted(s_owner);
    }

    modifier onlyOwner {
        require(msg.sender == s_owner, "You do not have permission to run this function. Only owner allowed.");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) {
            revert AmusementPark__NewOwnerAddressIsIncorrect();
        }
        s_owner = _newOwner;
        emit OwnerSetted(_newOwner);
    }

    function addAttraction(string memory _name, uint256 _price, bool _status) external onlyOwner {
        if (s_attractions[_name] != address(0)) {
            revert AmusementPark__TheAttractionAlreadyExists();
        }
        address newAttraction = address(Attraction(_name, _price, _status, address(this)));
        s_attractionNames.push(_name);
        s_attractions[_name] = newAttraction;
        emit AttractionAdded(_name, newAttraction);
    }

    function addFood(string memory _name, uint256 _price, bool _status) external onlyOwner {
        if (s_food[_name] != address(0)) {
            revert AmusementPark__TheFoodAlreadyExists();
        }
        address newFood = address(Food(_name, _price, _status, address(this)));
        s_foodNames.push(_name);
        s_food[_name] = newFood;
        emit FoodAdded(_name, newFood);
    }

    function setAttractionStatus(string memory _name, bool _status) external onlyOwner {
        if (s_attractions[_name] == address(0)) {
            revert AmusementPark__TheAttractionDoesNotExist();
        }
        Attraction tmp = Attraction(s_attractions[_name]);
        tmp.setStatus(_status);
    }

    function setFoodStatus(string memory _name, bool _status) external onlyOwner {
        if (s_food[_name] == address(0)) {
            revert AmusementPark__TheFoodDoesNotExist();
        }
        Food tmp = Food(s_food[_name]);
        tmp.setStatus(_status);
    }

    function getAttractionsList() external view returns(string[] memory) {
        return s_attractionNames;
    }

    function getFoodList() external view returns(string[] memory) {
        return s_foodNames;
    }
}
