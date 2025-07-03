# BadUSB Ransomware Simulation Project

This project demonstrates a **BadUSB-based attack framework** using two covert USB hardware platforms: the **Digispark ATTiny85** and an **Arduino Leonardo embedded inside a USB mouse (Bad Mouse)**. The attack emulates a stealth ransomware deployment targeting small law firm environments through Human Interface Device (HID) injection and automated PowerShell/Linux script execution.

> ⚠️ **Disclaimer**: This project is for **educational and research purposes only**. Do not use this code or methodology on systems you do not own or have explicit permission to test. Misuse may be illegal.

---

## 📌 Project Objectives

- Simulate real-world BadUSB attacks using affordable microcontrollers.
- Demonstrate automated delivery of platform-specific ransomware payloads via keystroke injection.
- Evaluate the risks of USB trust models, especially for small law firms with limited cybersecurity defenses.
- Raise awareness of hardware-based attack vectors and propose mitigation strategies.

---

## 🛠️ Hardware Platforms

### 🔹 Digispark ATTiny85 (BadUSB Stick)
- Emulates a USB keyboard using `DigiKeyboard.h`.
- Executes a one-line PowerShell command to:
  - Bypass execution policy,
  - Download `checkOS.py`,
  - Trigger ransomware script (`encrypt.ps1` for Windows or `encrypt.sh` for Linux).

### 🔹 Arduino Leonardo Embedded Mouse ("Bad Mouse")
- A standard USB optical mouse modified to embed an Arduino Leonardo (ATmega32u4).
- Functions as a real mouse while also injecting malicious keystrokes.
- Downloads and executes `checkOS.py`, which detects the OS and delivers the appropriate payload.

---

## 🧪 Attack Flow

1. **Connect USB device** (Digispark or Bad Mouse) to target system.
2. **Keystroke injection** opens the Run dialog or terminal.
3. Downloads and runs `checkOS.py`:
   - Determines if system is Windows or Linux.
   - Fetches `encrypt.ps1` or `encrypt.sh`.
4. Payload executes and encrypts user files (DOCX, PDF, XLSX, etc.).
5. Ransom note is dropped on the Desktop.
6. Device self-cleans (optional anti-forensics: clear event logs, command history).

---


