// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
  using Strings for uint256;
  using Counters for Counters.Counter;

  struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
  }

  Counters.Counter private _tokenIds;
  mapping(uint256 => Stats) public tokenIdToStats;

  constructor() ERC721 ("Chain Battles", "CBTLS") {}

  function random(uint number) private returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

  function generateCharacter(uint256 tokenId) public returns (string memory) {
    Stats memory stats = tokenIdToStats[tokenId];
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Nerd",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",stats.level.toString(),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",stats.speed.toString(),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",stats.strength.toString(),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",stats.life.toString(),'</text>',
        '</svg>'
    );

    return string(
      abi.encodePacked(
        "data:image/svg+xml;base64,",
        Base64.encode(svg)
      )
    );
  }

  function getTokenURI(uint256 tokenId) public returns (string memory) {
    bytes memory dataURI = abi.encodePacked(
      '{',
        '"name": "Chain Battles #', tokenId.toString(), '",',
        '"description": "Battles on chain",',
        '"image": "', generateCharacter(tokenId), '"',
      '}'
    );

    return string(
      abi.encodePacked(
        "data:application/json;base64,",
        Base64.encode(dataURI)
      )
    );
  }

  function mint() public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    tokenIdToStats[newItemId] = Stats(random(100), random(100), random(100), random(100));
    _setTokenURI(newItemId, getTokenURI(newItemId));
  }

  function train(uint256 tokenId) public {
    require(_exists(tokenId), "Token not found");
    require(ownerOf(tokenId) == msg.sender, "You cant level someone else's token");
    
    Stats memory currentStats = tokenIdToStats[tokenId];
    currentStats.level = currentStats.level + 1;
    currentStats.speed = currentStats.speed + random(3);
    currentStats.strength = currentStats.strength + random(3);
    currentStats.life = currentStats.life + random(5);
    tokenIdToStats[tokenId] = currentStats;
    _setTokenURI(tokenId, getTokenURI(tokenId));
  }
}
