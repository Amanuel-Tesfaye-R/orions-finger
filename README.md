# Orion's Finger & NOVA — Stellar Intelligence Terminal

**Winner — 2019~2020 Science Fair Competition**  
**Built by Amanuel Tesfaye | Grades 9–11 | Ethiopia**

> *"NOVA doesn't just look at the stars; it knows them."*

---

## The Story

I started this in Grade 9 and kept building until Grade 11.

It began with a simple question: *What if I could point a laser at any star I searched for?*

I was obsessed with space, and batch scripting was the only language I knew well enough, so that's where NOVA was born. It started as a text file of star data I compiled from Wikipedia, NASA's exoplanet archive, and astronomy reference books. I kept adding entries — stars, galaxies, nebulas, planets — across multiple revisions. By Grade 11, the database passed 800 objects.

Then I decided it needed a body.

Orion's Finger is that body — a robotic arm made of Lego, three servo motors, and an Arduino Uno. When NOVA calculates the position of a celestial object, it sends commands through a PowerShell script to the Arduino, which moves the arm to point a laser precisely at that spot in the sky.

The whole thing won first place at the 2019~2020 Science Fair.

---

## What's in This Repo

### NOVA — The Brain

| File | What it does |
|------|-------------|
| `NOVA.bat` | The main program. A batch-file astronomical database with 871+ stars, galaxies, nebulas, planets, and clusters. Search, browse, and inspect objects with full details. |

**Database fields per object:**
- Spectral Classification (temperature & composition)
- Absolute Luminosity & Visual Brightness
- Physical Radius & Dimensional Scale
- Evolutionary Stage & Life Cycle Data
- Exact Distance in Light Years
- Assigned Color Palette for console display

### Orion's Finger — The Body

| File | What it does |
|------|-------------|
| `StarPointer.ino` | Arduino firmware. Controls 3 servo motors (X/Y/Z axes) with smooth motion and serial command parsing at 115200 baud. |
| `PointToCelestial.ps1` | The celestial math engine. Converts Right Ascension / Declination coordinates into Altitude / Azimuth angles for the servos. Accounts for observer latitude and longitude. |
| `SendToStarPointer.ps1` | Simple serial helper. Sends angle commands (X, Y, Z) to the Arduino over a specified COM port. |

### Hardware Used

- **Arduino Uno** — The central nervous system
- **3 High-Torque Servo Motors** — The robotic joints
- **1 Precision Laser Pointer** — The visual guide
- **Lego frame** — The structural skeleton
- **Jumper cables & breadboard** — Wiring

### ASCII Visualizations

The `image ASCII assets/` folder contains custom ASCII art for different celestial categories — rendered in the console when you inspect an object:

- `Stars/Star.txt`
- `Galaxies/Galaxy.txt`
- `Nebulas/Nebulas.txt`
- `Planets/planet.txt`

---

## How It All Fits Together

```
You search for an object in NOVA (batch)
        │
        ▼
NOVA looks up the celestial coordinates (RA/Dec)
        │
        ▼
PointToCelestial.ps1 converts RA/Dec → Alt/Az
        │
        ▼
SendToStarPointer.ps1 sends Alt/Az to Arduino
        │
        ▼
Arduino moves 3 servos to point the laser
```

---

## How to Run

### NOVA (the database)

```
1. Open a Command Prompt (cmd.exe, not PowerShell)
2. cd to the project folder
3. Type: NOVA.bat
4. Use options 1 (Search) or 2 (Browse) to explore
```

### Star Pointer (if you have the hardware)

```
.\PointToCelestial.ps1 -RA "05:55:10" -Dec "+07:24:25" -Lat 40.71 -Long -74.00 -COM COM3
```

This points the arm at Betelgeuse from New York.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI & Database | Batch script (Windows cmd) |
| Math Engine | PowerShell |
| Firmware | C++ (Arduino) |
| Serial Protocol | 115200 baud, ASCII commands |
| Coordinate System | RA/Dec → Alt/Az conversion |

---

## Project Structure

```
Orion's Finger/
├── NOVA.bat                    # Main program + 871-object database
├── StarPointer.ino             # Arduino firmware (3-servo control)
├── PointToCelestial.ps1        # RA/Dec → Alt/Az math engine
├── SendToStarPointer.ps1       # Serial communication helper
├── Project image.jpg           # Photo of the build
├── README.md                   # This file
└── image ASCII assets/         # Console art for visualization
    ├── Stars/
    ├── Galaxies/
    ├── Nebulas/
    └── Planets/
```

---

## License

This project is shared as a reference and personal archive. Built for a science fair, maintained for the memory.

---

*Amanuel Tesfaye — Grade 9 to 11, 2019~2020*
