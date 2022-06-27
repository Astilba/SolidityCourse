// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "\SchoolManagement.sol";

error MinistryEducationScienceRF__NewMinistryHasInvalidAddress();
error MinistryEducationScienceRF__SchoolHasInvalidAddress();
error MinistryEducationScienceRF__NameOfSchoolIsTooShort();

contract MinistryEducationScienceRF {

    struct School{
        uint256 id;
        address owner;
        string name;
    }

    address private s_ministry;
    address[] private s_schoolAddresses;
    mapping(address => School) private s_schools;

    event MinistrySetted(address indexed _ministry);
    event SchoolAdded(address indexed _contractAddress, address indexed _owner);

    constructor(address _ministry) {
        s_ministry = _ministry;
        emit MinistrySetted(_ministry);
    }

    modifier onlyMinistry {
        require(msg.sender == s_ministry, "You are not a ministry!");
        _;
    }

    function setMinistry(address _newMinistry) external onlyMinistry {
        if (_newMinistry == address(0)) {
            revert MinistryEducationScienceRF__NewMinistryHasInvalidAddress();
        }
        s_ministry = _newMinistry;
        emit MinistrySetted(_newMinistry);
    }

    function addSchool(address _schoolOwner, string _name) external onlyMinistry returns(bool) {
        if (_schoolOwner == address(0)) {
            revert MinistryEducationScienceRF__SchoolHasInvalidAddress();
        }

        if (strLength(_name) <= 5) {
            revert MinistryEducationScienceRF__NameOfSchoolIsTooShort();
        }

        uint256 schoolId = s_schoolAddresses.length;
        address newContract = address(new SchoolManagement(_schoolOwner, _name, s_ministry));
        School memory tmp = Child({
            id: schoolId,
            owner: _schoolOwner,
            name: _name
        });
        s_schoolAddresses.push(newContract);
        s_schools[newContract] = tmp;
        emit SchoolAdded(newContract, _schoolOwner);
        return true;
    }

    function getMinistry() external view returns(address) {
        return s_ministry;
    }

    function strLength(string memory _text) internal pure returns(uint256) {
        bytes memory res = abi.encodePacked(_text);
        return res.length;
    }

}
