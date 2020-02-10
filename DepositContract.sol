pragma solidity >=0.4.22 <0.6.2;

contract Owned {
    address payable public owner;

    constructor() public payable {
        owner = msg.sender;
    }
}

/// @title Problem 1.	Receiving Funds from the default contract function
/// @author Denis M. Putnam
/// @notice Nothing in particular
/// @dev Use at your own risk.
contract DepositContract is Owned {
    uint256 private amountAdded;

    event DepositEvent(uint additionalAmount, uint currentTotal, address who);

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that only the owner can call the funtion.
    /// @dev emit the DepositEvent
    modifier ownerOnly() {
        require(msg.sender == owner,"Only the owner of the contract can execute this function.");
        emit DepositEvent(amountAdded, owner.balance,owner);
        _;
    }

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that only the msg sender is not the owner.
    /// @dev emit the DepositEvent
    modifier depositBy() {
        require(msg.sender != owner, "The owner of the contract cannot make his own deposit.");
        require(msg.value > 0, "The amount of the deposit must be greater than zero.");
        emit DepositEvent(msg.value, owner.balance, msg.sender);
        _;
    }

    /// @author Denis M. Putnam
    /// @notice The constructor for this contract.
    /// @dev It is envoked when the contract is deployed.  It initialized the amountAdded to zero.
    constructor() public {
        amountAdded = 0;
        emit DepositEvent(amountAdded,owner.balance,owner);
    }

    /// @author Denis M. Putnam
    /// @notice Deposit funds to the contract owner.
    /// @dev No extra details.
    function deposit() public payable depositBy() {
        owner.transfer(msg.value);
        amountAdded += msg.value;
    }

    /// @author Denis M. Putnam
    /// @notice Get the owner's address balance.
    /// @dev No extra details.
    /// @return owner.balance.
    function getOwnerBalance() public view returns(uint) {
        return owner.balance;
    }

    /// @author Denis M. Putnam
    /// @notice Get the total amount added
    /// @dev No extra details.
    /// @return amountAdded.
    function getAmountAdded() public view returns(uint) {
        return amountAdded;
    }

    /// @author Denis M. Putnam
    /// @notice kill this contract and send the owner.balance to the owner.
    /// @dev Kind of weired, since the owner already has it.
    function send() public ownerOnly() {
        selfdestruct(owner);
    }

    /// @author Denis M. Putnam
    /// @notice default fallback function that the calls the deposit function.
    /// @dev No Extra details.
    fallback() external payable depositBy(){
        deposit();
    }

    /// @author Denis M. Putnam
    /// @notice receive function that the calls the deposit function.
    /// @dev The 0.6.x compiler gives a warning if this is not defined.
    receive() external payable depositBy(){
        deposit();
    }
}