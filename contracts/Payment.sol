// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Payment {
    address payable public receiver;

    event PaymentSent(address sender, address receiver, uint amount);

    function sendPayment() public payable {
        require(msg.value > 0, "Amount should be greater than zero");
        receiver = payable(msg.sender);
        uint amount = msg.value;
        receiver.transfer(amount);
        emit PaymentSent(msg.sender, receiver, amount);
    }
}
