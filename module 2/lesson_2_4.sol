// SPDX-License-Identifier: MIT


pragma solidity 0.8.14;

contract BonusPoints {

    struct Customer {
        uint256 totalEarnedPoints;
        uint256 totalSpentPoints;
    }

    address private _owner;

    event EarnPoints(address user, uint256 value);
    event MovePoints(address from, address to, uint256 value);
    event BurnPoints(address user, uint256 value);
    event UpdateOwner(address newOwner);

    constructor() {
        _owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return _owner;
    }

    function updateOwner(address _newOwner) public {
        require(msg.sender == _owner, "you are not the owner");
        _owner = _newOwner;
        emit UpdateOwner(_newOwner);
    }

    function getTotalEarnedPoints(address _user) private view returns(uint256) {
        require(_isUser[_user] == true, "there is no user with this address");
        return _totalEarnedPoints[_user];
    }

    function getTotalSpentPoints(address _user) private view returns(uint256) {
        require(_isUser[_user] == true, "there is no user with this address");
        return _totalSpentPoints[_user];
    }

    function getCurrentBalance(address _user) public view returns(uint256) {
        unchecked {
            return getTotalEarnedPoints(_user) - getTotalSpentPoints(_user);
        }
    }

    function updatePoints(address _user, int256 _value) external virtual {
        if (_value < 0) {
            require(_isUser[_user] == true, "there is no user with this address");
            uint256 currentBalance = getCurrentBalance(_user);
            require(currentBalance >= uint256(-_value), "user doesn't have enough points to spent");
            _totalSpentPoints[_user] += uint256(-_value);
            emit BurnPoints(_user, uint(-_value));
        } else {
            if (_isUser[_user] == false) {
                _isUser[_user] = true;
                _users.push(_user);
            }
            _totalEarnedPoints[_user] += uint256(_value);
            emit EarnPoints(_user, uint256(_value));
        }
    }

    function movePoints(address _to, uint256 _value) external {
        uint256 currentBalance = getCurrentBalance(msg.sender);
        require(currentBalance >= _value, "you don't have enough points to move");
        _totalSpentPoints[msg.sender] += _value;
        _totalEarnedPoints[_to] += _value;
        emit MovePoints(msg.sender, _to, _value);
    }

    function clearPoints() external {
        for (uint256 i = 0; i < _users.length; i++) {
            uint256 currentBalance = getCurrentBalance(_users[i]);
            if (currentBalance > 0) {
                _totalSpentPoints[_users[i]] += currentBalance;
            }
        }
    }
}