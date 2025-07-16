# n-Digit BCD Adder (Verilog Project)

## 📘 Course Information
- **Course:** Advanced Digital Design (ENCS533)
- **University:** Birzeit University
- **Department:** Electrical and Computer Engineering
- **Instructors:** Dr. Abdellatif Abu-Issa & Dr. Elias Khalil
- **Student Name:** [Your Name]
- **Student ID:** [Your ID]

---

## 🎯 Objective

Design and implement an `n-digit BCD adder` in Verilog using:
- **Ripple Carry Adder (Stage 1)**
- **Carry Look-Ahead Adder (Stage 2)**

All designs are built structurally using basic logic gates and verified through simulation.

---

## 🏗️ Project Breakdown

### Stage 1: Ripple Carry Adder
- Built 1-bit full adder using gates
- Constructed 4-bit ripple carry adder
- Designed 1-digit BCD adder
- Extended to 3-digit BCD adder (n=3)
- Introduced and detected design error

### Stage 2: Carry Look-Ahead Adder
- Built 4-bit carry look-ahead adder
- Created 3-digit BCD adder using CLA blocks
- Verified faster performance compared to Stage 1
- Simulated and evaluated timing

---

## 🧱 Gate Library and Delays

| Gate     | Delay |
|----------|-------|
| Inverter | 5 ns  |
| NAND     | 8 ns  |
| NOR      | 8 ns  |
| AND      | 11 ns |
| OR       | 11 ns |
| XNOR     | 13 ns |
| XOR      | 15 ns |

---

## ✅ Features
- Fully structural Verilog design (no behavioral blocks)
- Modular and readable code
- Functional verification with error detection
- Timing and latency analysis

---
