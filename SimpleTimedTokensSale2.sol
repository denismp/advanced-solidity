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
/// @notice Problem 5.	A Simple Timed Auction (2) Write a contract for an auction, which continues for 1 block after contract's creation.
/// @dev Use at your own risk.
contract SimpleTimedTokensSale2 is Owned{
    uint256 private originalBlockNumber;
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
        originalBlockNumber = block.number + 1; 
        amountTokensForSale = tokensForSale;
    }

    event BuyTokensEvent(address who, uint256 bid);
    event TimeoutEvent(address who, uint256 bid);
    event BlockInfoEvent(uint index, address who, uint256 originalBlockNumber, uint256 currentBlockNumber);

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
        emit BlockInfoEvent(1, msg.sender, originalBlockNumber, block.number);
        require( originalBlockNumber >= block.number, "Block expired.");
        if(originalBlockNumber >= block.number) {
            users[msg.sender].amountTokensBought += numTokens;
            amountTokensForSale -= numTokens;
            emit BuyTokensEvent(msg.sender, numTokens);
            emit BlockInfoEvent(2, msg.sender, originalBlockNumber, block.number);
        } else {
            emit BlockInfoEvent(1, msg.sender, originalBlockNumber, block.number);
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
    /// @return currentBlockNumber
    function getBlockNumber() view public returns (uint256 currentBlockNumber) {
        currentBlockNumber = block.number;
    }

}