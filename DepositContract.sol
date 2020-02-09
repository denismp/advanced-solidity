pragma solidity >=0.4.22 <0.6.2;

contract Owned {
    address payable private owner;

    constructor() public payable {
        owner = msg.sender;
    }
}
contract DepositContract is Owned {
    uint256 private balance;

    constructor() public {
        balance = 0;
    }

    function deposit(uint256 value) public {
        balance += value;
    }

}