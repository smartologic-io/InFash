pragma solidity 0.5.2;

import "./AgreementContract.sol";

contract OfferContract {

    using SafeMath for uint256;

    enum OfferStatus { New, Accepted, Booked }
    OfferStatus status;

    mapping (address => string) newProposedConditions;
    mapping (address => uint) bookedAt;

    address public owner;
    address public bookedFor;

    string public conditions;
    uint public activeDuration;
    uint public creationDate;
    uint public bookingTime = 30 minutes;

    event AgreementCreated(address retailer, address customer, string conditions);
    event OfferConditionsChangeRequested(address by, string newConditions);
    event ConditionsChangeRequestAccepted(address from, string newConditions);

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    modifier onlyInActiveDuration() { 
        require(creationDate.add(activeDuration) >= block.timestamp); 
        _; 
    }
    
    constructor (string memory _conditions, uint _activeDuration) public {
        require(_activeDuration > 0);

        owner = msg.sender;
        conditions = _conditions;
        creationDate = block.timestamp;
        activeDuration = _activeDuration.mul(1 days);
    }

    function acceptOffer() public onlyInActiveDuration {
        require(msg.sender != owner);
        require(status == OfferStatus.New || status == OfferStatus.Booked);

        if(status == OfferStatus.Booked && bookedAt[bookedFor].add(bookingTime) >= block.timestamp){
            require(msg.sender == bookedFor);
        }
        
        //AgreementContract agreement = new AgreementContract(msg.sender, owner, conditions);
        emit AgreementCreated(owner, msg.sender, conditions);
        status = OfferStatus.Accepted;
    }

    function conditionsChangeRequest(string memory _conditions) public onlyInActiveDuration {
        newProposedConditions[msg.sender] = _conditions;
        emit OfferConditionsChangeRequested(msg.sender, _conditions);
    }

    function acceptConditionsChangeRequestFrom(address _tenant) public onlyOwner onlyInActiveDuration {
        require(bytes(newProposedConditions[_tenant]).length > 0);
        conditions = newProposedConditions[_tenant];
        emit ConditionsChangeRequestAccepted(_tenant, conditions);

        status = OfferStatus.Booked;
        bookedAt[_tenant] = block.timestamp;
        bookedFor = _tenant;
        activeDuration.add(2 hours);
    }
    
}