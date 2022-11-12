//// SPDX-License-Identifier: MIT
// contracts/BuyMeACoffee.sol

pragma solidity ^0.8.0;

// Example contract address on Goerli: 

contract BuyMeACoffee {
  // Event when memo is created
  event NewMemo(
    address indexed from,
    uint256 timestamp,
    string name,
    string message
  );

  event OwnershipTransfer(
    address indexed from,
    address indexed to,
    uint256 timestamp
  );

  struct Memo {
    address from;
    uint256 timestamp;
    string name;
    string message;
  }

  // Address of contract deployer
  address payable owner;

  // List of memos received
  Memo[] memos;

  constructor () public {
    owner = payable(msg.sender);
  }

  // return all memos
  function getMemos() public view returns (Memo[] memory) {
    return memos;
  }

  function buyCoffee(string memory _name, string memory _message) public payable {
    require(msg.value > 0, "Must pay more than 0 for a coffee!");
    
    memos.push(Memo(msg.sender, block.timestamp, _name, _message));

    emit NewMemo(msg.sender, block.timestamp, _name, _message);
  }

  function buyLargeCoffee(string memory _name, string memory _message) public payable {
    require(msg.value >= 0.003 ether, "Must pay at least 0.003 for a large coffee!");
    
    memos.push(Memo(msg.sender, block.timestamp, _name, _message));

    emit NewMemo(msg.sender, block.timestamp, _name, _message);
 
  }

  function transferOwnership(address payable _to) public {
    require(_to == address(_to), "Valid address required");
    require(!isContract(_to), "Can only transfer ownership to accounts, not smart contracts");
    require(_to != owner, "Can't transfer ownership to yourself!");

    address oldOwner = owner;
    owner = _to;
    emit OwnershipTransfer(oldOwner, owner, block.timestamp);
  }

  function getOwner() public view returns (address) {
    return owner;
  }

  function isContract(address _add) private view returns (bool) {
    uint size;
    assembly {
      size := extcodesize(_add)
    }

    return size > 0;
  }

  function withdrawTips() public {
    require(owner.send(address(this).balance));
  }
}
