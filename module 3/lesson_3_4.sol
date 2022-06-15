// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "github.com/Astilba/SolidityCourse/blob/main/module%202/lesson_2_6.sol";

error Lottery__PreviousLotteryIsNotOverYet();
error Lottery__roundTimeIsNoOverYet();
error Lottery__ThisRoundAlreadyEnded();
error Lottery__TicketsAmountMustBeGreaterThenZero();

contract Lottery {

    uint256 public constant LOTTERY_DURATION = 4 weeks;
    address public constant TOKEN_ADDRESS = 0xc8250Acd967aF4C783ab75d314632C0dea0E021f;

    struct LotteryRound {
        address winner;
        uint256 startTime;
        uint256 tokensInRound;
        uint256 ticketsInRound;
        uint256 ticketPrice;
        uint256 winningNumber;
    }

    MarishaToken immutable public i_token;
    address private s_owner;
    uint256 public s_currentRound;
    uint256 public s_price;
    uint256 public s_feeToOwner;
    LotteryRound[] private s_lotteryRounds;
    mapping(address => mapping(uint256 => uint256[])) private s_playerTickets;
    mapping(uint256 => address) public s_ticketsOwner;

    event StartRound(uint256 round, uint256 price);
    event RoundEnded(uint256 round, address winner, uint256 tokensInRound, uint256 winningNumber);
    event PriceSetted(uint256 newPrice);
    event FeeSetted(uint256 newFee);
    event TicketsBuyed(address user, uint256 ticketsAmount);
    event OwnerSetted(address newOwner);

    constructor(address _owner, uint256 _price, uint256 _feeToOwner) {
        s_owner = _owner;
        s_price = _price;
        s_feeToOwner = _feeToOwner;
        i_token = MarishaToken(TOKEN_ADDRESS);
    }

    modifier onlyOwner {
        require(msg.sender == s_owner, "You are not an owner!");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        s_owner = _newOwner;
        emit OwnerSetted(_newOwner);
    }

    function startRound() external onlyOwner {
        uint256 currentRound = ++s_currentRound;
        uint256 price = s_price;

        if(s_lotteryRounds[currentRound - 1].startTime + LOTTERY_DURATION > block.timestamp) {
            revert Lottery__PreviousLotteryIsNotOverYet();
        }

        s_lotteryRounds[currentRound] = LotteryRound(
            address(0),
            block.timestamp,
            0,
            0,
            price,
            0
        );

        emit StartRound(currentRound, price);
    }

    function endRound() external onlyOwner {
        uint256 round = s_currentRound;
        LotteryRound storage currentLottery = LotteryRounds[currentRound];

        if(currentLottery.startTime + LOTTERY_DURATION > block.timestamp) {
            revert Lottery__roundTimeIsNoOverYet();
        }

        uint256 randomTicketNumber = uint256(
            keccak256(
                abi.encode(
                    currentLottery.tokensInRound,
                    block.timestamp,
                    blockhash(block.number - round),
                    block.coinbase
                )
            )
        ) % currentLottery.ticketsInRound;

        address winner = s_ticketsOwner[randomTicketNumber];
        uint256 ownerFee = (currentLottery.tokensInRound / 100) * s_feeToOwner;

        i_token.transfer(winner, (currentLottery.tokensInRound - ownerFee));
        i_token.transfer(s_owner, ownerFee);

        currentLottery.winner = winner;
        currentLottery.winningNumber = randomTicketNumber;

        emit RoundEnded(round, winner, currentLottery.tokensInRound, randomTicketNumber);
    }

    function setTicketPrice(uint256 _newPrice) external onlyOwner {
        s_price = _newPrice;
        emit PriceSetted(_newPrice);
    }

    function setFee(uint256 _fee) external onlyOwner {
        s_feeToOwner = _fee;
        emit FeeSetted(_fee);
    }

    function buyTickets(uint256 _ticketsAmount) external {

        if (_ticketsAmount == 0) {
            revert Lottery__TicketsAmountMustBeGreaterThenZero();
        }

        uint256 currentRound = s_currentRound;

        LotteryRound storage currentLottery = LotteryRounds[currentRound];

        if (currentLottery.winner != address(0)) {
            revert Lottery__ThisRoundAlreadyEnded();
        }

        uint256 tokensSpent = _ticketsAmount * currentLottery.ticketPrice;
        i_token.transferFrom(msg.sender, address(this), tokensSpent);

        uint256 initialTicketsSupply = currentLottery.ticketsInRound;
        for(uint256 i = 1; i <= _ticketsAmount; i++) {
            s_ticketsOwner[initialTicketsSupply + i] = msg.sender;
            s_playerTickets[msg.sender][currentRound].push(initialTicketsSupply + i);
        }

        currentLottery.ticketsInRound += _ticketsAmount;
        currentLottery.tokensInRound += tokensSpent;

        emit TicketsBuyed(msg.sender, _ticketsAmount);
    }

    function getMyTicketsCount(uint256 _round) external view returns(uint256) {
        return s_playerTickets[msg.sender][_round].length;
    }

    function getMyTickets(uint256 _round) external view returns(uint256[]) {
        return s_playerTickets[msg.sender][_round];
    }

    function getPrizeFund(uint256 _round) external view returns(uint256) {
        return s_lotteryRounds[_round].tokensInRound;
    }

    function getTicketPrice(uint256 _round) external view returns(uint256) {
        return s_lotteryRounds[_round].ticketPrice;
    }

    function getWinningTicketNumber(uint256 _round) external view roundIsCompleted(_round) returns(uint256) {
        return s_lotteryRounds[_round].winningNumber;
    }
}
