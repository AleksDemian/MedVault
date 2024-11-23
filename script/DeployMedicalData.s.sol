// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/MedicalData.sol";

contract DeployMedicalData is Script {
    function run() external {
        vm.startBroadcast();

        MedicalData medicalData = new MedicalData();

        console.log("MedicalData contract deployed to:", address(medicalData));

        vm.stopBroadcast();
    }
}