// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ServiceAgreement is Ownable {
    struct Agreement {
        address serviceProvider;
        address client;
        uint256 agreedValue;
        uint256 startDate;
        uint256 deliveryDate;
        string serviceDescription;
        bool isCompleted;
        string contractHash; // Hash do contrato real, judiciário
        uint256 creationTimestamp; // Data e hora de criação do contrato
    }

    Agreement public agreement;

    constructor(
        address _initialOwner,
        address _serviceProvider,
        address _client,
        uint256 _agreedValue,
        uint256 _startDate,
        uint256 _deliveryDate,
        string memory _serviceDescription,
        string memory _contractHash
    ) Ownable(_initialOwner) {
        agreement.serviceProvider = _serviceProvider;
        agreement.client = _client;
        agreement.agreedValue = _agreedValue;
        agreement.startDate = _startDate;
        agreement.deliveryDate = _deliveryDate;
        agreement.serviceDescription = _serviceDescription;
        agreement.contractHash = _contractHash;
        agreement.creationTimestamp = block.timestamp;
        agreement.isCompleted = false;
    }

    function completeAgreement() public onlyOwner {
        require(!agreement.isCompleted, "Agreement already completed");
        require(block.timestamp >= agreement.deliveryDate, "Delivery date not reached");
        agreement.isCompleted = true;
        // Additional logic to complete the agreement, such as transferring funds, etc.
    }

    function updateAgreementDetails(
        uint256 _agreedValue,
        uint256 _deliveryDate,
        string memory _serviceDescription,
        string memory _contractHash
    ) public onlyOwner {
        agreement.agreedValue = _agreedValue;
        agreement.deliveryDate = _deliveryDate;
        agreement.serviceDescription = _serviceDescription;
        agreement.contractHash = _contractHash;
    }

    function getAgreementDetails() public view returns (
        address,
        address,
        uint256,
        uint256,
        uint256,
        string memory,
        bool,
        string memory,
        uint256
    ) {
        return (
            agreement.serviceProvider,
            agreement.client,
            agreement.agreedValue,
            agreement.startDate,
            agreement.deliveryDate,
            agreement.serviceDescription,
            agreement.isCompleted,
            agreement.contractHash,
            agreement.creationTimestamp
        );
    }
}