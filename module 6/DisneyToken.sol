// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./IERC20.sol";

// Контракт токена для расплачивания внутри дисней парка за аттракционы и за еду
// Данный токен имплементирует ERC20, чтобы им можно было управлять как обычным токеном, обмениваться им, пересылать, продавать и т.д.
// А так же имплементируется контракт Ownable, чтобы у данного контракта был владелец.
contract DisneyToken is IERC20 {
    string public constant NAME = "ERC20Disney";
    string public constant SYMBOL = "DSN";
    uint8 public constant DECIMALS = 18;

    mapping (address => uint256) s_balances;
    mapping (address => mapping (address => uint256)) s_allowed;

    uint256 s_totalSupply_;

    constructor (uint256 _initialSupply) {
        s_totalSupply_ = _initialSupply;
        s_balances[msg.sender] = s_totalSupply_;
    }

    function totalSupply() public override view returns(uint256) {
        return s_totalSupply_;
    }

    function increaseTotalSupply(uint256 _newTokensAmount) public {
        s_totalSupply_ += _newTokensAmount;
        s_balances[msg.sender] += _newTokensAmount;
    }

    function balanceOf(address _tokenOwner) public override view returns(uint256) {
        return s_balances[_tokenOwner];
    }

    function allowance(address _owner, address _delegate) public override view returns(uint256) {
        return s_allowed[_owner][_delegate];
    }

    function transfer(address _recipient, uint256 _numTokens) public override returns(bool) {
        require(_numTokens <= s_balances[msg.sender]);
        s_balances[msg.sender] = s_balances[msg.sender] - _numTokens;
        s_balances[_recipient] = s_balances[_recipient] + _numTokens;
        emit Transfer(msg.sender, _recipient, _numTokens);
        return true;
    }

    function approve(address _delegate, uint256 _numTokens) public override returns(bool) {
        s_allowed[msg.sender][_delegate] = _numTokens;
        emit Approval(msg.sender, _delegate, _numTokens);
        return true;
    }

    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns(bool) {
        require(_numTokens <= s_balances[_owner]);
        require(_numTokens <= s_allowed[_owner][msg.sender]);

        s_balances[_owner] = s_balances[_owner] - _numTokens;
        s_allowed[_owner][msg.sender] = s_allowed[_owner][msg.sender] - _numTokens;
        s_balances[_buyer] = s_balances[_buyer] + _numTokens;

        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }


}
