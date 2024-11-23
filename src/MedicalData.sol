// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "fhevm/lib/TFHE.sol";

contract MedicalData {
    struct PatientRecord {
        ebytes256 encryptedFullName;
        euint64 encryptedBirthYear;
        ebytes256[] encryptedComplaintsHistory;
        ebytes256[] encryptedExaminationDataHistory;
        address owner;
        mapping(address => bool) accessList;
        mapping(address => bool) accessRequests;
        address[] accessRequesters;
    }

    mapping(address => PatientRecord) private records;

    event RecordAdded(address indexed patient);
    event AccessGranted(address indexed patient, address indexed requester);
    event AccessRevoked(address indexed patient, address indexed requester);
    event AccessRequested(address indexed patient, address indexed requester);
    event RecordUpdated(address indexed updater);
    event NewDataAdded(address indexed patient, address indexed updater);

    modifier onlyOwner() {
        require(msg.sender == records[msg.sender].owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyAuthorized(address _patient) {
        PatientRecord storage record = records[_patient];
        require(
            msg.sender == record.owner || record.accessList[msg.sender], "Only authorized users can perform this action"
        );
        _;
    }

    function addRecord(
        ebytes256 _encryptedFullName,
        euint64 _encryptedBirthYear,
        ebytes256 _encryptedComplaints,
        ebytes256 _encryptedExaminationData
    ) public {
        PatientRecord storage record = records[msg.sender];
        record.encryptedFullName = _encryptedFullName;
        record.encryptedBirthYear = _encryptedBirthYear;
        record.encryptedComplaintsHistory.push(_encryptedComplaints);
        record.encryptedExaminationDataHistory.push(_encryptedExaminationData);
        record.owner = msg.sender;
        emit RecordAdded(msg.sender);
    }

    function addPatientData(address _patient, ebytes256 _newComplaints, ebytes256 _newExaminationData)
        public
        onlyAuthorized(_patient)
    {
        PatientRecord storage record = records[_patient];
        record.encryptedComplaintsHistory.push(_newComplaints);
        record.encryptedExaminationDataHistory.push(_newExaminationData);
        emit NewDataAdded(_patient, msg.sender);
    }

    function updateRecord(ebytes256 _encryptedFullName, euint64 _encryptedBirthYear) public onlyOwner {
        PatientRecord storage record = records[msg.sender];
        record.encryptedFullName = _encryptedFullName;
        record.encryptedBirthYear = _encryptedBirthYear;
        emit RecordUpdated(msg.sender);
    }

    function getRecord(address _patient)
        public
        view
        onlyAuthorized(_patient)
        returns (ebytes256 , euint64, ebytes256[] memory, ebytes256[] memory)
    {
        PatientRecord storage record = records[_patient];
        return (
            record.encryptedFullName,
            record.encryptedBirthYear,
            record.encryptedComplaintsHistory,
            record.encryptedExaminationDataHistory
        );
    }

    function getAccessRequests() public view onlyOwner returns (address[] memory) {
        PatientRecord storage record = records[msg.sender];
        return record.accessRequesters;
    }

    function requestAccess(address _patient) public {
        PatientRecord storage record = records[_patient];
        require(msg.sender != _patient, "Patient cannot request access to their own record");
        require(!record.accessRequests[msg.sender], "Access already requested by this address");
        record.accessRequests[msg.sender] = true;
        record.accessRequesters.push(msg.sender);
        emit AccessRequested(_patient, msg.sender);
    }

    function grantAccess(address _requester) public onlyOwner {
        PatientRecord storage record = records[msg.sender];
        record.accessList[_requester] = true;
        TFHE.allow(record.encryptedFullName, _requester);
        TFHE.allow(record.encryptedBirthYear, _requester);
        // TFHE.allow(record.encryptedComplaintsHistory, _requester);
        // TFHE.allow(record.encryptedExaminationDataHistory, _requester);
        emit AccessGranted(msg.sender, _requester);
    }

    function revokeAccess(address _requester) public onlyOwner {
        PatientRecord storage record = records[msg.sender];
        record.accessList[_requester] = false;
        emit AccessRevoked(msg.sender, _requester);
    }
}
