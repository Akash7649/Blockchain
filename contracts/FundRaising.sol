// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract FundRaising{

    address payable public owner; 
    uint public totalFundReq;
    uint public totalFundRaised;
    uint public totalDonor; // total number of donors
    uint public totalVote; // total number of vote given by public
    uint public votingEndTime;
    uint remainingFund;
    uint public endTime; // end time of contract after which no funds are deposited
    uint totalAsk=1; // means if schoool wants 100$ we will give them 10$ before-hand and the remaining 90$(only if the school gets >=51% of votiing by public) after the school gives their documents
    bool fundClamed; // if the school claimed their funds, but they are aattempting for the funds again we will throw error
    bool public votingStatus; // to check if voting is started

    mapping(address=>uint) public donors;
    mapping(address=>bool) public voted;

    constructor(uint _totalFundReq, uint _endTime){
        owner = payable(msg.sender);
        endTime = block.timestamp + _endTime;
        totalFundReq = _totalFundReq;
    }
 
    function sendFund() external payable {     // external means it cants be accessed within the smart-contracts and can only be accessed by outside
        require(block.timestamp < endTime, "Deadline has passed !!");
        require(msg.sender != owner, "School cannot participate in fund raising!!");
        require(msg.value > 0, "Minimum contribution is 1");

        // check for new contributor
        if(donors[msg.sender] == 0){
            totalDonor++;
        }
        donors[msg.sender] = donors[msg.sender] + msg.value;
        totalFundRaised = totalFundRaised + msg.value;
    }

    function getContractBalance() external view returns(uint) {   // gives the current funds in contract
        return address(this).balance;
    }

    function startVoting(uint _votingEndTime) external {
        require(msg.sender == owner, "Only School can start voting");
        require(block.timestamp > endTime, "Deadline has not passed yet!!");  // if fund raising is not over public cannot start voting
        votingEndTime = block.timestamp + _votingEndTime;
        votingStatus = true;
    }

    function putVote() external {
        require(votingStatus == true, "Voting has not started yet!!");
        require(block.timestamp < votingEndTime,"Voting time has passed!!");
        require(donors[msg.sender] != 0, "You are not allowed to participate as you have not cotributed!!");
        require(voted[msg.sender] == false, "You have already voted!!");
        totalVote++;
        voted[msg.sender] = true;
    }

    function claimFund() public{    // school can claim funds through this 
        require(fundClamed == false, "Fund is already claim!!");
        require(msg.sender == owner, "Only School can claim the funds!!");
        require(block.timestamp > endTime,"Crowdfunding not over yet!!");

        if(totalAsk == 1){
            uint transferAmt = totalFundRaised / 10;  //sending 10% of total fund raised; 
            remainingFund = totalFundRaised-transferAmt;
            totalAsk++;
            owner.transfer(transferAmt);
        }else{
            require(block.timestamp > votingEndTime,"Voting time has not yet passed!!");
            require(totalVote > totalDonor/2, "Majority does not support" );
            fundClamed = true;
            uint transferAmt = remainingFund;
            remainingFund =0;
            owner.transfer(transferAmt);
        }
        
    }


}