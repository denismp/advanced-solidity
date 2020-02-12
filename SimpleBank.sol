pragma solidity >=0.4.22 <0.6.2;

/// @title Problem 3.	Owned contract
/// @author Denis M. Putnam
/// @notice This contract establishes the owner and allows for an owner change.
/// @dev Use at your own risk.
contract Owned {
    address payable owner;

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that only the owner can call the funtion.
    /// @dev No other details
    modifier ownerOnly() {
        require(msg.sender == owner,"Only the owner of the contract can execute this function.");
        _;
    }

    /// @author Denis M. Putnam
    /// @notice Constructor called when the contract is deployed.
    /// @dev Sets the initial owner of the the contract.
    constructor() public payable {
        owner = msg.sender;
    }

    /// @author Denis M. Putnam
    /// @notice Get the current owner.
    /// @dev No other details.
    /// @return address current owner.
    function getCurrentOwner() public view returns(address) {
        return owner;
    }

    /// @author Denis M. Putnam
    /// @notice Change the current owner to the new owner.
    /// @dev No other details.
    /// @param newOwner new address payable owner.
    function changeOwner(address payable newOwner) public ownerOnly() {
        owner = newOwner;
    }
}

contract SimpleBank is Owned {
    // TODO make a transaction event.
    
    /// @notice User struct of from, balance, and flag.
    struct User {
        address payable from;
        address payable to;
        uint256 balance;
        bool flag;
    }

    /// @notice mapping of from addres to User.
    mapping(address => User) users;

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that the user has been added.
    /// @dev emit the DepositEvent
    modifier toAddressModifier(address payable to) {
        if(!users[to].flag) {
            users[to].to = to;
            users[to].from = msg.sender;
            users[to].flag = true;
            users[to].balance = 0;
        }
        _;
    }

    /// @author Denis M. Putnam
    /// @notice This modifier ensures 
    /// @dev emit the DepositEvent
    modifier fromAddressModifier() {
        require(users[msg.sender].flag, "User does not exist in this contract.  A deposit to the msg.sender must be made");        
        require(msg.sender == users[msg.sender].to, "msg.sender does not match the to address" );
        require(users[msg.sender].balance >= msg.value, "Not enough balance to withdaw the given amount");
        require(users[msg.sender].balance - msg.value < users[msg.sender].balance, "deposit will cause an overflow");
        _;
    }

    function deposit(address payable to) public payable toAddressModifier(to) returns(uint256 balance) {
        require(users[to].balance + msg.value > users[to].balance, "deposit will cause an overflow");
        users[to].balance += msg.value;
        return users[to].balance;
    }

    function withdraw() public payable fromAddressModifier() returns (uint256 balance) {
        users[msg.sender].balance -= msg.value; 
        msg.sender.transfer(msg.value);
        return users[msg.sender].balance;
    }

    function getBalance() public view returns (uint256 balance) {
        return users[msg.sender].balance;
    }
}