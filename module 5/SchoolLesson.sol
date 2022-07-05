// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./MinistryEducationScienceRF.sol";
import "./SchoolManagement.sol";
import "./ISchoolLesson.sol";
import "./SchoolLib.sol";

error SchoolLesson__NewSchoolHasInvalidAddress();
error SchoolLesson__TheTeacherHasAlreadyBeenAdded();
error SchoolLesson__TheTeacherHasNotBeenAdded();
error SchoolLesson__TheRequestHasAlreadyBeenAdded();

contract SchoolLesson is ISchoolLesson {
    SchoolManagement private s_school;
    string private s_name;
    mapping(address => bool) private s_teachers;
    mapping(bytes32 => SchoolLib.MarkInfo) private s_marks;
    string [] private s_examReviews;

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
        require(msg.sender == address(s_school.s_school()), "You are not a school!");
        _;
    }

    /**
     * @dev Returns the student mark.
     * '_fio', '_passport' - the student data.
     */
    function showMark(string memory _fio, string memory _passport) external view override returns(SchoolLib.MarkInfo memory) {
        SchoolLib.MarkInfo memory markStudent = s_marks[s_school.getStudentHash(_fio, _passport)];
        return markStudent;
    }

    /**
     * @dev Create the new request for review of the assessment.
     * '_fio' - the student data.
     */
    function examReviewRequest(string memory _fio) external override {
        uint256 size = s_examReviews.length;
        for (uint256 i; i < size; i++) {
            if (s_examReviews[i] == _fio) {
                revert SchoolLesson__TheRequestHasAlreadyBeenAdded();
            }
        }
        s_examReviews.push(_fio);
        emit ExamReviewRequestAdded(_fio);
    }

    /**
     * @dev Returns the list of student requests.
     * Can only be called by the teacher.
     */
    function viewingStudentRequested() external view override onlyTeacher returns(string[] memory) {
        return s_examReviews;
    }

    /**
     * @dev Updates status of the exam review request.
     * '_id' - the exam review request id.
     * Can only be called by the teacher.
     */
    function examReview(string memory _fio) external onlyTeacher {
        uint256 size = s_examReviews.length;
        for (uint256 i; i < size; i++) {
            if (s_examReviews[i] == _fio) {
                s_examReviews[i] = s_examReviews[size - 1];
                s_examReviews.pop();
                break;
            }
        }
        emit ExamReviewed(_fio);
    }

    /**
     * @dev Adds or updates the student mark.
     * '_fio', '_passport' - the student data.
     * '_mark' - the new mark.
     * Can only be called by the teacher.
     */
    function rateStudent(string memory _fio, string memory _passport, uint256 _mark) external override onlyTeacher {
        bytes32 studentHash = s_school.getStudentHash(_fio, _passport);
        if (s_marks[studentHash].timestamp == 0) {
            s_marks[studentHash] = SchoolLib.MarkInfo({
                mark: _mark,
                markReview: 0,
                timestamp: block.timestamp,
                timestampReview: 0,
                teacher: msg.sender,
                teacherReview: address(0),
                school: s_school
            });
        } else {
            s_marks[studentHash].markReview = _mark;
            s_marks[studentHash].timestampReview = block.timestamp;
            s_marks[studentHash].teacherReview = msg.sender;
        }
        emit StudentEvaluated(studentHash, _mark);
    }

    /**
     * @dev Adds the new teacher.
     * '_teacher' - the new teacher address.
     * Can only be called by the school.
     */
    function setTeacher(address _teacher) external override onlySchool {
        if (s_teachers[_teacher] == true) {
            revert SchoolLesson__TheTeacherHasAlreadyBeenAdded();
        }
        s_teachers[_teacher] = true;
        emit TeacherSetted(_teacher);
    }

    /**
     * @dev Removes the teacher.
     * '_teacher' - the teacher address.
     * Can only be called by the school.
     */
    function removeTeacher(address _teacher) external override onlySchool {
        if (s_teachers[_teacher] == false) {
            revert SchoolLesson__TheTeacherHasNotBeenAdded();
        }
        s_teachers[_teacher] = false;
        emit TeacherRemoved(_teacher);
    }

    /**
    * @dev Updates the school.
    * '_newSchool' - address of the new school contract.
    * Can only be called by the school.
    */
    function setSchool(address _newSchool) external override onlySchool {
        if (_newSchool == address(0)) {
            revert SchoolLesson__NewSchoolHasInvalidAddress();
        }
        s_school = SchoolManagement(_newSchool);
        emit SchoolSetted(_newSchool);
    }
}
