// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ServiceAgreement.sol";

contract ServiceAgreementFactory {
    ServiceAgreement[] public agreements;
    address public owner;

    constructor(address _initialOwner) {
        owner = _initialOwner;
    }

    function createAgreement(
        address _serviceProvider,
        address _client,
        uint256 _agreedValue,
        uint256 _startDate,
        uint256 _deliveryDate,
        string memory _serviceDescription,
        string memory _contractHash
    ) public {
        require(msg.sender == owner, "Only owner can create agreements");
        ServiceAgreement newAgreement = new ServiceAgreement(
            address(this), // O contrato de fábrica é o initialOwner
            _serviceProvider,
            _client,
            _agreedValue,
            _startDate,
            _deliveryDate,
            _serviceDescription,
            _contractHash
        );
        agreements.push(newAgreement);
    }

    function updateAgreement(
        uint index,
        uint256 _agreedValue,
        uint256 _deliveryDate,
        string memory _serviceDescription,
        string memory _contractHash
    ) public {
        require(msg.sender == owner, "Only owner can update agreements");
        require(index < agreements.length, "Invalid agreement index");
        agreements[index].updateAgreementDetails(
            _agreedValue,
            _deliveryDate,
            _serviceDescription,
            _contractHash
        );
    }

    function completeAgreement(uint index) public {
        require(msg.sender == owner, "Only owner can complete agreements");
        require(index < agreements.length, "Invalid agreement index");
        agreements[index].completeAgreement();
    }

    function getAgreements() public view returns (ServiceAgreement[] memory) {
        return agreements;
    }
}