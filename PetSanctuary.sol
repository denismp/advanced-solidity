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
        address name;
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
        int count;
        bool flag;
    }

    /// @notice PersonAnimal struct
    struct PersonAnimal {
        Person person;
        Animal animal;
        int count;
        uint256 timeBought;
        bool flag;
    }
    mapping(int => SanctuaryAnimal) private sanctuaryAnimalMap;
    mapping(int => PersonAnimal) private personAnimalMap;
    uint256 private endTime = 5 minutes;

    struct IndexToAnimal {
        int index;
        string name;
    }

    struct IndexToPerson {
        int index;
        address personAddress;
    }

    IndexToAnimal[] private indexToAnimalAr;
    IndexToPerson[] private indexToPersonAr;

    int private sanctuaryIndex = -1;
    int private personAnimalIndex = -1;

    event AddAnimalEvent(int index, string animalKind, uint howMany);

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
        if(getAnimalKindCount(animalKind) == 0) {
            sanctuaryIndex++;
            string memory _animalKindName = getAnimalKindName(_animalKind);
            sanctuaryAnimalMap[sanctuaryIndex].animal.animalKind = _animalKind;
            sanctuaryAnimalMap[sanctuaryIndex].animal.animalKindName = getAnimalKindName(_animalKind);
            sanctuaryAnimalMap[sanctuaryIndex].animal.flag = true;
            sanctuaryAnimalMap[sanctuaryIndex].count = int(numberToAdd);
            IndexToAnimal memory i2a;
            i2a.index = sanctuaryIndex;
            i2a.name = _animalKindName;
            indexToAnimalAr.push(i2a);
            emit AddAnimalEvent(sanctuaryIndex,_animalKindName,numberToAdd);
        } else {
            //sanctuaryAnimalMap[sanctuaryIndex].count = getAnimalKindCount(_animalKind,sanctuaryIndex) + int(numberToAdd);
            sanctuaryAnimalMap[sanctuaryIndex].count = getAnimalKindCount(animalKind) + int(numberToAdd);
        }
    }    

    event BuyEvent(address who, uint age, uint gender, string animalKindName);

    /// @author Denis M. Putnam
    /// @notice This modifier checks for the team time out.
    /// @dev dead or alive is reandomly determined.
    modifier buyModifier(uint personGender,string memory animalKind) {
        require(personGender == 0 || personGender == 1, "gender is 0 for male and 1 for female");
        AnimalKind _animalKind = getAnimalKind(animalKind);
        require(_animalKind >= AnimalKind.Fish && _animalKind <= AnimalKind.Parrot, "animal kind is not supported");
        require(isBought() == false, "Only one animal allowed for life"); 
        _;
    }
    function buy(uint personAge, uint personGender, string memory animalKind) public buyModifier(personGender,animalKind){
        AnimalKind _animalKind = getAnimalKind(animalKind);

        string memory animalKindName = getAnimalKindName(_animalKind);
        int _sanctuaryIndex = getAnimalKindIndex(animalKindName);
        int animalCount = sanctuaryAnimalMap[_sanctuaryIndex].count;

        if(getGender(personGender) == Gender.Male && (_animalKind == AnimalKind.Dog || _animalKind == AnimalKind.Fish)) {
            personAnimalIndex++;
            personAnimalMap[personAnimalIndex].person.name = msg.sender;
            personAnimalMap[personAnimalIndex].person.age = personAge;
            personAnimalMap[personAnimalIndex].person.gender = Gender.Male;
            personAnimalMap[personAnimalIndex].flag = true;
            personAnimalMap[personAnimalIndex].timeBought = now;
            personAnimalMap[personAnimalIndex].animal.animalKind = _animalKind;
            personAnimalMap[personAnimalIndex].animal.animalKindName = animalKindName;
            personAnimalMap[personAnimalIndex].animal.flag = true;
            if(animalCount > 0) {
                sanctuaryAnimalMap[_sanctuaryIndex].count--;
            }
            IndexToPerson memory i2a;
            i2a.index = personAnimalIndex;
            i2a.personAddress = msg.sender;
            indexToPersonAr.push(i2a);
            emit BuyEvent(msg.sender, personAge, personGender, animalKindName);
        }
        if(getGender(personGender) == Gender.Female && personAge < 40 && _animalKind != AnimalKind.Cat) {
            personAnimalIndex++;
            personAnimalMap[personAnimalIndex].person.name = msg.sender;
            personAnimalMap[personAnimalIndex].person.age = personAge;
            personAnimalMap[personAnimalIndex].person.gender = Gender.Female;
            personAnimalMap[personAnimalIndex].flag = true;
            personAnimalMap[personAnimalIndex].timeBought = now;
            personAnimalMap[personAnimalIndex].animal.animalKind = _animalKind;
            personAnimalMap[personAnimalIndex].animal.animalKindName = animalKindName;
            personAnimalMap[personAnimalIndex].animal.flag = true;
            if(animalCount > 0) {
                sanctuaryAnimalMap[_sanctuaryIndex].count--;
            }
            IndexToPerson memory i2a;
            i2a.index = personAnimalIndex;
            i2a.personAddress = msg.sender;
            indexToPersonAr.push(i2a);
            emit BuyEvent(msg.sender, personAge, personGender, animalKindName);
        }
        if(getGender(personGender) == Gender.Female && personAge >= 40) {
            personAnimalIndex++;
            personAnimalMap[personAnimalIndex].person.name = msg.sender;
            personAnimalMap[personAnimalIndex].person.age = personAge;
            personAnimalMap[personAnimalIndex].person.gender = Gender.Female;
            personAnimalMap[personAnimalIndex].flag = true;
            personAnimalMap[personAnimalIndex].timeBought = now;
            personAnimalMap[personAnimalIndex].animal.animalKind = _animalKind;
            personAnimalMap[personAnimalIndex].animal.animalKindName = animalKindName;
            personAnimalMap[personAnimalIndex].animal.flag = true;
            if(animalCount > 0) {
                sanctuaryAnimalMap[_sanctuaryIndex].count--;
            }
            IndexToPerson memory i2a;
            i2a.index = personAnimalIndex;
            i2a.personAddress = msg.sender;
            indexToPersonAr.push(i2a);
            emit BuyEvent(msg.sender, personAge, personGender, animalKindName);
        }
    }

    event TimeoutEvent(address who, string animalKindName);

    function giveBack(string memory animalKind) public {
        int _personIndex = getPersonAnimalIndex(); 
        AnimalKind _animalKind = getAnimalKind(animalKind); // convert string animalKind to enum
        string memory animalKindName = getAnimalKindName(_animalKind); // now get the real animalKindName
        int _animalIndex = getAnimalKindIndex(animalKindName); // get the index for the sanctuary

        // See if the person's time has run out.
        uint256 currentTime = now;
        if(currentTime > personAnimalMap[_personIndex].timeBought + endTime) {
            emit TimeoutEvent(msg.sender, animalKindName);
            return;
        }
        personAnimalMap[_personIndex].count = 0;
        sanctuaryAnimalMap[_animalIndex].count++;
    }

    function isBought() public view returns (bool) {
        int _index = getPersonAnimalIndex();
        if(_index != -1 && personAnimalMap[_index].flag == true) {
            return true;
        }
        return false;
    }

    function getPersonAnimalIndex() public view returns (int) {
        for(uint i = 0; i < indexToPersonAr.length; i++) {
            if(indexToPersonAr[i].personAddress == msg.sender) {
                return indexToPersonAr[i].index;
            }
        } 
        return -1;
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

    function getAnimalKindCount(string memory animalKind) public view returns (int) {
        AnimalKind _animalKind = getAnimalKind(animalKind);
        string memory _animalKindName = getAnimalKindName(_animalKind);
        for(uint i = 0; i < indexToAnimalAr.length; i++) {
            if(keccak256(abi.encodePacked(indexToAnimalAr[i].name)) == keccak256(abi.encodePacked(_animalKindName))) {
                return sanctuaryAnimalMap[int(i)].count;
            }
        }
        return 0;
    }

    function getAnimalKindIndex(string memory animalKind) public view returns (int) {
        AnimalKind _animalKind = getAnimalKind(animalKind);
        string memory _animalKindName = getAnimalKindName(_animalKind);
        for(uint i = 0; i < indexToAnimalAr.length; i++) {
            if(keccak256(abi.encodePacked(indexToAnimalAr[i].name)) == keccak256(abi.encodePacked(_animalKindName))) {
                return int(i);
            }
        }
        return -1;
    }

    function getAnimalKindName(AnimalKind animalKind) public pure returns (string memory) {
        if(animalKind == AnimalKind.Fish) {
            return "Fish";
        }
        if(animalKind == AnimalKind.Cat) {
            return "Cat";
        }
        if(animalKind == AnimalKind.Dog) {
            return "Dog";
        }
        if(animalKind == AnimalKind.Rabbit) {
            return "Rabbit";
        }
        if(animalKind == AnimalKind.Parrot) {
            return "Parrot";
        }
    }

    function getI2A() view public returns (IndexToAnimal[] memory toAnimalAr) {
       return indexToAnimalAr;
    }
}