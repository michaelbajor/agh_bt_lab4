// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Accounting} from "../src/Accounting/Accounting.sol";

contract AccountingTest is Test {
    Accounting accounting;

    address user = address(1);
    address user2 = address(2);

    function setUp() public {
        accounting = new Accounting();

        vm.deal(user, 10 ether);
        vm.prank(user);
        accounting.deposit{value: 10 ether}();
    }

    function test_works() public {
        assertEq(accounting.balanceOf(user), 10 ether);
        assertEq(accounting.totalDeposit(), 10 ether);

        vm.prank(user);
        accounting.withdrawTo(3 ether, user2);

        assertEq(accounting.balanceOf(user), 7 ether);
        assertEq(accounting.totalDeposit(), 7 ether);
        assertEq(accounting.balanceOf(user2), 0 ether);
        assertEq(user2.balance, 3 ether);

        vm.prank(user);
        accounting.transfer(user2, 1 ether);

        assertEq(accounting.balanceOf(user), 6 ether);
        assertEq(accounting.totalDeposit(), 7 ether);
        assertEq(accounting.balanceOf(user2), 1 ether);
        assertEq(user2.balance, 3 ether);
    }

    function test_exploit() public {
        // TODO: Lock the funds in Accounting contract
    }
}
