pragma solidity ^0.8.0;

interface ISchoolLesson {

    struct ExamReview {
        string fio;
        bool status;
    }

    function showMark(string _fio, string _passport) external view returns(uint256);
    function examReviewRequest(string _fio) external returns(bool);
    function rateStudent(string _fio, string _passport, uint256 _mark) external;
    function viewingStudentRequested() external view returns(ExamReview[]);
    function setTeacher(address _teacher) external;
    function removeTeacher(address _teacher) external;
    function setSchool(address _school) external;
}
