// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FirstToHash {
    address public owner;
    IERC20 public airdropToken;

    mapping(string => mapping(string => mapping(uint256 => bool))) claimed;
    mapping(address => bytes32) public addressToIdentity;

    mapping(bytes32 => uint256) public airdrops;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _airdropToken) {
        owner = msg.sender;
        airdropToken = IERC20(_airdropToken);
    }

    function updateToken(address newToken) external onlyOwner {
        airdropToken = IERC20(newToken);
    }

    // suffix to be used to differentiate people with same first and last name
    function claimIdentity(
        string memory _firstName,
        string memory _lastName,
        uint256 _suffix
    ) external {
        bytes32 identity = keccak256(
            abi.encodePacked(_firstName, _lastName, _suffix)
        );

        require(
            !claimed[_firstName][_lastName][_suffix],
            "Identity already claimed, change suffix"
        );
        require(
            addressToIdentity[msg.sender] == bytes32(0x0),
            "Sender already has an identity"
        );

        claimed[_firstName][_lastName][_suffix] = true;
        addressToIdentity[msg.sender] = identity;
    }

    function transferAirdropTo(address newOwner, uint256 amount) external {
        bytes32 callerIdentity = addressToIdentity[msg.sender];
        require(callerIdentity != bytes32(0x0), "No identity for that caller");
        require(airdrops[callerIdentity] >= amount, "No airdrop available");

        bytes32 newOwnerIdentity = addressToIdentity[newOwner];
        require(
            newOwnerIdentity != bytes32(0x0),
            "New Owner doesn't have claimed identity"
        );

        airdrops[callerIdentity] -= amount;
        airdrops[newOwnerIdentity] += amount;
    }

    function claimAirdrop() external {
        bytes32 callerIdentity = addressToIdentity[msg.sender];
        require(callerIdentity != bytes32(0x0), "No identity for that caller");

        uint256 tokensToAirdrop = airdrops[callerIdentity];
        require(tokensToAirdrop != 0, "No airdrop available");

        airdrops[callerIdentity] = 0;
        airdropToken.transfer(msg.sender, tokensToAirdrop);
    }

    function airdropTo(bytes32 identity, uint256 amount) external onlyOwner {
        airdropToken.transferFrom(msg.sender, address(this), amount);
        airdrops[identity] = amount;
    }
}

contract ERC20Token is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, totalSupply);
    }
}
