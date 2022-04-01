// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./withdrawContract.sol";

contract Staker {

  withdrawContract public _withdrawContract;

  constructor(address contractAddress)  {
    _withdrawContract = withdrawContract(contractAddress);
  }

  mapping (address => uint) public balances;
  uint256 public _totalStaked;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;


  event Stake(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  function stake() payable public {
    require(msg.value > 0, "Insufficent balance");

    balances[msg.sender] += msg.value;

    _totalStaked += msg.value;

    emit Stake(msg.sender, msg.value);
  }
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  modifier deadlineReached {
    require(block.timestamp >= deadline, "Deadline not reached");
    _;
  }

  modifier notCompleted {
    require(_withdrawContract.completed() == false, "Raise has ended.");
    _;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public deadlineReached notCompleted {
    if (address(this).balance >= threshold) {
      _withdrawContract.complete{value: address(this).balance}();
      _totalStaked = 0;
    } else {
      openForWithdraw = true;
    }
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() external notCompleted {
    require(openForWithdraw, "Unable to withdraw funds.");
    require(balances[msg.sender] > 0, "You did not stake.");
    uint256 _deposit = balances[msg.sender];

    // tokenContract.transfer(msg.sender, _deposit);
    balances[msg.sender] -= _deposit;
    _totalStaked -= _deposit;
    payable(msg.sender).transfer(_deposit);

    emit Withdraw(msg.sender, _deposit);
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256 timeleft) {
    if (block.timestamp >= deadline) return 0;
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() payable external {
    require(msg.value > 0, "Insufficent balance");
    stake();
  }


}
