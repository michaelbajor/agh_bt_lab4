// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CustomProtection {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(tx.origin == owner, "Not owner");
        _;
    }

    function withdrawAll() external onlyOwner {
        // tx.origin is bad if someone makes owner call a malicious contract
        // let's make sure no contract can call it
        if (msg.sender.code.length > 0) {
            revert("CONTRACT CALLING!");
        }

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(success, "transfer failed");
    }

    receive() external payable {}
}
