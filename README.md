# advanced-solidity
Exercises: Solidity Advanced In this lesson, we learned about functions, modifiers, events, contracts, interactions, error handling and libraries in Solidity programming language. The goal of this exercise is to get practical skills in writing advanced smart contracts in Solidity, publishing and testing contracts in the Remix IDE.

Problem 1.	Receiving Funds from the default contract function
Create a Deposit contract which:
•	Stores the owner of the contract
•	People can deposit ethers in the contract
•	People can get the balance of the contract
•	Owner can send amount
o	Upon sending, the contract self-destructs with the total amount in the contract
Use modifiers where it is appropriate.
Add appropriate events for the functions.

Problem 2.	Inheritance
Write a SafeMath contract (don’t google for the solution!)
•	The contract has methods to safely add, subtract and multiply two numbers
•	The methods should throw if an integer overflow occurs!
Write an Owned contract
•	Which knows its owner
•	Has method to change the owner (called from current owner)
•	Implements an access modifier
Write a contract that inherits SafeMath and Owned and uses their methods
•	The contract should hold one int256 state variable
•	Has a method to change the state variable automatically by these rules:
o	Method is called by the owner
o	The state is incremented by now % 256
o	The state is multiplied by the amount of seconds since the last state change (initially 1)
o	The current block gas limit is subtracted from the state

Problem 3.	Simple Bank
Create a simple Bank contract which:
•	holds balances of users
•	holds the owner of the contract
•	function deposit – user deposits ether to the bank
o	method must be payable
o	use require to validate corner cases (e.g. overflow)
o	return the balance of the user
•	 function withdraw(amount) – user withdraws ether from the bank
o	use require to validate corner cases
o	use msg.sender.transfer
o	return the new balance of the user
•	function getBalance – returns the caller's balance
Use modifiers where it is appropriate.
Add appropriate events for the functions.

Problem 4.	A Simple Timed Auction
Write a  contract for an auction, which continues for 1 minute after the contract is deploye. Use block.timestamp as a start time.
Contract stores:
•	owner of the contract
•	start time
•	duration time
•	stores each buyer's amount bought
•	constructor with a parameter – tokens amount to sell
•	function buyTokens(amount) – check whether the auction has ended
Use modifiers where it is appropriate.
Add appropriate events for the functions.

Problem 5.	A Simple Timed Auction (2)
Write a contract for an auction, which continues for 1 block after contract's creation.

Problem 6.	Hunger Games
 
Every year, in the ruins of what was once North America, the Capitol of the nation of Panem - a technologically advanced, utopian city where the nation's most wealthy and powerful citizens live, forces each of its 12 districts to send a teenage boy and a girl, between the ages of 12 and 18, to compete in the Hunger Games: a nationally televised event in which 'tributes' fight each other within an arena, until one survivor remains.
This time of the year has come and it’s time for the 100th hunger game where you should send the new pair of teenage boy and girl.
Create a Capitol contract which:
o	adds person by age and gender (hint: use struct for storing the person)
o	chooses one girl and one boy:
•	you are not allowed to choose the two people from the same gender
•	they should be between 12 and 18 years old
•	they should be chosen by random function (you can use block.timestamp but it is not safe or oraclize -> learn more about it from oraclize documentation)
o	you can check how many girls and boys are added -> returns a positive number
o	after choosing the pair (boy and girl) set the start date of the hunger games and the end date (the hunger games should last 5 minutes)
o	after the end of the hunger game, check if the boy and girl are alive (use random 0 - dead, 1 - alive, use modifier for checking if the hunger game ended)	
Use modifiers where it is appropriate.	
Add appropriate events for the functions.
Test and play around with the contract!
