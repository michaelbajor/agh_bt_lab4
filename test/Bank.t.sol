// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank/Bank.sol";
import {WETH} from "../src/Bank/WETH.sol";

contract BankTest is Test {
    Bank public bank;
    WETH public weth;

    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.deal(owner, 1000 ether);

        vm.startPrank(owner);

        bank = new Bank();
        weth = bank.weth();
        bank.deposit{value: 1000 ether}();

        vm.stopPrank();

        // sanity checks
        assertEq(address(bank).balance, 0);
        assertEq(weth.balanceOf(owner), 1000 ether);
    }

    function test_works() public {
        vm.deal(user, 10 ether);

        vm.prank(user);
        bank.deposit{value: 10 ether}();

        assertEq(weth.balanceOf(user), 10 ether);

        vm.prank(user);
        weth.transfer(owner, 1 ether);

        assertEq(weth.balanceOf(user), 9 ether);

        // withdrawing
        vm.prank(user);
        bank.withdrawAll();

        assertEq(weth.balanceOf(user), 0);
        assertEq(user.balance, 9 ether);
    }

    function test_exploit() public {
        // TODO: steal all ETH from Bank
        // This one is a little harder than the rest
    }
}
