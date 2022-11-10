// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenPairAAddress;

    constructor(address _inputToken) ERC20("TimoSwap LP Token", "TSLP") {
        require(_inputToken != address(0), "Token address passed is a null address");
        tokenPairAAddress = _inputToken;
    }

    function getReserve() public view returns (uint) {
        return ERC20(tokenPairAAddress).balanceOf(address(this));
    }

    function addLiquidity(uint _amount) public payable returns (uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint tokenPairAReserve = getReserve();
        ERC20 tokenPairAToken = ERC20(tokenPairAAddress);

        if(tokenPairAReserve == 0) {
            tokenPairAToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint ethReserve = ethBalance - msv.value;
            uint tokenPairAAmount = (msg.value * tokenPairAReserve)/(ethReserve);
            require(_amount >= tokenPairAAmount, "Amount of tokens sent is less than the minimum tokens required");
            tokenPairAToken.transferFrom(msg.sender, address(this), tokenPairAToken);
            liquidity = (totalSupply() * msg.value/ethReserve);
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns (uint, uint) {
        require(_amount, "_amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint ethAmount = (ethReserve * _amount)/_totalSupply;
        uint tokenPairAAmount = (getReserve() * _amount)/_totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(tokenPairAAddress).transfer(msg.sender, tokenPairAAmount);
        return (ethAmount, tokenPairAAmount);
    }


}
