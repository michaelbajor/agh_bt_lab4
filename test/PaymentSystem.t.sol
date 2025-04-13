// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PaymentSystem} from "../src/PaymentSystem/PaymentSystem.sol";

contract PaymentSystemTest is Test {
    PaymentSystem public paymentSystem;
    address public user1 = address(1);
    address public user2 = address(2);

    function setUp() public {
        paymentSystem = new PaymentSystem();
    }

    function test_paymentWorks() public {
        // user1 creates payment
        string memory description = "Payment for invoice 1/1/2025";
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        paymentSystem.createPayment{value: 1 ether}(user2, description);

        // sanity check - Payment was created
        PaymentSystem.ClaimablePayment memory payment = paymentSystem
            .getPaymentFor(user2);
        assertTrue(payment.exists);
        assertEq(payment.amount, 1 ether);
        assertEq(payment.description, description);

        // it should be impossible to create second payment for user2
        string memory description2 = "Doesn't matter";
        vm.prank(user1);
        vm.expectRevert("Unclaimed payment exists");
        paymentSystem.createPayment{value: 2 ether}(user2, description2);

        // user2 claims payment
        uint256 user2BalanceBefore = user2.balance;
        console.logUint(user2BalanceBefore); // if you want to see it in console.log, run with -vv

        vm.prank(user2);
        paymentSystem.claimPayment();

        uint256 user2BalanceAfter = user2.balance;
        console.logUint(user2BalanceAfter);
        assertEq(user2BalanceBefore + 1 ether, user2BalanceAfter);

        // user2 shouldn't be able to claim again
        vm.prank(user2);
        vm.expectRevert("No available payment");
        paymentSystem.claimPayment();
    }

    function test_rejectionWorks() public {
        string memory description = "Payment for invoice 1/1/2025";
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        paymentSystem.createPayment{value: 1 ether}(user2, description);

        PaymentSystem.ClaimablePayment memory payment = paymentSystem
            .getPaymentFor(user2);
        assertTrue(payment.exists);
        assertEq(payment.amount, 1 ether);
        assertEq(payment.description, description);

        assertEq(user1.balance, 9 ether);

        vm.prank(user2);
        paymentSystem.rejectPayment();

        PaymentSystem.ClaimablePayment memory paymentAfter = paymentSystem
            .getPaymentFor(user2);
        assertFalse(paymentAfter.exists);
        assertEq(paymentAfter.amount, 0);
        assertEq(paymentAfter.description, "");
        assertEq(user1.balance, 10 ether);

        vm.prank(user2);
        vm.expectRevert("No available payment");
        paymentSystem.claimPayment();
    }

    function test_exploit() public {
        // TODO: can you drain the Payment system?
    }
}
