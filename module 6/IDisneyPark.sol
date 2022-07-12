// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./DisneyToken.sol";

contract IDisneyPark {

    enum PassType {
       THREE_HOURS,
       SIX_HOURS,
       NINE_HOURS,
       TWELVE_HOURS,
       DAY
   }

   struct PassSettings {
       uint256 passDuration;
       uint256 passPrice;
   }

    struct Client {
        uint256 tokensBuyed;
        string[] attractionsVisited;
        uint256 attractionsPassEndTime;
    }

    struct Attraction {
        string name;
        uint256 price;
        bool status;
    }

    struct Food {
        string name;
        uint256 price;
        bool status;
    }

    event ClientVisitedAttraction(string indexed name, uint256 price, address indexed walletClient);
    event ClientBuyedFood(string indexed name, uint256 price, address indexed walletClient);
    event AttractionAdded(string indexed name, uint256 price, bool status);
    event AttractionStatusUpdated(string indexed name, bool newStatus);
    event FoodAdded(string indexed name, uint256 price, bool status);
    event FoodStatusUpdated(string indexed name, bool newStatus);
    event PassBuyed(address indexed client, PassType passType);

    // --------------------------------- УПРАВЛЕНИЕ ТОКЕНАМИ ---------------------------------

    // Функция покупки токенов Disney, для использования на атракционах или в ресторане парка
    // numTokens_: количество токенов, которые клиент хочет купить
    function buyTokens(uint256 numTokens_) external payable;

    // Баланс токенов контракта Disney
    function balanceOf() external view returns (uint256);

    // Отображение количества оставшихся токенов клиента
    function myTokens() external view returns (uint256);

    // Функция для генерации большего количества токенов
    // numTokens_: сколько нужно сгенерировать новых токенов (Управление только для владельца контракта Disney)
    function generateNewTokens(uint256 _numTokens) external;

    // --------------------------------- УПРАВЛЕНИЕ ПАРКОМ ---------------------------------

    // Функции только для владельца контракта парка Disney
    // Создавание нового аттракциона в парке (Управление только для владельца контракта Disney)
    // attractionName_: название атракциона в парке
    // price_: цена на билета атракцион
    function addAttraction(string memory attractionName_, uint256 price_) external;

    // Создавание нового элемента меню в ресторане парка (Управление только для владельца контракта Disney)
    // foodName_: название элемента питания в ресторане парка
    // price_: цена элемента питания
    function addNewFood(string memory foodName_, uint256 price_) external;

    // Изменить статус доступа к атракциону (Управление только для владельца контракта Disney)
    // attractionName_: название атракциона, к которому должен быть прекращён доступ
    // status_: новый статус аттракциона
    function setAttractionStatus(string memory attractionName_, bool status_) external;

    // Изменить статус доступа к определённому элементу меню в ресторане парка (Управление только для владельца контракта Disney)
    // foodName_: название элемента питания в ресторане парка, который нельзя будет продолжать покупать
    // status_: новый статус еды
    function setFoodStatus(string memory foodName_, bool _status) external;

    // Функции для клиентов парка Disney
    // Посмотреть список всех атракционов в парке Disney
    function showAttractions() external view returns (string[] memory);

    // Посмотреть весь список элементов еды (продуктов) в ресторане парка Disney
    function showFoods() external view returns (string[] memory);

    // Функция, чтобы попасть на аттракцион парка Disney и заплатить токенами
    // attractionName_: название атракциона, на котором хочет прокатиться клиент
    function getOnAttraction(string memory attractionName_) external;

    // Функция покупки еды за токены
    // foodName_: название элемента питания, который хотел бы купить клиент
    function buyFood(string memory foodName_) external;

    // Просмотр полной истории аттракционов, которые посетил клиент (клиент может узнать только свою историю посещения атракционов)
    function showHistoryAttractions() external view returns (string[] memory);

    // Просмотр полной истории элементов еды в меню, которые покупал клиент (клиент может узнать только свою историю покупок продуктов)
    function showHistoryFoods() external view returns (string[] memory);

    // Функция, позволяющая клиенту Disney возвращать токены парку в обмен на нативную валюту блокчейна
    // numTokens_: количество возвращаемых токенов в обмен на нативную монету сети
    function returnTokens(uint256 numTokens_) external payable;

    // Функция, позволяющая клиенту Disney покупать абонемент
    // passType_: тип абонемента
    function buyPass(PassType passType_) external;

}
