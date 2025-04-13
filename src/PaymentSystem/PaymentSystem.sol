// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PaymentSystem {
    event PaymentCreated(
        address indexed creator,
        address indexed receiver,
        uint256 amount
    );
    event PaymentClaimed(address indexed claimer, uint256 amount);

    struct ClaimablePayment {
        bool exists; // is that required? If so, why? :)
        address sender;
        uint amount;
        string description;
    }

    mapping(address => ClaimablePayment) public _payments;

    constructor() {}

    function getPaymentFor(
        address recipient
    ) external view returns (ClaimablePayment memory) {
        return _payments[recipient];
    }

    function createPayment(
        address recipient,
        string memory description
    ) external payable {
        require(!_payments[recipient].exists, "Unclaimed payment exists");
        require(msg.value > 0, "Zero payment");
        require(bytes(description).length <= 255, "Description too long");

        ClaimablePayment memory payment = ClaimablePayment(
            true,
            msg.sender,
            msg.value,
            description
        );
        _payments[recipient] = payment;

        emit PaymentCreated(msg.sender, recipient, msg.value);
    }

    function claimPayment() external {
        ClaimablePayment storage payment = _payments[msg.sender];
        require(payment.exists, "No available payment");

        (bool success, ) = payable(msg.sender).call{value: payment.amount}("");
        require(success, "Transfer failed");

        payment.exists = false;
        emit PaymentClaimed(msg.sender, payment.amount);
    }

    function rejectPayment() external {
        ClaimablePayment storage payment = _payments[msg.sender];
        require(payment.exists, "No available payment");

        // send the money back to sender and delete the payment
        (bool success, ) = payable(payment.sender).call{value: payment.amount}(
            ""
        );
        require(success, "transfer failed");

        delete _payments[msg.sender];
    }
}
