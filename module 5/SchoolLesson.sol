// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "\MinistryEducationScienceRF.sol";
import "\SchoolManagement.sol";

contract SchoolLesson {
    SchoolManagement i_school;
    string i_name;
    mapping(address => bool) s_teachers;
    mapping(bytes32 => uint256) private s_assessments;

    event StudentRated(bytes32 _studentHash, uint256 _assessment);

    constructor(address _school, string _name) {
        i_school = SchoolManagement(_school);
        i_name = _name;
    }

    modifier onlyTeacher {
        require(s_teachers[msg.sender] == true, "You are not a teacher!");
        _;
    }

    modifier onlySchool {
        require(msg.sender == address(i_school), "You are not a school!");
        _;
    }

    function showMark(string _fio, string _passport) external view returns(uint256){
        return s_assessments[getStudentHash(_fio, _passport)];
    }

    function examReviewRequest(string _fio, string _passport) external returns(bool){

        return true;
    }

    function rateStudent(string _fio, string _passport, uint256 _assessment) external onlyTeacher {
        bytes32 studentHash = getStudentHash(_fio, _passport);
        s_assessments[studentHash] = _assessment;
        emit StudentRated(studentHash, _assessment);
    }

    function getStudentHash(string _fio, string passport) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_fio, _passport));
    }
}
