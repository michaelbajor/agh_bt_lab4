// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex, ERC20Token} from "../src/Dex/Dex.sol";

contract DexTest is Test {
    Dex dex;
    ERC20Token token1;
    ERC20Token token2;
    address public owner = address(1);
    address public user = address(2);

    uint256 totalSupply = 100000; // decimals don't matter

    function setUp() public {
        vm.startPrank(owner);
        dex = new Dex();
        token1 = new ERC20Token("Token1", "TKN1", totalSupply);
        token2 = new ERC20Token("Token2", "TKN2", totalSupply);

        dex.setTokens(address(token1), address(token2));

        // transferring some tokens to user
        token1.transfer(user, 20);
        token2.transfer(user, 20);

        // adding liquidity to the "Dex"
        token1.approve(address(dex), 200);
        token2.approve(address(dex), 200);
        dex.addLiquidity(address(token1), 200);
        dex.addLiquidity(address(token2), 200);

        vm.stopPrank();
    }

    function test_dex() public {
        // Okay... so, there 200 tokens of each kind in the Dex
        // then it means that they are worth the same as of right now
        // so swapping 10 TKN1 should result in getting 10 TKN2
        vm.startPrank(user);

        // Approving the token transfer first
        token1.approve(address(dex), 10);

        uint256 tkn2BalanceBefore = token2.balanceOf(user);
        // swapping
        dex.swap(address(token1), address(token2), 10);

        uint256 tkn2BalanceAfter = token2.balanceOf(user);
        assertEq(tkn2BalanceAfter, tkn2BalanceBefore + 10);

        vm.stopPrank();
    }

    function test_exploit() public {
        // TODO - try to drain the Dex!
    }
}
