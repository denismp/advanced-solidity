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

contract HungerGames is Owned {

    uint private numPeople = 0;
    enum Gender { Male, Female }
    InsecureRandomGenerator rand = new InsecureRandomGenerator();

    /// @notice Person struct of from, balance, and flag.
    struct Person {
        string name;
        uint256 age;
        Gender gender;
        bool flag;
    }

    /// @notice mapping of from addres to Person.
    mapping(string => Person) persons; // map name => Person
    mapping(uint256 => string) personsIndexMap; // index => name

    function add(string memory boyName, string memory girlName) public {
        persons[boyName].name = boyName;
        persons[boyName].age = rand.pseudoRandom(12,18);
        persons[boyName].gender = getGender(0);
        persons[boyName].flag = true;
        personsIndexMap[numPeople++] = boyName;
        persons[girlName].name = girlName;
        persons[girlName].age = rand.pseudoRandom(12,18);
        persons[girlName].gender = getGender(1);
        persons[girlName].flag = true;
        personsIndexMap[numPeople++] = girlName;
    }

    function getGender(uint256 index) public pure returns(Gender) {
        require( index == 0 || index == 1, "argument must be 0 or 1");
        return Gender(index);
    }

    function getPersonInfo(string memory name) public view returns (string memory _player, uint256 _age, uint256 _sex) {
        _player = persons[name].name;
        _age = persons[name].age;
        _sex = uint256(persons[name].gender);
        return (_player, _age, _sex);
    }

    function getNumberOfGirls() view public returns (uint256 numGirls) {
        numGirls = 0;
        for(uint i = 0; i < numPeople; i++) {
            if(persons[personsIndexMap[i]].gender == Gender.Female) {
                numGirls++;
            }
        }
    }
    function getNumberOfBoys() view public returns (uint256 numBoys) {
        numBoys = 0;
        for(uint i = 0; i < numPeople; i++) {
            if(persons[personsIndexMap[i]].gender == Gender.Male) {
                numBoys++;
            }
        }
    }

    function getNumberBoysAndGirls() public view returns(uint) {
        return numPeople;
    }
}

contract InsecureRandomGenerator {
    bytes32 public randseed;

    function pseudoRandom(uint start, uint end) public returns (uint256) {
        randseed = keccak256(abi.encodePacked( randseed, block.timestamp, block.coinbase, block.difficulty, block.number));
        uint range = end - start + 1;
        uint randVal = start + uint256(randseed) % range;
        return randVal;    
    }
}