pragma solidity 0.5.2;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract AgreementContract {
    
    using SafeMath for uint256;

    enum AgreementStatus { New, Signed, Declined, Terminated }
    AgreementStatus status;

    string public declineReason;
    string public conditions;

    address public model;
    address public owner;

    uint public agreementCreated;
    uint month = 30 days;

    bool signedByOwner;
    bool signedByModel;

    event AgreementSigned(address by);
    event AgreementDeclined(address by, string reason);

    modifier onlyModelOrOwner() { 
        require(msg.sender == owner || msg.sender == model); 
        _; 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    modifier onlyAfterPeriodExpired() { 
        require (agreementCreated.add(month) <= block.timestamp); 
        _; 
    }

    modifier onlyNew() { 
        require(status == AgreementStatus.New); 
        _; 
    }
    
    modifier onlySigned() { 
        require(status == AgreementStatus.Signed); 
        _; 
    }

    constructor(address _model, address _owner, string memory _conditions) public {
        model = _model;
        owner = _owner;
        conditions = _conditions;
        agreementCreated = block.timestamp;
        status = AgreementStatus.New;
    }

    function signAgreement() public onlyModelOrOwner onlyNew {
        if(msg.sender == model) {
            require(signedByOwner == false);
            signedByOwner = true;
            emit AgreementSigned(msg.sender);
            if(signedByModel == true){
                status = AgreementStatus.Signed;
                
            }
        } else {
            require(signedByModel== false);
            signedByModel = true;
            emit AgreementSigned(msg.sender);
            if(signedByOwner == true){
                status = AgreementStatus.Signed;
               
            }
        }
    }

    function declineAgreement(string calldata _reason) external onlyModelOrOwner onlyNew {
        require (status!=AgreementStatus.Declined);
        
        declineReason = _reason;
        status = AgreementStatus.Declined;
        emit AgreementDeclined(msg.sender, _reason);
    }

    function terminateAgreement() external onlyOwner onlySigned {
      require(status == AgreementStatus.Signed);
      
      status = AgreementStatus.Terminated;
    }

    function extendAgreement(string memory _newConditions) public onlyOwner {
        require(status == AgreementStatus.Signed);
        require(bytes(_newConditions).length > 0);

        agreementCreated = block.timestamp;
        
        signedByModel = false;
        signedByOwner = false;

        conditions = _newConditions;

        status = AgreementStatus.New;
    } 
}