pragma solidity 0.4.24;

contract OfferContract {

    using SafeMath for uint256;

    enum OfferStatus { New, Accepted, Booked }
    OfferStatus status;

    mapping (address => uint) newProposedPrices;
    mapping (address => uint) bookedAt;

    address public owner;
    address public bookedFor;

    uint public price;
    uint public activeDuration;
    uint public creationDate;
    uint public bookingTime = 30 minutes;

    event AgreementCreated(address tenant, address landlord, uint price);
    event OfferPriceChangeRequested(address by, uint newPrice);
    event PriceChangeRequestAccepted(address from, uint newPrice);

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    modifier onlyInActiveDuration() { 
        require(creationDate.add(activeDuration) >= block.timestamp); 
        _; 
    }
    
    constructor (uint _price, uint _activeDuration){
        require(_activeDuration > 0);

        owner = msg.sender;
        price = _price;
        creationDate = block.timestamp;
        activeDuration = _activeDuration.mul(1 days);
    }

    function acceptOffer() public onlyInActiveDuration {
        require(msg.sender != owner);
        require(status == OfferStatus.New || status == OfferStatus.Booked);

        if(status == OfferStatus.Booked && bookedAt[bookedFor].add(bookingTime) >= block.timestamp){
            require(msg.sender == bookedFor);
        }
        
        //AgreementContract agreement = new AgreementContract(msg.sender, owner, price);
        emit AgreementCreated(msg.sender, owner);
        status = OfferStatus.Accepted;
    }

    function priceChangeRequest(uint _newPrice) public onlyInActiveDuration {
        newProposedPrices[msg.sender] = _newRentPrice;
        emit OfferPriceChangeRequested(msg.sender, _newRentPrice);
    }

    function acceptPriceChangeRequestFrom(address _tenant) public onlyOwner onlyInActiveDuration {
        require(newProposedPrices[_tenant] > 0);
        price = newProposedPrices[_tenant];
        emit PriceChangeRequestAccepted(_tenant, price);

        status = OfferStatus.Booked;
        bookedAt[_tenant] = block.timestamp;
        bookedFor = _tenant;
        activeDuration.add(2 hours);
    }
    
}