// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./SchoolLib.sol";

interface ISchoolLesson {

    event StudentEvaluated(bytes32 indexed _studentHash, uint256 _assessment);
    event TeacherSetted(address indexed _teacher);
    event TeacherRemoved(address indexed _teacher);
    event SchoolSetted(address indexed _school);
    event ExamReviewRequestAdded(string indexed _fio);
    event ExamReviewed(string indexed _fio);

    function showMark(string memory _fio, string memory _passport) external view returns(SchoolLib.MarkInfo memory);
    function examReviewRequest(string memory _fio) external;
    function rateStudent(string memory _fio, string memory _passport, uint256 _mark) external;
    function viewingStudentRequested() external view returns(string[] memory);
    function setTeacher(address _teacher) external;
    function removeTeacher(address _teacher) external;
    function setSchool(address _school) external;
}
