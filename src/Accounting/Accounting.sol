// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Accounting is ReentrancyGuard {
    using Address for address payable;
    using Address for address;

    mapping(address => uint256) private balances;
    uint256 public totalDeposit;

    modifier accountInvariant() {
        assert(address(this).balance == totalDeposit);
        _;
        assert(address(this).balance == totalDeposit);
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    function transfer(address _to, uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Not enough balance");
        internalTransfer(msg.sender, _to, _amount);
    }

    function deposit() external payable {
        require(msg.value != 0, "Zero deposit");

        balances[msg.sender] += msg.value;
        totalDeposit += msg.value;
    }

    function withdrawTo(
        uint256 amount,
        address to
    ) external nonReentrant accountInvariant {
        address transferSource = msg.sender;
        require(balances[transferSource] >= amount, "Not enough deposit");
        payable(to).sendValue(amount);

        totalDeposit -= amount;
        balances[transferSource] -= amount;
    }

    function internalTransfer(
        address src,
        address dst,
        uint256 amount
    ) internal {
        balances[src] -= amount;
        balances[dst] += amount;
    }

    receive() external payable {
        revert("Do not send ETH directly");
    }
}
