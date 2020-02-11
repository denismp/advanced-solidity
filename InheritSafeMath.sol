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

/// @title Problem 2.	SafeMath
/// @author Denis M. Putnam
/// @notice This contract provides add, subtract, and multiply of int256 values.
/// @dev Use at your own risk
contract SafeMath {

    /// @author Denis M. Putnam
    /// @notice Add two int256 values.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    /// @param a int256 value
    /// @param b int256 value
    /// @return an int256 sum.
    function add(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a + _b <= _max, "The value requested will cause an overflow condition.");
        return a + b;
    }

    /// @author Denis M. Putnam
    /// @notice Subtract two int256 values.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    /// @param a int256 value
    /// @param b int256 value
    /// @return an int256 difference.
    function subtract(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a - _b <= _max, "The value requested will cause an overflow condition.");
        return a - b;
    }

    /// @author Denis M. Putnam
    /// @notice Multiply two int256 values.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    /// @param a int256 value
    /// @param b int256 value
    /// @return an int256 multiplication value.
    function multiply(int256 a, int256 b) external pure returns(int256) {
        uint256 _a = uint256(a);
        uint256 _b = uint256(b);
        uint256 _max = 2**256 - 1;
        require(_a * _b <= _max, "The value requested will cause an overflow condition.");
        return a * b;
    }
}

/// @title Problem 2.	InheritSafeMath
/// @author Denis M. Putnam
/// @notice This contract provides add, subtract, and multiply of int256 values.
/// @dev Use at your own risk
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

    /// @author Denis M. Putnam
    /// @notice Increment by now % 256
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    function increment() public ownerOnly() lastTimeModifier() {
        state = this.add(state, int256(now) % 256); 
    }

    /// @author Denis M. Putnam
    /// @notice Multiply the state by the amount seconds since the last state change.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    function multiply() public ownerOnly() lastTimeModifier() {
        state = this.multiply(state, this.subtract(int256(lastChangedTime),int256(now))); 
    }

    /// @author Denis M. Putnam
    /// @notice Subtract the state by the block.gaslimit.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    function subtract() public ownerOnly() lastTimeModifier() {
        state = this.subtract(state, int256(block.gaslimit)); 
    }

    /// @author Denis M. Putnam
    /// @notice Get the current state value.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    /// @return currentState
    function getCurrentState() view public returns (int256 currentState) {
        return state; 
    }

    /// @author Denis M. Putnam
    /// @notice Get the last time the state was changed.
    /// @dev I have attempted to make this function prevent overflow, but we will see in the next session
    /// @return lastTimeChanged
    function getLastTimeChanged() view public returns (uint256 lastTimeChanged) {
        return lastChangedTime; 
    }
}