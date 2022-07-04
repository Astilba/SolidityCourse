// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "\MinistryEducationScienceRF.sol";
import "\SchoolManagement.sol";
import "\ISchoolLesson.sol";

error SchoolLesson__NewSchoolHasInvalidAddress();
error SchoolLesson__TheTeacherHasAlreadyBeenAdded();
error SchoolLesson__TheTeacherHasNotBeenAdded();
error SchoolLesson__TheRequestHasAlreadyBeenAdded();

contract SchoolLesson is ISchoolLesson {
    SchoolManagement private s_school;
    string private s_name;
    address[] public s_teacherAddresses;
    mapping(address => bool) private s_teachers;
    mapping(bytes32 => uint256) private s_assessments;
    ExamReview[] private s_examReviews;
    mapping(string => bool) s_examReviewStatuses;

    event StudentRated(bytes32 _studentHash, uint256 _assessment);
    event TeacherSetted(address indexed _teacher);
    event TeacherRemoved(address indexed _teacher);
    event SchoolSetted(address indexed _school);
    event ExamReviewRequestAdded(uint256 indexed _requestId, string indexed _fio);
    event ExamReviewed(uint256 indexed _requestId);

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
    function showMark(string _fio, string _passport) external view returns(uint256) {
        return s_assessments[s_school.getStudentHash(_fio, _passport)];
    }

    /**
     * @dev Create the new request for review of the assessment.
     * '_fio' - the student data.
     */
    function examReviewRequest(string _fio) external {
        if (s_examReviewStatuses[_fio] == true) {
            revert SchoolLesson__TheRequestHasAlreadyBeenAdded();
        }
        uint256 size = s_examReviews.length;
        ExamReview memory tmp = ExamReview({
            id: size,
            fio: _fio
        });
        ExamReview.push(tmp);
        s_examReviewStatuses[_fio] = true;
        emit ExamReviewRequestAdded(size, _fio);
    }

    /**
     * @dev Returns the list of student requests.
     * Can only be called by the teacher.
     */
    function viewingStudentRequested() external view onlyTeacher returns(ExamReview[]) {
        return s_examReviews;
    }

    /**
     * @dev Updates status of the exam review request.
     * '_id' - the exam review request id.
     * Can only be called by the teacher.
     */
    function examReview(uint256 _id) external onlyTeacher {
        string memory fio = s_examReviews[_id].fio;
        s_examReviewStatuses[fio] = false;
        emit ExamReviewed(_id);
    }

    /**
     * @dev Adds or updates the student mark.
     * '_fio', '_passport' - the student data.
     * '_mark' - the new mark.
     * Can only be called by the teacher.
     */
    function rateStudent(string _fio, string _passport, uint256 _mark) external onlyTeacher {
        bytes32 studentHash = s_school.getStudentHash(_fio, _passport);
        s_assessments[studentHash] = _mark;
        emit StudentRated(studentHash, _mark);
    }

    /**
     * @dev Adds the new teacher.
     * '_teacher' - the new teacher address.
     * Can only be called by the school.
     */
    function setTeacher(address _teacher) external onlySchool {
        if (s_teachers[_teacher] == true) {
            revert SchoolLesson__TheTeacherHasAlreadyBeenAdded();
        }
        s_teacherAddresses.push(_teacher);
        s_teachers[_teacher] = true;
        emit TeacherSetted(_teacher);
    }

    /**
     * @dev Removes the teacher.
     * '_teacher' - the teacher address.
     * Can only be called by the school.
     */
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

    /**
    * @dev Updates the school.
    * '_newSchool' - address of the new school contract.
    * Can only be called by the school.
    */
    function setSchool(address _newSchool) external onlySchool {
        if (_newSchool == address(0)) {
            revert SchoolLesson__NewSchoolHasInvalidAddress();
        }
        s_school = SchoolManagement(_newSchool);
        emit SchoolSetted(_newSchool);
    }
}
