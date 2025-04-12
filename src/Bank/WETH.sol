// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract WETH is Ownable {
    using Address for address;
    using Address for address payable;

    string public constant name = "wrapped ETH";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() Ownable(msg.sender) {}

    receive() external payable {
        revert("WETH: Do not send ETH directly");
    }

    function deposit(address _userAddress) public payable onlyOwner {
        _mint(_userAddress, msg.value);
    }

    function withdraw(address _userAddress, uint256 _amount) public onlyOwner {
        payable(_userAddress).sendValue(_amount);
        _burn(_userAddress, _amount);
    }

    function withdrawAll(address _userAddress) public onlyOwner {
        payable(_userAddress).sendValue(balanceOf[_userAddress]);
        _burnAll(_userAddress);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 amount) public returns (bool) {
        allowance[msg.sender][guy] = amount;
        return true;
    }

    function transfer(address dst, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, dst, amount);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) public returns (bool) {
        require(balanceOf[src] >= amount);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint256).max
        ) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }

        balanceOf[src] -= amount;
        balanceOf[dst] += amount;

        return true;
    }

    function flashLoan(
        address _userAddress,
        uint256 _amount,
        bytes calldata data
    ) public onlyOwner {
        require(
            _amount <= address(this).balance,
            "WETH: amount exceeds balance"
        );
        require(
            _userAddress.code.length > 0,
            "WETH: Borrower must be a contract"
        );

        uint256 userBalanceBefore = address(this).balance;

        Address.functionCallWithValue(_userAddress, data, _amount);

        uint256 userBalanceAfter = address(this).balance;

        require(
            userBalanceAfter >= userBalanceBefore,
            "PETH: You did not return my Ether!"
        );

        // if user gave me more Ether, refund it
        if (userBalanceAfter > userBalanceBefore) {
            uint256 refund = userBalanceAfter - userBalanceBefore;
            payable(_userAddress).sendValue(refund);
        }
    }

    function _mint(address dst, uint256 amount) internal {
        balanceOf[dst] += amount;
    }

    function _burn(address src, uint256 amount) internal {
        require(balanceOf[src] >= amount);
        balanceOf[src] -= amount;
    }

    function _burnAll(address _userAddress) internal {
        _burn(_userAddress, balanceOf[_userAddress]);
    }
}
