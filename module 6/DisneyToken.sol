// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./ERC20.sol";
import "./Ownable.sol";

error DisneyToken__AddressIsIncorrect();
error DisneyToken__ZeroAmount();
error DisneyToken__NotEnoughTokensToPay();

// Контракт токена для расплачивания внутри дисней парка за аттракционы и за еду
// Данный токен имплементирует ERC20, чтобы им можно было управлять как обычным токеном, обмениваться им, пересылать, продавать и т.д.
// А так же имплементируется контракт Ownable, чтобы у данного контракта был владелец.
contract DisneyToken is ERC20, Ownable {
    constructor (address _owner, address _tokenTo, uint256 _initialSupply)
        ERC20("DisneyCoin", "DC")
    {
        _transferOwnership(_owner);
        _mint(_tokenTo, _initialSupply);
    }

    function decimals() public pure override returns0(uint8) {
        return 2;
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool) {
        if (_to == address(0)) {
            revert DisneyToken__AddressIsIncorrect();
        }
        if (_amount == 0) {
            revert DisneyToken__ZeroAmount();
        }
        _mint(_to, _amount);
        return true;
    }

    function burn(address _from, uint256 _amount) external onlyOwner returns(bool) {
        if (_from == address(0)) {
            revert DisneyToken__AddressIsIncorrect();
        }
        if (_amount == 0) {
            revert DisneyToken__ZeroAmount();
        }
        _burn(_from, _amount);
        return true;
    }

    function transferToDisney(address _owner, address _spender, uint256 _amount) external {
        if (_amount > balanceOf(_owner)) {
            revert DisneyToken__NotEnoughTokensToPay();
        }
        _approve(_owner, _spender, _amount);
        transferFrom(_owner, _spender, _amount);
    }
}
