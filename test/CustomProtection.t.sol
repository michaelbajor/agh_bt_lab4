// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CustomProtection} from "../src/CustomProtection/CustomProtection.sol";

contract CustomProtectionTest is Test {
    CustomProtection protection;
    address public owner = address(1);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        protection = new CustomProtection();
    }

    function test_protection() public {
        vm.prank(owner);
        (bool success, ) = address(protection).call{value: 10 ether}("");
        require(success, "deposit failed :(");

        assertEq(address(protection).balance, 10 ether);

        // owner can withdraw
        vm.prank(owner, owner); // msg.sender, tx.origin
        protection.withdrawAll();

        assertEq(address(protection).balance, 0);
        assertEq(owner.balance, 10 ether);
    }

    function test_exploit() public {
        // TODO: Can you bypass the protection?
    }
}
