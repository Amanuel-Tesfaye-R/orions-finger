#include <Servo.h>

/**
 * NOVA Star Pointer Controller
 * Controls 3 servo motors for X, Y, and Z axes.
 * 
 * Hardware Connections:
 * - Servo X (Azimuth): Signal to Pin 9
 * - Servo Y (Altitude): Signal to Pin 10
 * - Servo Z (Roll/Fine): Signal to Pin 11
 * - Connect all GND to Arduino GND
 * - Connect Servo VCC to external 5V (recommended) or Arduino 5V
 */

// Create servo objects
Servo servoX;
Servo servoY;
Servo servoZ;

// Current and Target positions (in degrees, now with decimals)
float posX = 90.0;
float posY = 90.0;
float posZ = 90.0;

float targetX = 90.0;
float targetY = 90.0;
float targetZ = 90.0;

// Movement speed (degree increment per loop)
const float MOVE_STEP = 0.5; 
const int LOOP_DELAY = 20;

void setup() {
  // Attach servos to pins
  servoX.attach(9);
  servoY.attach(10);
  servoZ.attach(11);

  // Initialize to center using microseconds for high precision
  // 1500us is typically 90 degrees
  servoX.writeMicroseconds(1500);
  servoY.writeMicroseconds(1500);
  servoZ.writeMicroseconds(1500);

  // Start Serial communication
  Serial.begin(115200);
  Serial.println("NOVA Precision Controller Ready");
}

void loop() {
  // Check for incoming serial data
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    parseCommand(input);
  }

  // Smoothly move servos to target positions
  updateServos();
  
  delay(MOVE_DELAY);
}

void parseCommand(String cmd) {
  cmd.toUpperCase();
  cmd.trim();
  if (cmd.length() == 0) return;

  int xPos = cmd.indexOf('X');
  int yPos = cmd.indexOf('Y');
  int zPos = cmd.indexOf('Z');

  if (xPos != -1) targetX = constrain(extractFloat(cmd, xPos), 0, 360);
  if (yPos != -1) targetY = constrain(extractFloat(cmd, yPos), 0, 180);
  if (zPos != -1) targetZ = constrain(extractFloat(cmd, zPos), 0, 180);

  Serial.print("ACK: X"); Serial.print(targetX);
  Serial.print(" Y"); Serial.print(targetY);
  Serial.print(" Z"); Serial.println(targetZ);
}

float extractFloat(String data, int startIdx) {
  String result = "";
  for (int i = startIdx + 1; i < data.length(); i++) {
    char c = data.charAt(i);
    if (isDigit(c) || c == '-' || c == '.') result += c;
    else if (isAlpha(c) || isSpace(c)) break;
  }
  return result.toFloat();
}

void updateServos() {
  bool moved = false;

  if (abs(posX - targetX) > 0.1) {
    posX += (targetX > posX) ? MOVE_STEP : -MOVE_STEP;
    moved = true;
  }
  if (abs(posY - targetY) > 0.1) {
    posY += (targetY > posY) ? MOVE_STEP : -MOVE_STEP;
    moved = true;
  }
  if (abs(posZ - targetZ) > 0.1) {
    posZ += (targetZ > posZ) ? MOVE_STEP : -MOVE_STEP;
    moved = true;
  }

  if (moved) {
    // Map 0-180 degrees to 1000-2000 microseconds
    // If your Azimuth is 360 with a 2:1 gear, the script handles the mapping
    servoX.writeMicroseconds(mapFloat(posX, 0, 180, 1000, 2000));
    servoY.writeMicroseconds(mapFloat(posY, 0, 180, 1000, 2000));
    servoZ.writeMicroseconds(mapFloat(posZ, 0, 180, 1000, 2000));
  }
}

long mapFloat(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
