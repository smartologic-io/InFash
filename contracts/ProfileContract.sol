pragma solidity 0.4.25;

contract ProfileContract {
  address public profile;

  constructor() public {
   profile = msg.sender;
  }

}
