// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MultisigWallet, WalletLib} from "../src/OnchainWallet/OnchainWallet.sol";

contract OnchainWalletTest is Test {
    MultisigWallet public wallet;
    WalletLib public walletLib;
    address public user1 = address(1);
    address public user2 = address(2);
    address public user3 = address(3);
    address public recipientUser = address(4);

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = user1;
        owners[1] = user2;
        owners[2] = user3;

        walletLib = new WalletLib();
        wallet = new MultisigWallet(address(walletLib), owners, 2);

        vm.deal(address(wallet), 10 ether);
    }

    function test_sanityCheck() public view {
        MultisigWallet.WalletStorageView memory s = wallet.getStorageData();
        assertEq(s._numOwners, 3);
        assertEq(s._minSignatures, 2);
        assertTrue(s._initialized);
        assertEq(s._owners[0], user1);
        assertEq(s._owners[1], user2);
        assertEq(s._owners[2], user3);
        assertEq(s._nextProposalId, 1);
    }

    function test_walletWorks() public {
        vm.prank(user1);
        wallet.proposeTransfer(recipientUser, 1 ether);

        // check proposal
        WalletLib.TransferProposal memory proposal = wallet.getProposal(1);
        assertEq(proposal._recipient, recipientUser);
        assertEq(proposal._amount, 1 ether);
        assertFalse(proposal._executed);

        // trying to execute proposal without consensus should fail
        vm.prank(user2);
        vm.expectRevert("Execute transfer failed");
        wallet.executeTransfer(1);

        // user2 agrees
        vm.prank(user2);
        wallet.agreeToTransfer(1);

        // consensus reached, transfer should work
        vm.prank(user2);
        wallet.executeTransfer(1);

        uint256 recpipientBalanceAfter = recipientUser.balance;
        assertEq(recpipientBalanceAfter, 1 ether);

        // trying to re-execute the same proposal should fail
        vm.prank(user2);
        vm.expectRevert("Execute transfer failed");
        wallet.executeTransfer(1);
    }

    function test_exploit() public {
        // TODO
    }
}
