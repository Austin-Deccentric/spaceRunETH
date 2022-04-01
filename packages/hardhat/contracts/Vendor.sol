pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./atadiaToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  atadiaToken public _atadiaToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    _atadiaToken = atadiaToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require( msg.value > 0, "Your ETH balance is low." );
    uint256 tokenBuyAmount = msg.value * tokensPerEth;
    
    (bool sent) = _atadiaToken.transfer(msg.sender, tokenBuyAmount); 
    require(sent, "Failed to complete sale");

    emit BuyTokens(msg.sender, msg.value, tokenBuyAmount);
    
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No FUNDS to transfer");

    // transfer to owner
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send Sale proceeds to owner");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenSellAmount) public {
    require(_atadiaToken.balanceOf(msg.sender) >= tokenSellAmount, "You don not have enough Tokens.");
    uint256 ethToSend = tokenSellAmount / tokensPerEth;
    require(address(this).balance >= ethToSend, "ETH Reserves is low");
    
    _atadiaToken.transferFrom(msg.sender, address(this), tokenSellAmount);
    
    // transfer to user
    (bool sent,) = msg.sender.call{value: ethToSend}("");
    require(sent, "Failed to send ETH");

    emit SellTokens(msg.sender, ethToSend, tokenSellAmount);
  }

}
