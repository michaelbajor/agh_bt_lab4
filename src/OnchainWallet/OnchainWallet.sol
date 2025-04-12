// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Convert library to regular contract
contract WalletLib {
    event ProposalExecuted(uint256 indexed proposalId, address by);

    struct TransferProposal {
        bool _executed;
        address payable _recipient;
        uint256 _amount;
    }

    // Storage variables that match the main contract's layout
    bool _initialized;
    uint8 _numOwners;
    uint8 _minSignatures;
    uint256 _nextProposalId;
    address[] _owners;
    mapping(uint256 => TransferProposal) _proposals;
    mapping(uint256 => address[]) _agreedToProposal;

    function isOneOfOwners(address addr) public view returns (bool) {
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == addr) {
                return true;
            }
        }

        return false;
    }

    function didAddrVoteFor(
        address addr,
        uint256 proposalId
    ) public view returns (bool) {
        address[] memory agreedTo = _agreedToProposal[proposalId];
        for (uint i = 0; i < agreedTo.length; i++) {
            if (agreedTo[i] == addr) {
                return true;
            }
        }

        return false;
    }

    function getProposalById(
        uint256 proposalId
    ) public view returns (TransferProposal memory) {
        return _proposals[proposalId];
    }

    // No need for storage pointer when we're using delegatecall
    function getProposalByIdStorage(
        uint256 proposalId
    ) internal view returns (TransferProposal storage) {
        return _proposals[proposalId];
    }

    function initWallet(address[] memory owners, uint8 minSignatures) external {
        _initialized = true;
        _owners = owners;
        _minSignatures = minSignatures;
        _numOwners = uint8(owners.length);
        _nextProposalId = 1;
    }

    function proposeTransfer(address recipient, uint256 amount) external {
        require(isOneOfOwners(msg.sender), "Not owner");
        TransferProposal memory proposal = TransferProposal({
            _recipient: payable(recipient),
            _amount: amount,
            _executed: false
        });

        _proposals[_nextProposalId] = proposal;
        _agreedToProposal[_nextProposalId].push(msg.sender);

        _nextProposalId++;
    }

    function agreeToProposal(uint256 proposalId) external {
        require(isOneOfOwners(msg.sender), "Not owner");
        require(!didAddrVoteFor(msg.sender, proposalId), "Already voted");

        _agreedToProposal[proposalId].push(msg.sender);
    }

    function executeTransfer(uint256 proposalId) external {
        uint256 numAgreed = _agreedToProposal[proposalId].length;
        require(numAgreed >= _minSignatures, "Consensus not reached");

        TransferProposal storage proposal = getProposalByIdStorage(proposalId);
        require(!proposal._executed, "Already executed");
        proposal._executed = true;

        (bool success, ) = proposal._recipient.call{value: proposal._amount}(
            ""
        );
        require(success, "transfer failed");

        emit ProposalExecuted(proposalId, msg.sender);
    }

    function testDelegate(uint8 newVal) external {
        _numOwners = newVal;
    }
}

contract MultisigWallet {
    // Storage layout must match WalletLib for delegatecall to work correctly
    bool public _initialized;
    uint8 public _numOwners;
    uint8 public _minSignatures;
    uint256 public _nextProposalId;
    address[] public _owners;
    mapping(uint256 => WalletLib.TransferProposal) _proposals;
    mapping(uint256 => address[]) _agreedToProposal;

    // Address of the deployed WalletLib contract
    address public immutable walletLibAddress;

    struct WalletStorageView {
        bool _initialized;
        uint8 _numOwners;
        uint8 _minSignatures;
        uint256 _nextProposalId;
        address[] _owners;
    }

    constructor(
        address walletLib,
        address[] memory owners,
        uint8 minSignatures
    ) {
        walletLibAddress = walletLib;

        // Use delegatecall to initialize the wallet
        (bool success, ) = walletLibAddress.delegatecall(
            abi.encodeWithSignature(
                "initWallet(address[],uint8)",
                owners,
                minSignatures
            )
        );
        require(success, "Init failed");
    }

    function getStorageData() external view returns (WalletStorageView memory) {
        return
            WalletStorageView({
                _initialized: _initialized,
                _owners: _owners,
                _minSignatures: _minSignatures,
                _numOwners: _numOwners,
                _nextProposalId: _nextProposalId
            });
    }

    function getProposal(
        uint256 proposalId
    ) external view returns (WalletLib.TransferProposal memory) {
        return _proposals[proposalId];
    }

    function proposeTransfer(address recipient, uint256 amount) external {
        (bool success, ) = walletLibAddress.delegatecall(
            abi.encodeWithSignature(
                "proposeTransfer(address,uint256)",
                recipient,
                amount
            )
        );
        require(success, "Propose transfer failed");
    }

    function executeTransfer(uint256 proposalId) external {
        (bool success, ) = walletLibAddress.delegatecall(
            abi.encodeWithSignature("executeTransfer(uint256)", proposalId)
        );
        require(success, "Execute transfer failed");
    }

    function agreeToTransfer(uint256 proposalId) external {
        (bool success, ) = walletLibAddress.delegatecall(
            abi.encodeWithSignature("agreeToProposal(uint256)", proposalId)
        );
        require(success, "Agree to transfer failed");
    }

    fallback() external payable {
        // Unknown function, wire into implementation contract
        (bool success, ) = walletLibAddress.delegatecall(msg.data);
        require(success, "delegatecall fail");
    }

    receive() external payable {}
}
