// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./DisneyToken.sol";
import "./IDisneyPark.sol";

error AmusementPark__NewOwnerAddressIsIncorrect();
error AmusementPark__TheAttractionAlreadyExists();
error AmusementPark__TheAttractionDoesNotExist();
error AmusementPark__TheFoodAlreadyExists();
error AmusementPark__TheFoodDoesNotExist();
error AmusementPark__TheAttractionIsNotAvailable();
error AmusementPark__TheFoodIsNotAvailable();
error AmusementPark__NotEnoughEther();
error AmusementPark__NotEnoughTokensOnTheParkBalance();
error AmusementPark__NotEnoughTokensOnTheClientBalance();
error AmusementPark__AttractionStatusIsAlreadySetted();
error AmusementPark__FoodStatusIsAlreadySetted();
error AmusementPark__NumTokensIsIncorrect();

contract AmusementPark is IDisneyPark, Ownable {

    DisneyToken immutable i_token;
    string[] private s_attractionNames;
    string[] private s_foodNames;
    mapping(string => Attraction) private s_attractions;
    mapping(string => Food) private s_food;
    mapping(address => Client) public clients;
    mapping(address => string[]) private s_historyAttractions;
    mapping(address => string[]) private s_historyFood;
    mapping(PassType => PassSettings) public s_passSettings;

    constructor() {
        i_token = new DisneyToken(_msgSender(), address(this), 10000 * 10**2);
    }

    function tokenPrice(uint256 _numTokens) internal view returns(uint256) {
        // Конвертация токенов в эфиры: 1 токен -> 0.1 эфира
        return (_numTokens / (10**token.decimals())) * (0.01 ether);
    }

    function buyTokens(uint256 _numTokens) external payable {
        uint256 price = tokenPrice(_numTokens);
        if (msg.value < price) {
            revert AmusementPark__NotEnoughEther();
        }
        uint256 balance = balanceOf();
        if (balance < _numTokens) {
            revert AmusementPark__NotEnoughTokensOnTheParkBalance();
        }
        i_token.transfer(_msgSender(), _numTokens);
        uint256 change = msg.value - price;
        payable(_msgSender()).transfer(change);
        clients[_msgSender()].tokensBuyed += _numTokens;
    }

    function balanceOf() external view returns(uint256) {
        return i_token.balanceOf(address(this));
    }

    function myTokens() external view returns(uint256) {
        return i_token.balanceOf(_msgSender());
    }

    function generateNewTokens(uint256 _numTokens) external onlyOwner {
        i_token.mint(address(this), _numTokens);
    }

    function addAttraction(string memory _name, uint256 _price, bool _status) external onlyOwner {
        if (s_attractions[_name] != address(0)) {
            revert AmusementPark__TheAttractionAlreadyExists();
        }
        s_attractions[_name] = Attraction(_name, _price, _status);
        s_attractionNames.push(_name);
        emit AttractionAdded(_name, _price, _status);
    }

    function addFood(string memory _name, uint256 _price, bool _status) external onlyOwner {
        if (s_food[_name] != address(0)) {
            revert AmusementPark__TheFoodAlreadyExists();
        }
        s_food[_name] = Food(_name, _price, _status);
        s_foodNames.push(_name);
        emit FoodAdded(_name, _price, _status);
    }

    function setAttractionStatus(string memory _name, bool _status) external onlyOwner {
        if (s_attractions[_name].name == "") {
            revert AmusementPark__TheAttractionDoesNotExist();
        }
        if (s_attractions[_name].status == _status) {
            revert AmusementPark__AttractionStatusIsAlreadySetted();
        }
        s_attractions[_name].status = _status;
        emit AttractionStatusUpdated(_name, _status);
    }

    function setFoodStatus(string memory _name, bool _status) external onlyOwner {
        if (s_food[_name] == "") {
            revert AmusementPark__TheFoodDoesNotExist();
        }
        if (s_food[_name].status == _status) {
            revert AmusementPark__FoodStatusIsAlreadySetted();
        }
        s_food[_name].status = _status;
        emit FoodStatusUpdated(_name, _status);
    }

    function showAttractions() external view returns(string[] memory) {
        return s_attractionNames;
    }

    function showFoods() external view returns(string[] memory) {
        return s_foodNames;
    }

    function getOnAttraction(string memory _attractionName) external {
         if (s_attractions[_attractionName].status == false) {
             revert AmusementPark__TheAttractionIsNotAvailable();
         }
         if (clients[_msgSender()].attractionsPassEndTime < block.timestamp) {
             uint256 price = s_attractions[_attractionName].price;
             if (price > myTokens()) {
                 revert AmusementPark__NotEnoughTokensOnTheClientBalance();
             }
             i_token.transferToDisney(_msgSender(), address(this), price);
         }
         s_historyAttractions[_msgSender()].push(_attractionName);
         clients[_msgSender()].attractionsVisited.push(_attractionName);
         emit ClientVisitedAttraction(_attractionName, price, _msgSender());
     }

    function buyFood(string memory _foodName) external {
        if (s_food[_foodName].status == false) {
             revert AmusementPark__TheFoodIsNotAvailable();
         }
         uint256 price = s_food[_foodName].price;
         if (price > myTokens()) {
             revert AmusementPark__NotEnoughTokensOnTheClientBalance();
         }
         i_token.transferToDisney(_msgSender(), address(this), price);
         s_historyFood[_msgSender()].push(_foodName);
         emit ClientBuyedFood(_foodName, price, _msgSender());
    }

    function showHistoryAttractions() external view returns(string[] memory) {
        return s_historyAttractions[_msgSender()];
    }

    function showHistoryFoods() external view returns(string[] memory) {
        return s_historyFood[_msgSender()];
    }

    function returnTokens(uint256 _numTokens) external payable {
        if (_numTokens == 0) {
            revert AmusementPark__NumTokensIsIncorrect();
        }
        if (_numTokens < myTokens()) {
            revert AmusementPark__NotEnoughTokensOnTheClientBalance();
        }
        i_token.transferToDisney(_msgSender(), address(this), _numTokens);
        payable(_msgSender()).transfer(tokenPrice(_numTokens));
    }

    function buyPass(PassType _passType) external {
        uint256 price = s_passSettings[_passType].passPrice;
        if (price > myTokens()) {
            revert AmusementPark__NotEnoughTokensOnTheClientBalance();
        }
        i_token.transferToDisney(_msgSender(), address(this), price);
        uint256 currentPassEndTime = clients[_msgSender()].attractionsPassEndTime;
        if (block.timestamp > currentPassEndTime) {
            clients[_msgSender()].attractionsPassEndTime = block.timestamp + s_passSettings[_passType].passDuration;
        } else {
            clients[_msgSender()].attractionsPassEndTime += s_passSettings[_passType].passDuration;
        }
        emit PassBuyed(_msgSender(), _passType);
    }
}
