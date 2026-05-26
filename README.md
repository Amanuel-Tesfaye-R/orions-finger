# Orion's Finger & NOVA

**Winner — 2019~2020 Science Fair Competition**  
**Built by Amanuel Tesfaye | Grades 9–11 | Ethiopia**

---

## The Story

I started this in Grade 9 and kept building until Grade 11.

I was into space and batch scripting was the only thing I knew, so I started with a text file of star data from Wikipedia, NASA, and astronomy books. Just kept adding to it. By Grade 11 the database passed 800 objects.

Then I built the hardware to go with it — a Lego frame, three servo motors, an Arduino Uno, and a laser pointer. NOVA sends coordinates through a PowerShell script to the Arduino, and the arm moves to point the laser at whatever star you searched for.

Won first place at the 2019~2020 Science Fair.

---

## Files

| File | What it is |
|------|-----------|
| `NOVA.bat` | The batch program. 871+ stars, galaxies, nebulas, planets, clusters. Search and browse with full data. |
| `StarPointer.ino` | Arduino firmware. Controls 3 servo motors over serial at 115200 baud. |
| `PointToCelestial.ps1` | PowerShell script. Converts RA/Dec to Alt/Az based on your latitude/longitude. |
| `SendToStarPointer.ps1` | Sends angle commands to the Arduino over a COM port. |
| `image ASCII assets/` | ASCII art that shows in the console when you inspect an object. |

### Hardware

- Arduino Uno
- 3 servo motors
- Laser pointer
- Lego frame
- Wires and breadboard

---

## How It Works

```
NOVA looks up RA/Dec for the object
  → PointToCelestial.ps1 converts to Alt/Az
  → SendToStarPointer.ps1 sends angles to Arduino
  → Servos move, laser points
```

---

## How to Run

```
1. Open cmd.exe (not PowerShell)
2. cd to the project folder
3. Type: NOVA.bat
4. Pick Search (1) or Browse (2)
```

If you have the hardware:

```
.\PointToCelestial.ps1 -RA "05:55:10" -Dec "+07:24:25" -Lat 40.71 -Long -74.00 -COM COM3
```

That points at Betelgeuse from New York.

---

## Tech

| Layer | Stack |
|-------|-------|
| UI & Database | Batch (cmd) |
| Math engine | PowerShell |
| Firmware | C++ (Arduino) |
| Serial | 115200 baud, ASCII |
| Coordinates | RA/Dec → Alt/Az |

---

## Project Tree

```
Orion's Finger/
├── NOVA.bat
├── StarPointer.ino
├── PointToCelestial.ps1
├── SendToStarPointer.ps1
├── Project image.jpg
├── README.md
└── image ASCII assets/
    ├── Stars/
    ├── Galaxies/
    ├── Nebulas/
    └── Planets/
```

---

*Amanuel Tesfaye — 2019~2020*
