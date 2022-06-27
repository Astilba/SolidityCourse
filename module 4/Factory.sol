// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "github.com/Astilba/SolidityCourse/blob/main/module%202/lesson_2_6.sol";

contract Factory is Ownable {

    event AddChild(address childOwner, address contractAddress);
    event ApproveRequest(address orgAddress);
    event UpdateCertificate(bytes32 fioPassportHash, CertificateType);

    uint256 constant public MIN_DEPOSIT = 1;
    enum CertificateType{ Vaccination, PCR }
    enum OrgType{ Clinic, Laboratory }

    struct Certificate {
        CertificateType certificateType;
        string certificateNumber;
        bool certificateStatus;
        string ipfsCID;
    }

    struct Child {
        uint256 id;
        address owner;
    }

    struct Org {
        OrgType orgType;
        string name;
        bool approved;
    }

    struct Client {
        bytes32 fioHash;
        bytes32 passportHash;
    }

    mapping(bytes32 => Certificate) private s_userCertificate;
    address[] public s_childAddresses;
    address[] public s_organisationAddresses;
    mapping(address => Child) public s_children;
    mapping(address => Org) public s_organisations;


    function addChild(address _childOwner) internal onlyOwner returns(bool) {
        uint256 childId = s_childAddresses.length;
        address newContract = address(new Organisation(childId, _childOwner, address(this)));
        Child memory tmp = Child({
            id: childId,
            owner: _childOwner
        });
        s_children[newContract] = tmp;
        s_childAddresses.push(newContract);
        emit AddChild(_childOwner, newContract);
        return true;
    }

    function addRequest(string memory _name, uint8 _type) external payable {
        OrgType orgType = OrgType.Clinic;
        if (_type == 1) {
            orgType = OrgType.Laboratory;
        }

        require(msg.value >= MIN_DEPOSIT, "Insufficient funds have been sent!");
        require(strLength(_name) > 5 , "Name of your organisation is too short. Request is cancelled.");
        Org memory tmp = Org({
            orgType: orgType,
            name: _name,
            approved: false
        });
        s_organisationAddresses.push(_msgSender());
        s_organisations[_msgSender()] = tmp;
    }

    function approveRequest(address _org) external onlyOwner returns(bool) {
        require(strLength(s_organisations[_org].name) > 0 , "Organisation not found. Approve is cancelled.");
        require(s_organisations[_org].approved == false, "This request is already approved.");
        s_organisations[_org].approved = true;
        bool res = addChild(_org);
        emit ApproveRequest(_org);
        return res;
    }

    function addCertificate(string memory _fio, uint64 _passport, uint8 _type, string memory _number,
        string memory _cid) external {
        CertificateType certType = CertificateType.Vaccination;
        if (_type == 1) {
            certType = CertificateType.PCR;
        }

        require(getRights(_msgSender()) == true, "Unauthorized access is prohibited");
        bytes32 fioHash = keccak256(abi.encodePacked(_fio, _passport, _type));
        Certificate memory tmp = Certificate({
            certificateType: certType,
            certificateNumber: _number,
            certificateStatus: true,
            ipfsCID: _cid
        });
        s_userCertificate[fioHash] = tmp;
        emit UpdateCertificate(fioHash, certType);
    }

    function getCertificate(string memory _fio, uint64 _passport, uint8 _type) external view returns(Certificate memory) {
        bytes32 fioHash = keccak256(abi.encodePacked(_fio, _passport, _type));
        return s_userCertificate[fioHash];
    }

    function getChildrenCount() public view returns(uint256){
        return s_childAddresses.length;
    }

    function strLength(string memory _text) internal pure returns(uint256) {
        bytes memory res = abi.encodePacked(_text);
        return res.length;
    }

    function getRights(address _sender) internal view returns(bool) {
        return s_organisations[s_children[_sender].owner].approved;
    }

}

contract Organisation {
    Factory immutable private i_mainContract;
    uint256 immutable private i_organisationId;
    address private s_owner;

    constructor(uint256 _id, address _owner, address _factory) {
        i_organisationId = _id;
        s_owner = _owner;
        i_mainContract = Factory(_factory);
    }

    modifier onlyOwner() {
        require(s_owner == msg.sender, "Caller is not the owner");
        _;
    }

    function addCertificate(string memory _fio, uint64 _passport, uint8 _type, string memory _number,
        string memory _cid) public onlyOwner {
        i_mainContract.addCertificate(_fio, _passport, _type, _number, _cid);
    }

}