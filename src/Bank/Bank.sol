// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./WETH.sol";

// Deposit Ether to Bank to get WETH
contract Bank is ReentrancyGuard {
    using Address for address payable;
    using Address for address;

    WETH public immutable weth;
    address private _owner;

    constructor() {
        weth = new WETH();
        _owner = msg.sender;
    }

    function deposit() public payable nonReentrant {
        weth.deposit{value: msg.value}(msg.sender);
    }

    function withdraw(uint256 amount) public nonReentrant {
        weth.withdraw(msg.sender, amount);
    }

    function withdrawAll() public nonReentrant {
        weth.withdrawAll(msg.sender);
    }

    function flashLoan(
        address receiver,
        bytes calldata data,
        uint256 amount
    ) public nonReentrant {
        weth.flashLoan(receiver, amount, data);
    }

    receive() external payable {}
}
