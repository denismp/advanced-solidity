pragma solidity >=0.4.22 <0.6.2;

/// @title Problem 2.	Owned contract
/// @author Denis M. Putnam
/// @notice This contract establishes the owner and allows for an owner change.
/// @dev Use at your own risk.
contract Owned {
    address payable owner;

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that only the owner can call the funtion.
    /// @dev emit the DepositEvent
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

contract SafeMath {

    function add(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a + _b <= _max, "The value requested will cause an overflow condition.");
        return a + b;
    }

    function subtract(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a - _b <= _max, "The value requested will cause an overflow condition.");
        return a - b;
    }

    function multiply(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a * _b <= _max, "The value requested will cause an overflow condition.");
        return a * b;
    }
}

contract InheritSafeMath is Owned, SafeMath {
    int256 private state = 0;
    uint256 private lastChangedTime = 1;

    /// @author Denis M. Putnam
    /// @notice This modifier updates the lastChangedTime.
    /// @dev No other details.
    modifier lastTimeModifier() {
        lastChangedTime = uint256(this.add(int256(lastChangedTime), int256(now)));
        _;
    }

    // function testAdd() public view returns(int256) {
    //     int256 rVal = this.add(1,1);
    //     return rVal;
    // }
    // function testSubtract() public view returns(int256) {
    //     int256 rVal = this.subtract(1,2);
    //     return rVal;
    // }
    // function testMultiply() public view returns(int256) {
    //     int256 rVal = this.multiply(2,-1);
    //     return rVal;
    // }

    function increment() public ownerOnly() lastTimeModifier() {
        state = this.add(state, int256(now) % 256); 
    }

    function multiply(int256 amountOfSeconds) public ownerOnly() lastTimeModifier() {
        state = this.multiply(state, this.add(int256(lastChangedTime),amountOfSeconds)); 
    }

    function subtract() public ownerOnly() lastTimeModifier() {
        state = this.subtract(state, int256(block.gaslimit)); 
    }

    function getCurrentState() view public returns (int256 currentState) {
        return state; 
    }

    function getLastTimeChanged() view public returns (uint256 lastTimeChanged) {
        return lastChangedTime; 
    }
}