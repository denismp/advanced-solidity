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

/// @title Problem 5. Hunger Games
/// @author Denis M. Putnam
/// @notice This contract establishes the owner and allows for an owner change.
/// @dev Use at your own risk.
contract HungerGames is Owned {

    uint256 private startTime;
    uint256 private endTime;
    bool private timedOut = false;
    bool private chooseTeamFlag = true;
    bool private checkTeamFlag = false;
    uint private teamNumber;
    uint private teamCount = 0;
    enum Gender { Male, Female }
    InsecureRandomGenerator rand = new InsecureRandomGenerator();

    /// @notice Person struct
    struct Person {
        string name;
        uint256 age;
        Gender gender;
        uint alive;
        bool flag;
    }

    /// @notice Team struct
    struct Team {
        uint team;
        Person male;
        Person female;
    }

    mapping(uint256 => Team) private teams;

    event AddTeamEvent(uint teamNum, string boyName, string girlName);

    /// @author Denis M. Putnam
    /// @notice Add team.  One female and one male
    /// @dev No further details
    /// @param boyName name of boy
    /// @param girlName name of girl
    function add(string memory boyName, string memory girlName) public {
        teams[teamCount].male.name = boyName;
        teams[teamCount].male.age = rand.pseudoRandom(12,18);
        teams[teamCount].male.gender = getGender(0);
        teams[teamCount].male.flag = true;
        teams[teamCount].male.alive = 1;

        teams[teamCount].female.name = girlName;
        teams[teamCount].female.age = rand.pseudoRandom(12,18);
        teams[teamCount].female.gender = getGender(1);
        teams[teamCount].female.flag = true;
        teams[teamCount].female.alive = 1;

        teams[teamCount].team = teamCount;
        emit AddTeamEvent(teamCount, teams[teamCount].male.name, teams[teamCount].female.name);
        teamCount++;
    }

    function getGender(uint256 index) public pure returns(Gender) {
        require( index == 0 || index == 1, "argument must be 0 or 1");
        return Gender(index);
    }

    /// @author Denis M. Putnam
    /// @notice getPersonInfo for the given name
    /// @dev No further details
    /// @param name of the person of interest
    /// @return team
    /// @return _player the name of the player
    /// @return _age
    /// @return _sex
    /// @return _alive
    function getPersonInfo(string memory name) public view returns (uint team, string memory _player, uint256 _age, Gender _sex, uint256 _alive) {
        Person memory _male;
        Person memory _female;
        for(uint i = 0; i < teamCount; i++) {
            _male = teams[i].male;
            _female = teams[i].female;
            if(keccak256(abi.encodePacked(_male.name)) == keccak256(abi.encodePacked(name))) {
                _player = _male.name;
                _age = _male.age;
                _sex = _male.gender;
                _alive = _male.alive;
                return (i, _player, _age, _sex, _alive);
            }
            if(keccak256(abi.encodePacked(_female.name)) == keccak256(abi.encodePacked(name))) {
                _player = _female.name;
                _age = _female.age;
                _sex = _female.gender;
                _alive = _female.alive;
                return (i, _player, _age, _sex, _alive);
            }
        }
    }

    /// @author Denis M. Putnam
    /// @notice getNumberOfTeams
    /// @dev No further details
    /// @return teamCount
    function getNumberOfTeams() public view returns(uint) {
        return teamCount;
    }

    event ChooseTeamEvent(uint team, string boyName, string girlName, bool timedOut, bool chooseTeamFlag, bool checkTeamFlag);
    
    /// @author Denis M. Putnam
    /// @notice Choose a team to play
    /// @dev No further details
    /// @param team number
    function chooseTeam(uint team) public {
       require(chooseTeamFlag == true, "You cannot choose a team yet");
       teamNumber = team;
       startTime = now; 
       endTime = 5 minutes;
       timedOut = false;
       chooseTeamFlag = false;
       checkTeamFlag = true;
       string memory boyName = teams[team].male.name;
       string memory girlName = teams[team].female.name;
       emit ChooseTeamEvent(teamNumber, boyName, girlName, timedOut, chooseTeamFlag, checkTeamFlag);
    }

    event TimeoutEvent(uint team, string boyName, bool boyAlive, string girlName, bool girlAlive);
    event TimeoutFlagEvent(bool timedOut);

    /// @author Denis M. Putnam
    /// @notice This modifier checks for the team time out.
    /// @dev dead or alive is reandomly determined.
    modifier checkTimeOutModifier() {
        uint256 currentTime = now;
        if(currentTime > startTime + endTime) {
            timedOut = true;
            chooseTeamFlag = true;
        } else {
            timedOut = false;
            chooseTeamFlag = false;
        }
        emit TimeoutFlagEvent(timedOut);
        _;
    }

    /// @author Denis M. Putnam
    /// @notice Check the life of the team
    /// @dev No further details
    /// @return teamNum
    /// @return boyName
    /// @return boyAlive
    /// @return girlName
    /// @return girlAlive
    function checkTeam() public checkTimeOutModifier() returns(uint teamNum, string memory boyName, bool boyAlive, string memory girlName, bool girlAlive) {
        //emit TimeoutFlagEvent(timedOut);
        require(checkTeamFlag == true, "Team has not been chosen yet");
        require(timedOut == true, "Clock is still ticking");
        timedOut = false;
        teamNum = teamNumber;
        boyName = teams[teamNum].male.name;
        girlName = teams[teamNum].female.name;
        teams[teamNum].male.alive = rand.pseudoRandom(0,1);
        teams[teamNum].female.alive = rand.pseudoRandom(0,1);
        if(teams[teamNum].male.alive == 0) {
            boyAlive = false;
        } else {
            boyAlive = true;
        }
        if(teams[teamNum].female.alive == 0) {
            girlAlive = false;
        } else {
            girlAlive = true;
        }
        emit TimeoutEvent(teamNum, boyName, boyAlive, girlName, girlAlive);
    }

    /// @author Denis M. Putnam
    /// @notice Check the life of the team regardless of time out.
    /// @dev No further details
    /// @param team number
    /// @return teamNum
    /// @return boyName
    /// @return boyAlive
    /// @return girlName
    /// @return girlAlive
    function checkTeamResults(uint team) public view returns(uint teamNum, string memory boyName, bool boyAlive, string memory girlName, bool girlAlive) {
        require(checkTeamFlag == true, "Team has not been chosen yet");
        //require(timedOut == true, "Clock is still ticking");
        teamNum = team;
        boyName = teams[teamNum].male.name;
        girlName = teams[teamNum].female.name;
        if(teams[teamNum].male.alive == 0) {
            boyAlive = false;
        } else {
            boyAlive = true;
        }
        if(teams[teamNum].female.alive == 0) {
            girlAlive = false;
        } else {
            girlAlive = true;
        }
    }

    /// @author Denis M. Putnam
    /// @notice Get time left
    /// @dev No further details.
    /// @return timeLeft
    function getTimeLeft() view public returns (int256 timeLeft) {
        uint256 currentTime = now;
        if(int256((startTime + endTime) - currentTime) > 0){
            timeLeft = int256((startTime + endTime) - currentTime);
        } else {
            timeLeft = 0;
        }
    }
}

/// @title Problem 5. InsecureRandomGenerator
/// @author Denis M. Putnam
/// @notice This contract establishes the owner and allows for an owner change.
/// @dev Use at your own risk.
contract InsecureRandomGenerator {
    bytes32 public randseed;

    /// @author Denis M. Putnam
    /// @notice Generate a pseudo random number
    /// @dev No further details
    /// @param start number
    /// @param end number
    /// @return randVal
    function pseudoRandom(uint start, uint end) public returns (uint256) {
        randseed = keccak256(abi.encodePacked( randseed, block.timestamp, block.coinbase, block.difficulty, block.number));
        uint range = end - start + 1;
        uint randVal = start + uint256(randseed) % range;
        return randVal;    
    }
}