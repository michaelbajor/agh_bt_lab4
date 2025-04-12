// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dex {
    address public token1;
    address public token2;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyValidTokens(address one, address two) {
        require(one == token1 || two == token1);
        require(one == token2 || two == token2);
        require(one != two);
        _;
    }

    function setTokens(address _token1, address _token2) external onlyOwner {
        require(_token1 != _token2, "Oopsie");
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(address tokenAddr, uint amount) external onlyOwner {
        IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount);
    }

    // given the amount of from tokens, calculate the number of to tokens that we can buy
    function calculateSwapPrice(
        address from,
        address to,
        uint amount
    ) public view returns (uint) {
        uint256 toBalance = IERC20(to).balanceOf(address(this));
        uint256 fromBalance = IERC20(from).balanceOf(address(this));
        return (amount * toBalance) / fromBalance;
    }

    // swaps *amount* number of *from* tokens into *to* token
    function swap(
        address from,
        address to,
        uint amount
    ) external onlyValidTokens(from, to) {
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough balance to swap"
        );

        uint256 swapAmount = calculateSwapPrice(from, to, amount);

        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).transfer(msg.sender, swapAmount);
    }
}

contract ERC20Token is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, totalSupply);
    }
}
