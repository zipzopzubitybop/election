pragma solidity ^0.4.0;

/*
Election contract that allows the owner to issue voting rights 
to anybody and also end the election and announce results
*/
contract Election {
    
    struct Candidate {
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bool voted;
        uint vote;
        uint weight;
    }
    
    address public owner;
    string public name;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    
    event ElectionResult(string candidateName, uint voteCount);
    event VoteSubmitted();
    
    function Election(string _name, string candidate1, string candidate2) public {
        owner = msg.sender;
        
        name = _name;
        //initialize list of candidates to vote for
        candidates.push(Candidate(candidate1, 0));
        candidates.push(Candidate(candidate2, 0));
    }
    
    function authorize(address voter) public {
        //make sure only owner can authorize voting rights
        require(msg.sender == owner);
        //make sure voter has not already voted
        require(!voters[voter].voted);

        //assign voting rights
        voters[voter].weight = 1;
    }
    
    function vote(uint voteIndex) public {
        //make sure voter has not already voted
        require(!voters[msg.sender].voted);
        
        //record vote
        voters[msg.sender].vote = voteIndex;
        voters[msg.sender].voted = true;
        
        //increase candidate vote count by voter weight
        candidates[voteIndex].voteCount += voters[msg.sender].weight;
        VoteSubmitted();
    }
    
    function end() public {
        //make sure only owner can end voting
        require(msg.sender == owner);
        
        //announce each candidates results
        for(uint i=0; i < candidates.length; i++){
            ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
        
        //destroy the contract
        selfdestruct(owner);
    }
}

// to do:
// add an admin section
//  auth all users // by address (index.html + app.js)
//  get systemMap. Map map map (TANGO? FFXV Orthos66)
// struct(variables,descriptions)#
// mapping(address => struct) nameOfInstance[]

pragma solidity ^0.4.4; contract SimpleWallet {
    // Address is the owner
    address owner;
    
    struct WithdrawlStruct {
        address to;
        uint amount;
    }

    // Create an object for Senders
    struct Senders {
        bool allowed;
        uint amount_sends;
        mapping(uint => WithdrawlStruct) withdrawls;
    }

    // Mapping to determine if the Sender is allowed to send funds
    mapping(address => Senders) isAllowedToSendFundsMapping;
    
    // Events for Deposit and Withdrawals

    event Deposit(address _sender, uint amount);
    event Withdraw(address _sender, uint amount, address _beneficiary);

    // Set the owner as soon as the wallet is created

    function SimpleWallet() {
        owner = msg.sender;
    }

    // Check if the caller is allowed to send the messages.
    modifier allowedToSend() {
        require(isAllowedToSend(msg.sender));
        _;
    }
    // This anonymous function is called when the contract receives
    // funds from an address that is allowed to send funds
    // The "msg.sender" needs to be the Owner/Senders
    // and allowed to send funds to deposit them to the wallet
    // Also emit an event called Deposit and declare the "msg.sender"
    // and the value deposited.

    function() allowedToSend payable {
        Deposit(msg.sender, msg.value);
    }

    // Someone that is allowed to deposit funds is allowed to send
    // In this case, it is the owner or the boolean mapping is true for the caller
    // Their balance must be higher than the amount
    // If it goes through, we emit a withdraw event and return the balance

    function sendFunds(uint amount, address receiver) allowedToSend returns (uint) {
        require(this.balance >= amount);
        receiver.transfer(amount);
        Withdraw(msg.sender, amount, receiver);
        // Log each withdrawl, receiver, amount
        isAllowedToSendFundsMapping[msg.sender].amount_sends++;
        isAllowedToSendFundsMapping[msg.sender].withdrawls[
        isAllowedToSendFundsMapping[msg.sender].amount_sends ] = WithdrawlStruct(receiver, amount);
        return this.balance;
    }

    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    // Allowed to send funds when the boolean mapping is set to true
    function allowAddressToSendMoney(address _address) isOwner {
        isAllowedToSendFundsMapping[_address].allowed = true;
    }
    // Not allowed to send funds when the boolean mapping is set to false
    function disallowAddressToSendMoney(address _address) isOwner {
        isAllowedToSendFundsMapping[_address].allowed = false;
    }
    // Check function which returns the boolean value
    function isAllowedToSend(address _address) constant returns (bool) {
        return isAllowedToSendFundsMapping[_address].allowed || _address == owner;
    }
    // Check to make sure the msg.sender is the owner
    // And it will suicide the contract and return funds to the owner
    function killWallet() isOwner {
        suicide(owner);
    }
} 