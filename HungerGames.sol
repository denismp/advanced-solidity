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

    enum Gender { Male, Female }
    InsecureRandomGenerator rand = new InsecureRandomGenerator();

    /// @notice User struct of from, balance, and flag.
    struct User {
        string name;
        uint256 age;
        Gender gender;
        bool flag;
    }

    /// @notice mapping of from addres to User.
    mapping(string => User) users; // map name => User
    mapping(uint256 => string) usersIndexMap; // index => name

    function add(string memory name, uint256 gender) public {
        users[name].name = name;
        users[name].age = rand.pseudoRandom(12,18);
        users[name].gender = getGender(gender);
        users[name].flag = true;
    }

    function getGender(uint256 index) public pure returns(Gender) {
        require( index == 0 || index == 1, "argument must be 0 or 1");
        return Gender(index);
    }

    function getPersonInfo(string memory name) public view returns (string memory, uint256, uint256) {
        string memory _player = users[name].name;
        uint256 _age = users[name].age;
        uint256 _sex = uint256(users[name].gender);
        return (_player, _age, _sex);
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