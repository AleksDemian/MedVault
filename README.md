# MedVault

MedVault is a secure, blockchain-based platform for encrypted storage, management, and sharing of sensitive medical data. This project empowers patients to control access to their medical records while ensuring data privacy, integrity, and availability.

## Problem Statement

In today's healthcare systems, patients face significant challenges in managing their medical records securely and conveniently. Medical data is often fragmented across various institutions, and privacy concerns arise due to unauthorized access and data breaches. MedVault aims to solve these issues by offering a decentralized solution for secure medical data management.

## Features

- Patient-Controlled Access: Patients have full control over who can access their medical records, allowing them to grant or revoke permissions.

- Homomorphic Encryption: Sensitive data is encrypted using homomorphic encryption to ensure privacy even when shared for processing.

- Decentralized Storage: Medical records are stored on a blockchain, ensuring data integrity and resistance to tampering.

- Secure Sharing: Data can be securely shared with healthcare professionals, maintaining confidentiality.

## Smart Contracts

The main contract, MedicalData, manages patient records by:

- Storing encrypted patient data (full name, birth year, medical history).

- Allowing authorized users to access medical records.

- Providing the functionality for patients to grant or revoke access permissions.

## Usage

Add Patient Record: Patients can add their encrypted medical information to the blockchain by interacting with the addRecord() function.

Request Access: Healthcare professionals can request access to patient records, and patients can choose to grant or deny access.

Grant/Revoke Access: The owner of the record can update permissions at any time to control who has access to their data.
