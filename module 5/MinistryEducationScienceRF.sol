// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./SchoolManagement.sol";

error MinistryEducationScienceRF__NewMinistryHasInvalidAddress();
error MinistryEducationScienceRF__SchoolOwnerHasInvalidAddress();
error MinistryEducationScienceRF__NameOfSchoolIsTooShort();

// Контракт которым управляет Министерство образования и науки Российской Федерации.
// Данный контракт позволяет создавать школы для последующего аудита и прозрачности в проставление оценок и выдаче дипломов.
contract MinistryEducationScienceRF {

    struct School{
        uint256 id;
        address owner;
        string name;
    }

    address public s_ministry;
    address[] public s_schoolAddresses;
    mapping(address => School) public s_schools;

    event MinistrySetted(address indexed _ministry);
    event SchoolAdded(string indexed _name, address indexed _contractAddress, address indexed _owner);

    constructor(address _ministry) {
        s_ministry = _ministry;
        emit MinistrySetted(_ministry);
    }

    modifier onlyMinistry {
        require(msg.sender == s_ministry, "You do not have permission to run this function. Only ministry allowed.");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`_newMinistry`).
     * Can only be called by the current owner.
     */
    function setMinistry(address _newMinistry) external onlyMinistry {
        if (_newMinistry == address(0)) {
            revert MinistryEducationScienceRF__NewMinistryHasInvalidAddress();
        }
        s_ministry = _newMinistry;
        emit MinistrySetted(_newMinistry);
    }

    /**
     * @dev Creates the new SchoolManagement contract.
     * '_schoolOwner' - the owner of the child contract, '_name' - the name of the new school.
     * Can only be called by the current owner.
     */
    function addSchool(address _schoolOwner, string _name) external onlyMinistry {
        if (_schoolOwner == address(0)) {
            revert MinistryEducationScienceRF__SchoolOwnerHasInvalidAddress();
        }

        if (strLength(_name) <= 5) {
            revert MinistryEducationScienceRF__NameOfSchoolIsTooShort();
        }

        uint256 schoolId = s_schoolAddresses.length;
        address newContract = address(new SchoolManagement(_schoolOwner, _name, address(this)));
        School memory tmp = Child({
            id: schoolId,
            owner: _schoolOwner,
            name: _name
        });
        s_schoolAddresses.push(newContract);
        s_schools[newContract] = tmp;
        emit SchoolAdded(_name, newContract, _schoolOwner);
    }

    function strLength(string memory _text) public pure returns(uint256) {
        bytes memory res = abi.encodePacked(_text);
        return res.length;
    }

}
