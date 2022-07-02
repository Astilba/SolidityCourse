// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./MinistryEducationScienceRF.sol";
import "./SchoolLesson.sol";

error SchoolManagement__NewOwnerHasInvalidAddress();
error SchoolManagement__NewSchoolNameIsTooShort();
error SchoolManagement__LessonAlreadyExists();
error SchoolManagement__LessonNameIsTooShort();

contract SchoolManagement {

    MinistryEducationScienceRF private i_ministryContract;
    address public s_school;
    string public s_name;

    struct Lesson {
        uint256 id;
        string name;
        address[] teachers;
    }

    address[] public s_lessonAddresses;
    mapping(address => Lesson) public s_lessons;

    event SchoolSetted(address indexed _owner);
    event SchoolNameSetted(string indexed _name);
    event LessonAdded(string indexed _name);

    constructor(address _owner, string _name, address _ministry) {
        s_school = _owner;
        s_name = _name;
        i_ministryContract = MinistryEducationScienceRF(_ministry);
        emit SchoolSetted(_owner);
        emit SchoolNameSetted(_name);
    }

    modifier onlySchool {
        require(msg.sender == s_school, "You are not the school!");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`_newSchool`).
     * Can only be called by the current owner.
     */
    function setSchool(address _newSchool) external onlyMinistry {
        if (_newSchool == address(0)) {
            revert SchoolManagement__NewOwnerHasInvalidAddress();
        }
        s_school = _newSchool;
        emit SchoolSetted(_newSchool);
    }

    /**
     * @dev Sets the new school name.
     * Can only be called by the current owner.
     */
    function setName(string _newName) external onlyMinistry {
        if (i_ministryContract.strLength(_newName) <= 5) {
            revert SchoolManagement__NewSchoolNameIsTooShort();
        }
        s_name = _newName;
        emit SchoolNameSetted(_newName);
    }

    /**
     * @dev Creates the new SchoolLesson contract.
     * '_name' - the name of the new lesson.
     * Can only be called by the current owner.
     */
    function addLesson(string _name) external onlySchool {

        if (i_ministryContract.strLength(_name) <= 5) {
            revert SchoolManagement__LessonNameIsTooShort();
        }

        uint256 size = s_lessons.length;
        for(uint256 i; i < size; ++i) {
            if (s_lessons[s_lessonAddresses[i]].name == _name) {
                revert SchoolManagement__LessonAlreadyExists();
            }
        }
        address newLesson = address(new SchoolLesson(address(this), _name));
        SchoolLesson memory tmp = SchoolLesson({
            id: size,
            name: _name,
            teachers: address[]
        });
        s_lessonAddresses.push(newLesson);
        s_lessons[newLesson] = tmp;
        emit LessonAdded(_name);
    }

}
