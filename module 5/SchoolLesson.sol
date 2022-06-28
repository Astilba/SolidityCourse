// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "\MinistryEducationScienceRF.sol";
import "\SchoolManagement.sol";
import "\ISchoolLesson.sol";

error SchoolLesson__NewSchoolHasInvalidAddress();
error SchoolLesson__TheTeacherHasAlreadyBeenAdded();
error SchoolLesson__TheTeacherHasNotBeenAdded();

contract SchoolLesson is ISchoolLesson {
    SchoolManagement private s_school;
    string private s_name;
    address[] public s_teacherAddresses;
    mapping(address => bool) private s_teachers;
    mapping(bytes32 => uint256) private s_assessments;
    ExamReview[] private s_examReviews;

    event StudentRated(bytes32 _studentHash, uint256 _assessment);
    event TeacherSetted(address indexed _teacher);
    event TeacherRemoved(address indexed _teacher);
    event SchoolSetted(address indexed _school);

    constructor(address _school, string _name) {
        s_school = SchoolManagement(_school);
        s_name = _name;
        emit SchoolSetted(_school);
    }

    modifier onlyTeacher {
        require(s_teachers[msg.sender] == true, "You are not a teacher!");
        _;
    }

    modifier onlySchool {
        require(msg.sender == address(s_school), "You are not a school!");
        _;
    }

    function showMark(string _fio, string _passport) external view returns(uint256) {
        return s_assessments[getStudentHash(_fio, _passport)];
    }

    function examReviewRequest(string _fio) external returns(bool) {
        ExamReview memory tmp = ExamReview({
            fio: _fio,
            status: false
        });
        ExamReview.push(tmp);
        return true;
    }

    function viewingStudentRequested() external view onlyTeacher returns(ExamReview[]) {
        return s_examReviews;
    }

    function rateStudent(string _fio, string _passport, uint256 _mark) external onlyTeacher {
        bytes32 studentHash = getStudentHash(_fio, _passport);
        s_assessments[studentHash] = _mark;
        emit StudentRated(studentHash, _mark);
    }

    function getStudentHash(string _fio, string _passport) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_fio, _passport));
    }

    function setTeacher(address _teacher) external onlySchool {
        if (s_teachers[_teacher] == true) {
            revert SchoolLesson__TheTeacherHasAlreadyBeenAdded();
        }
        s_teacherAddresses.push(_teacher);
        s_teachers[_teacher] = true;
        emit TeacherSetted(_teacher);
    }

    function removeTeacher(address _teacher) external onlySchool {
        if (s_teachers[_teacher] == false) {
            revert SchoolLesson__TheTeacherHasNotBeenAdded();
        }
        uint256 size = s_teacherAddresses.length;
        for (i; i < size; i++) {
            if (s_teacherAddresses[i] == _teacher) {
                s_teacherAddresses[i] = s_teacherAddresses[size - 1];
                s_teacherAddresses.pop();
                break;
            }
        }
        s_teachers[_teacher] = false;
        emit TeacherRemoved(_teacher);
    }

    function setSchool(address _newSchool) external onlySchool {
        if (_newSchool == address(0)) {
            revert SchoolLesson__NewSchoolHasInvalidAddress();
        }
        s_school = _newSchool;
        emit SchoolSetted(_newSchool);
    }
}
