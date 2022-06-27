// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

error SchoolManagement__NewOwnerHasInvalidAddress();
error SchoolManagement__LessonAlreadyExists();

contract SchoolManagement {

    address private i_ministryContract;
    address private s_owner;
    string private s_name;
    mapping(string => mapping(bytes32 => uint8)) private assessments;
    mapping(string => bool) private s_isLesson;
    mapping(string => address[]) private s_teachers;

    event OwnerSetted(address indexed _owner);
    event LessonAdded(string indexed _name);

    constructor(address _owner, string _name, address _ministry) {
        s_owner = _owner;
        s_name = _name;
        i_ministryContract = _ministry;
        emit OwnerSetted(_owner);
    }

    modifier onlyOwner {
        require(msg.sender == s_owner, "You are not an owner!");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) {
            revert SchoolManagement__NewOwnerHasInvalidAddress();
        }
        s_owner = _newOwner;
        emit OwnerSetted(_newOwner);
    }

    function setName(string _newName) external onlyOwner {

    }

    function addLesson(string _name) external onlyOwner {
        if (s_isLesson[_name] == true) {
            revert SchoolManagement__LessonAlreadyExists();
        }
        s_isLesson[_name] = true;
        emit LessonAdded(_name);
    }

    function getOwner() external view returns(address){
        return s_owner;
    }
}
