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
contract SimpleTimedAuction is Owned{
    uint256 private startTime;
    uint256 private durationTime;
    uint256 private amountTokensForSale;
    uint256 private numberOfUsers;
    bool private firstTime = true;
    bool private timedOut = false;

    /// @notice User struct of from, balance, and flag.
    struct User {
        address who;
        uint256 bidAmount; // in wei
        uint256 tokensWon;
        bool flag;
    }

    /// @notice mapping of from addres to User.
    mapping(address => User) users;
    mapping(uint256 => address) userAddresses;
    
    constructor(uint256 tokensForSale) public payable {
        startTime = block.timestamp; 
        durationTime = 60 seconds;
        amountTokensForSale = tokensForSale;
        numberOfUsers = 0;
    }

    event BidTokensEvent(address who, uint256 bid);
    event TimeoutEvent(address who, uint256 bid);
    event WinnerEvent(address winner, uint256 bid, uint256 tokensRecieved);
    event OwnerPayedEvent(address owner, uint256 payAmount, address fromAddress);

    /// @author Denis M. Putnam
    /// @notice This modifier ensures that the user has been added.
    /// @dev corners/edges are check for.
    modifier bidTokens() {
        if(!users[msg.sender].flag) {
            users[msg.sender].who = msg.sender;
            users[msg.sender].flag = true;
            users[msg.sender].bidAmount = 0;
            users[msg.sender].tokensWon = 0;
            userAddresses[numberOfUsers] = msg.sender;
            numberOfUsers++;
        }
        _;
    }

    function bid() public payable bidTokens() {
        require(msg.sender != getCurrentOwner(),"You cannot be the owner to bid.");
        require(timedOut == false,"Bidding has timed out");
        address winAddress;
        uint256 currentTime = now;
        if(currentTime < startTime + durationTime) {
            users[msg.sender].bidAmount = msg.value;
            emit BidTokensEvent(msg.sender, msg.value);
        } else {
            timedOut = true;
            // Bidding timed out.
            emit TimeoutEvent(msg.sender, msg.value);

            // Find the winner's address and emit it.
            winAddress = winner();
            users[winAddress].tokensWon = amountTokensForSale;
            amountTokensForSale = 0;
            emit WinnerEvent(winAddress, users[winAddress].bidAmount, amountTokensForSale);

            // Pay the owner the amount bid by the winner.
            address payable currentOwner = getCurrentOwner();
            currentOwner.transfer(users[winAddress].bidAmount);
            emit OwnerPayedEvent(currentOwner, users[winAddress].bidAmount, winAddress);
        }
    }

    /// @author Denis M. Putnam
    /// @notice Get the winner.
    /// @dev No further details.
    /// @return winningUser index:winningUser.
    function getWinner() private view returns(uint256 winningUser) {
        uint256 winningBid = 0;
        for (uint u = 0; u <= numberOfUsers; u++) {
            if (users[userAddresses[u]].bidAmount > winningBid) {
                winningBid = users[userAddresses[u]].bidAmount;
                winningUser = u;
            }
        }
    }

    /// @author Denis M. Putnam
    /// @notice Determine winner.
    /// @dev No further details.
    /// @return winningAddress that is current.
    function winner() public view returns (address winningAddress) {
        winningAddress = userAddresses[getWinner()]; 
    }


    /// @author Denis M. Putnam
    /// @notice Get the total amount of tokens for sale
    /// @dev No further details.
    /// @return amountTokensForSale
    function getTotalAmountOfTokens() view public returns (uint256) {
        return amountTokensForSale;
    }

    /// @author Denis M. Putnam
    /// @notice Get the winner and his tokens
    /// @dev No further details.
    /// @return winAddress
    /// @return myBid
    /// @return tokensWon
    function getWinnings() view public returns (address winAddress, uint256 myBid, uint256 tokensWon) {
        address winnerAddress = winner();
        require(users[winnerAddress].tokensWon > 0,"You haven't won yet.");
        tokensWon = users[winnerAddress].tokensWon;
        myBid = users[winnerAddress].bidAmount;
        return(winnerAddress,myBid,tokensWon);
    }

    /// @author Denis M. Putnam
    /// @notice Terminate this contract
    /// @dev No further details.
    function kill() public {
        require(msg.sender == getCurrentOwner(), "You must be the owner of this contract");
        selfdestruct(getCurrentOwner());
    }
}