pragma solidity >=0.4.22 <0.6.2;

contract Owned {
    address payable public owner;

    constructor() public payable {
        owner = msg.sender;
    }
}
contract DepositContract is Owned {
    uint256 private amountAdded;

    event DepositEvent(uint amount, uint currentTotal, address who);

    modifier ownerOnly() {
        require(msg.sender == owner,"Only the owner of the contract can execute this function.");
        emit DepositEvent(amountAdded, owner.balance,owner);
        _;
    }

    modifier depositBy(address who, uint256 amount) {
        require(msg.sender != owner, "The owner of the contract cannot make his own deposit.");
        emit DepositEvent(amount, owner.balance, who);
        _;
    }

    constructor() public {
        amountAdded = 0;
        emit DepositEvent(amountAdded,owner.balance,owner);
    }

    function deposit() public payable depositBy(msg.sender, msg.value) {
        owner.transfer(msg.value);
        amountAdded += msg.value;
    }

    function getOwnerBalance() public view returns(uint) {
        return owner.balance;
    }

    function getAmountAdded() public view returns(uint) {
        return amountAdded;
    }

    function send() public ownerOnly() {
        selfdestruct(owner);
    }
}