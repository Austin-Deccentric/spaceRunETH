pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract atadiaToken is ERC20 {
    address public owner;

    constructor() ERC20("Atadia", "ATA") {
        //_mint( ~~~YOUR FRONTEND ADDRESS HERE~~~~ , 1000 * 10 ** 18);
        owner = msg.sender;
        _mint(msg.sender, 2000 * 10 ** 18);
    }
}
