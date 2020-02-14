pragma solidity >=0.4.22 <0.6.2;

/// @title Problem 4.	Owned contract
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
    function getCurrentOwner() public view returns(address payable) {
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

/// @title Problem 4.	A Simple Timed Auction.
/// @author Denis M. Putnam
/// @notice A contract for an auction, which continues for 1 minute after the contract is deploye. Use block.timestamp as a start time.
/// @dev Use at your own risk.
contract SimpleTimedTokensSale is Owned{
    uint256 private startTime;
    uint256 private durationTime;
    uint256 private amountTokensForSale;
    bool private firstTime = true;
    bool private timedOut = false;

    /// @notice User struct of from, balance, and flag.
    struct User {
        address who;
        uint256 amountTokensBought; // in wei
        bool flag;
    }

    /// @notice mapping of from addres to User.
    mapping(address => User) users;
    
    constructor(uint256 tokensForSale) public payable {
        startTime = block.timestamp; 
        durationTime = 60 seconds;
        amountTokensForSale = tokensForSale;
    }

    event BuyTokensEvent(address who, uint256 bid);
    event TimeoutEvent(address who, uint256 bid);

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that the user has been added.
    /// @dev corners/edges are check for.
    modifier buyTokensModifier() {
        if(!users[msg.sender].flag) {
            users[msg.sender].who = msg.sender;
            users[msg.sender].flag = true;
            users[msg.sender].amountTokensBought = 0;
        }
        _;
    }

    /// @author Denis M. Putnam
    /// @notice Buy tokens
    /// @dev No further details.
    function buyTokens(uint256 numTokens) public buyTokensModifier() {
        require(msg.sender != getCurrentOwner(),"You cannot be the owner to bid.");
        require(timedOut == false,"Bidding has timed out");
        require(amountTokensForSale >= numTokens,"Purchase amount is greater than the number of tokens for sale");
        require(amountTokensForSale - numTokens <= amountTokensForSale, "The value requested will cause an overflow condition.");
        uint256 currentTime = now;
        if(currentTime < startTime + durationTime) {
            users[msg.sender].amountTokensBought += numTokens;
            amountTokensForSale -= numTokens;
            emit BuyTokensEvent(msg.sender, numTokens);
        } else {
            timedOut = true;
            // Bidding timed out.
            emit TimeoutEvent(msg.sender, numTokens);
        }
    }

    /// @author Denis M. Putnam
    /// @notice Get the tokens of the buyer.
    /// @dev No further details.
    /// @return numPurchased
    function getTokens() view public returns (uint256 numPurchased) {
       require(users[msg.sender].amountTokensBought > 0, "You did not buy any tokens");
       numPurchased = users[msg.sender].amountTokensBought; 
    }

    /// @author Denis M. Putnam
    /// @notice Get the total amount of tokens for sale
    /// @dev No further details.
    /// @return amountTokensForSale
    function getTotalAmountOfTokens() view public returns (uint256) {
        return amountTokensForSale;
    }

    /// @author Denis M. Putnam
    /// @notice Terminate this contract
    /// @dev No further details.
    function kill() public {
        require(msg.sender == getCurrentOwner(), "You must be the owner of this contract");
        selfdestruct(getCurrentOwner());
    }

    /// @author Denis M. Putnam
    /// @notice Get time left
    /// @dev No further details.
    /// @return timeLeft
    function getTimeLeft() view public returns (int256 timeLeft) {
        uint256 currentTime = now;
        if(int256((startTime + durationTime) - currentTime) > 0){
            timeLeft = int256((startTime + durationTime) - currentTime);
        } else {
            timeLeft = 0;
        }
    }

}