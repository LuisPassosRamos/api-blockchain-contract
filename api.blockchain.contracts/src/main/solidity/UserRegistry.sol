// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserRegistry {
    struct User {
        string name;
        string sensitiveInfo; // Deve ser criptografado ou armazenado de forma segura
        address wallet;
        uint256 creationTimestamp; // Data e hora de criação do usuário
    }

    mapping(address => User) public users;

    function registerUser(
        string memory _name,
        string memory _sensitiveInfo,
        address _wallet
    ) public {
        require(_wallet != address(0), "Invalid wallet address");
        users[_wallet] = User({
            name: _name,
            sensitiveInfo: _sensitiveInfo,
            wallet: _wallet,
            creationTimestamp: block.timestamp
        });
    }

    function getUser(address _wallet) public view returns (
        string memory,
        string memory,
        address,
        uint256
    ) {
        User memory user = users[_wallet];
        return (
            user.name,
            user.sensitiveInfo,
            user.wallet,
            user.creationTimestamp
        );
    }
}