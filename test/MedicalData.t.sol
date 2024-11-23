// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MedicalData.sol";
import "fhevm/lib/TFHE.sol";

contract MedicalDataTest is Test {
    MedicalData medicalData;

    address patient = address(0x1);
    address doctor = address(0x2);
    address unauthorized = address(0x3);
    address secondDoctor = address(0x4);

    function setUp() public {
        medicalData = new MedicalData();
        vm.prank(patient);
        medicalData.addRecord(TFHE.asEbytes256("PatientName"), TFHE.asEuint64(1990), TFHE.asEbytes256("Initial complaint"), TFHE.asEbytes256("Initial examination"));
    }

    function testAddRecord() public {
        vm.prank(patient);
        medicalData.addRecord(TFHE.asEbytes256("NewPatientName"), TFHE.asEuint64(1985), TFHE.asEbytes256("New complaint"), TFHE.asEbytes256("New examination"));
    }

    function testRequestAccess() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        address[] memory requests = medicalData.getAccessRequests();
        assertEq(requests.length, 1);
        assertEq(requests[0], doctor);
    }

    function testGrantPermanentAccess() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantPermanentAccess(doctor);
        vm.prank(doctor);
        (ebytes256 fullName, euint64 birthYear, ebytes256[] memory complaints, ebytes256[] memory examination) = medicalData.getRecord(patient);
        assertEq(birthYear.unwrap(), 1990);
    }

    function testGrantTemporaryAccess() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantTemporaryAccess(doctor);
    }

    function testUnauthorizedAccess() public {
        vm.expectRevert("Only authorized users can perform this action");
        vm.prank(unauthorized);
        medicalData.getRecord(patient);
    }

    function testAddPatientData() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantPermanentAccess(doctor);
        vm.prank(doctor);
        medicalData.addPatientData(patient, TFHE.asEbytes256("Follow-up complaint"), TFHE.asEbytes256("Follow-up examination"));
    }

    function testRevokeAccess() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantPermanentAccess(doctor);
        vm.prank(patient);
        medicalData.revokeAccess(doctor);
        vm.expectRevert("Only authorized users can perform this action");
        vm.prank(doctor);
        medicalData.getRecord(patient);
    }

    function testMultipleAccessRequests() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(secondDoctor);
        medicalData.requestAccess(patient);
        address[] memory requests = medicalData.getAccessRequests();
        assertEq(requests.length, 2);
        assertEq(requests[0], doctor);
        assertEq(requests[1], secondDoctor);
    }

    function testGrantAccessAndAddData() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantPermanentAccess(doctor);
        vm.prank(doctor);
        medicalData.addPatientData(patient, TFHE.asEbytes256("New complaint after access granted"), TFHE.asEbytes256("New examination data"));
    }

    function testGrantAccessThenRevoke() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantPermanentAccess(doctor);
        vm.prank(patient);
        medicalData.revokeAccess(doctor);
        vm.expectRevert("Only authorized users can perform this action");
        vm.prank(doctor);
        medicalData.getRecord(patient);
    }

    function testTemporaryAccessExpiry() public {
        vm.prank(doctor);
        medicalData.requestAccess(patient);
        vm.prank(patient);
        medicalData.grantTemporaryAccess(doctor);
        vm.prank(patient);
        medicalData.revokeAccess(doctor);
        vm.expectRevert("Only authorized users can perform this action");
        vm.prank(doctor);
        medicalData.getRecord(patient);
    }

    function testOwnerCanUpdateRecord() public {
        vm.prank(patient);
        medicalData.updateRecord(TFHE.asEbytes256("UpdatedPatientName"), TFHE.asEuint64(1995));
        (ebytes256 fullName, euint64 birthYear, , ) = medicalData.getRecord(patient);
        assertEq(birthYear.unwrap(), 1995);
    }

    function testUnauthorizedCannotUpdateRecord() public {
        vm.expectRevert("Only the owner can perform this action");
        vm.prank(unauthorized);
        medicalData.updateRecord(TFHE.asEbytes256("FakeUpdate"), TFHE.asEuint64(2000));
    }
}
