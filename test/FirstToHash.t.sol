// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FirstToHash, ERC20Token} from "../src/FirstToHash/FirstToHash.sol";

contract FirstToHashTest is Test {
    address owner = address(1);
    address user = address(2);
    ERC20Token token;
    FirstToHash firstToHashContract;

    function setUp() public {
        vm.startPrank(owner);

        token = new ERC20Token("Token", "TKN", 10000);
        firstToHashContract = new FirstToHash(address(token));

        vm.stopPrank();

        string memory firstName = "John";
        string memory lastName = "Smith";
        uint256 suffix = 0;

        vm.prank(user);
        firstToHashContract.claimIdentity(firstName, lastName, suffix);

        // sanity check
        bytes32 userIdentity = keccak256(
            abi.encodePacked(firstName, lastName, suffix)
        );

        // airdropping tokens to user
        vm.startPrank(owner);
        token.approve(address(firstToHashContract), 100);
        firstToHashContract.airdropTo(userIdentity, 100);
        vm.stopPrank();
    }

    function test_Airdrop() public {
        // user claims airdrop
        vm.prank(user);
        firstToHashContract.claimAirdrop();

        uint256 userBalanceAfterAirdrop = token.balanceOf(user);
        assertEq(userBalanceAfterAirdrop, 100);
    }

    function test_exploit() public {
        // TODO: steal the airdrop
    }
}
