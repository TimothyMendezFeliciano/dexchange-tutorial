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
            uint ethReserve = ethBalance - msg.value;
            uint tokenPairAAmount = (msg.value * tokenPairAReserve)/(ethReserve);
            require(_amount >= tokenPairAAmount, "Amount of tokens sent is less than the minimum tokens required");
            tokenPairAToken.transferFrom(msg.sender, address(this), tokenPairAAmount);
            liquidity = (totalSupply() * msg.value/ethReserve);
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns (uint, uint) {
        require(_amount > 0, "_amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint ethAmount = (ethReserve * _amount)/_totalSupply;
        uint tokenPairAAmount = (getReserve() * _amount)/_totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(tokenPairAAddress).transfer(msg.sender, tokenPairAAmount);
        return (ethAmount, tokenPairAAmount);
    }

    // Based on the equation y*x = k
    // (x+deltaX)*(y+deltaY)=(y*x)
    function getAmountOfTokens(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserves");

        uint256 inputAmountWithFee = inputAmount*99; // deltaX

        uint256 numerator = inputAmountWithFee * outputReserve; // y * deltaX
        uint256 denominator = (inputReserve *100) + inputAmountWithFee; // x + deltaX
        return numerator / denominator; // deltaY
    }

    function ethToPairToken(uint _minimumTokens) public payable {
        uint256 tokenReserve = getReserve();

        uint tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenReserve);
        require(tokensBought >= _minimumTokens, "Insufficient Input Amount");
        ERC20(tokenPairAAddress).transfer(msg.sender, tokensBought);
    }

    function pairTokenToEth(uint _tokensSold, uint _minimumEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmountOfTokens(_tokensSold, tokenReserve, address(this).balance);

        require(ethBought >= _minimumEth, "Insufficient Output Amount");

        ERC20(tokenPairAAddress).transferFrom(msg.sender, address(this), _tokensSold);

        payable(msg.sender).transfer(ethBought);
    }
}
