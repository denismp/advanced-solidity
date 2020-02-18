pragma solidity >=0.4.22 <0.6.2;
pragma experimental ABIEncoderV2; // This is experimental.  don't use in main net.
// https://blog.ethereum.org/2019/03/26/solidity-optimizer-and-abiencoderv2-bug/

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

contract PetSanctuary is Owned {

    enum Gender { Male, Female }
    enum AnimalKind { Fish, Cat, Dog, Rabbit, Parrot, Invalid }

    /// @notice Person struct
    struct Person {
        string name;
        uint256 age;
        Gender gender;
        bool flag;
    }

    /// @notice Animal struct
    struct Animal {
        string animalKindName;
        AnimalKind animalKind;
        bool flag;
    }

    /// @notice SanctuaryAnimal struct
    struct SanctuaryAnimal {
        Animal animal;
        uint count;
        bool flag;
    }

    /// @notice PersonAnimal struct
    struct PersonAnimal {
        Person adoptee;
        Animal animal;
        uint256 timeBought;
        bool flag;
    }
    mapping(uint => SanctuaryAnimal) private sanctuaryAnimalMap;
    //mapping(string => uint) private animalKindToAnimalMap;
    mapping(uint => PersonAnimal) private personAnimalMap;
    mapping(string => uint) private personToAnimalMap;

    struct IndexToAnimal {
        uint index;
        string name;
    }

    IndexToAnimal[] private indexToAnimalAr;

    uint private sanctuaryIndex = 0;

    event AddAnimalEvent(uint index, string animalKind, uint howMany);

   /// @author Denis M. Putnam
    /// @notice This modifier checks for the team time out.
    /// @dev dead or alive is reandomly determined.
    modifier checkOwnerModifier() {
        require(msg.sender == owner,"You must be the owner of the sanctuary");
        _;
    }

    function add(string memory animalKind, uint numberToAdd) public checkOwnerModifier() {
        AnimalKind _animalKind = getAnimalKind(animalKind);
        require(_animalKind >= AnimalKind.Fish && _animalKind <= AnimalKind.Parrot,"Invalid animal kind");
        if(getAnimalKindCount(_animalKind, sanctuaryIndex) == 0) {
            string memory _animalKindName = getAnimalKindName(_animalKind);
            sanctuaryAnimalMap[sanctuaryIndex].animal.animalKind = _animalKind;
            sanctuaryAnimalMap[sanctuaryIndex].animal.animalKindName = getAnimalKindName(_animalKind);
            sanctuaryAnimalMap[sanctuaryIndex].animal.flag = true;
            sanctuaryAnimalMap[sanctuaryIndex].count = numberToAdd;
            //animalKindToAnimalMap[_animalKindName] = sanctuaryIndex;
            IndexToAnimal memory i2a;
            i2a.index = sanctuaryIndex;
            i2a.name = _animalKindName;
            indexToAnimalAr.push(i2a);
            emit AddAnimalEvent(sanctuaryIndex,_animalKindName,numberToAdd);
            sanctuaryIndex++; 
        } else {
            sanctuaryAnimalMap[sanctuaryIndex].count = getAnimalKindCount(_animalKind,sanctuaryIndex) + numberToAdd;
        }
    }    

    function buy(uint personAge, uint personGender, string memory animalKind) public {

    }

    function giveBack(string memory animalKind) public {
        
    }

    function getGender(uint256 index) public pure returns(Gender) {
        require( index == 0 || index == 1, "argument must be 0 or 1");
        return Gender(index);
    }

    function getAnimalKind(uint256 index) private pure returns(AnimalKind) {
        require( index >= 0 && index < 4, "argument must be between 0 and 4");
        return AnimalKind(index);
    }

    function getAnimalKind(string memory name) public pure returns (AnimalKind) {
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("Fish")) || keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("fish"))) {
           return AnimalKind.Fish;
        }
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("Cat")) || keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("cat"))) {
           return AnimalKind.Cat;
        }
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("Dog")) || keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("dog"))) {
           return AnimalKind.Dog;
        }
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("Rabbit")) || keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("rabbit"))) {
           return AnimalKind.Rabbit;
        }
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("Parrot")) || keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("parrot"))) {
           return AnimalKind.Parrot;
        }
        return AnimalKind.Invalid;
    }

    event AnimalKindCountEvent(uint debug, string animalKind, uint sanctuaryIndex, bool flag, uint count);
    
    function getAnimalKindCount(AnimalKind animalKind, uint index) public view returns (uint) {
        if(sanctuaryAnimalMap[index].animal.animalKind == animalKind) {
            return sanctuaryAnimalMap[index].count; 
        }
        return 0;
    }

    // function getAnimalKindCount(string memory animalKind) public view returns (uint) {
    //     AnimalKind _animalKind = getAnimalKind(animalKind);
    //     string memory _animalKindName = getAnimalKindName(_animalKind);
    //     uint index = animalKindToAnimalMap[_animalKindName];
    //     bool exists = sanctuaryAnimalMap[index].flag;
    //     if(exists == true) {
    //         return sanctuaryAnimalMap[index].count; 
    //     }
    //     return 0;
    // }
    function getAnimalKindCount(string memory animalKind) public view returns (uint) {
        AnimalKind _animalKind = getAnimalKind(animalKind);
        string memory _animalKindName = getAnimalKindName(_animalKind);
        for(uint i = 0; i < indexToAnimalAr.length; i++) {
            if(keccak256(abi.encodePacked(indexToAnimalAr[i].name)) == keccak256(abi.encodePacked(_animalKindName))) {
                return sanctuaryAnimalMap[i].count;
            }
        }
        return 0;
    }

    //event GetAnimalKindNameEvent(string name);
    function getAnimalKindName(AnimalKind animalKind) public pure returns (string memory) {
        if(animalKind == AnimalKind.Fish) {
            //emit GetAnimalKindNameEvent("Fish");
            return "Fish";
        }
        if(animalKind == AnimalKind.Cat) {
            //emit GetAnimalKindNameEvent("Cat");
            return "Cat";
        }
        if(animalKind == AnimalKind.Dog) {
            //emit GetAnimalKindNameEvent("Dog");
            return "Dog";
        }
        if(animalKind == AnimalKind.Rabbit) {
            //emit GetAnimalKindNameEvent("Rabbit");
            return "Rabbit";
        }
        if(animalKind == AnimalKind.Parrot) {
            //emit GetAnimalKindNameEvent("Parrot");
            return "Parrot";
        }
        //emit GetAnimalKindNameEvent("Nothing");
    }

    function getI2A() view public returns (IndexToAnimal[] memory toAnimalAr) {
       return indexToAnimalAr;
    }
}