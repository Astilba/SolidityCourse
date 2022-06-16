// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Factory {

    enum FileType{ Vaccination, PCR }
    mapping(bytes32 => bytes32) private s_userCertificate;

    event AddCertificate(bytes32 passport, bytes32 hash);

    function hash(string memory _text) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_text));
    }

    function hashPassport(uint64 _passport) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_passport));
    }

    function addCertificate(uint64 _passport, bytes32 _hash) external {
        bytes32 passport = hashPassport(_passport);
        s_userCertificate[passport] = _hash;
        emit AddCertificate(passport, _hash);
    }
}
