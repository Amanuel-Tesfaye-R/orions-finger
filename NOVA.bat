@echo off
setlocal enabledelayedexpansion

:: Change to script's folder so %~nx0 works in findstr (avoids unicode path issues)
cd /d "%~dp0" 2>nul

:: Set console size for high-detail ASCII art
mode con: cols=120 lines=80

:: --- ANSI COLOR SETUP ---
for /f "tokens=2 delims==" %%a in ('set ^| findstr /I "COLUMNS"') do set "COLS=%%a"
if not defined COLS set "COLS=120"

set "ESC= "
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

set "C_RESET=%ESC%[0m"
set "C_WHITE=%ESC%[97m"
set "C_BLUE=%ESC%[94m"
set "C_CYAN=%ESC%[96m"
set "C_YELLOW=%ESC%[93m"
set "C_ORANGE=%ESC%[33m"
set "C_RED=%ESC%[91m"
set "C_GREEN=%ESC%[92m"
set "C_PURPLE=%ESC%[95m"
set "C_GRAY=%ESC%[90m"
set "C_BOLD=%ESC%[1m"

:: --- WELCOME SCREEN ---
:WELCOME
cls
echo %C_BLUE%
echo    _   _  ______      __      
echo   ^| \ ^| ^|/ __ \ \    / / /\   
echo   ^|  \^| ^| ^|  ^| \ \  / / /  \  
echo   ^| . ` ^| ^|  ^| ^|\ \/ / / /\ \ 
echo   ^| ^|\  ^| ^|__^| ^| \  / / ____ \
echo   ^|_^| \_^|\____/   \/ /_/    \_\
echo %C_RESET%
echo %C_WHITE%==========================================%C_RESET%
echo %C_CYAN%     Hi, I'm NOVA by Aman%C_RESET%
echo %C_YELLOW%  I have 1000+ stars and galaxies data%C_RESET%
echo %C_WHITE%==========================================%C_RESET%
echo.
echo %C_BOLD%[1] SEARCH DATABASE%C_RESET%
echo %C_BOLD%[2] BROWSE CATEGORIES%C_RESET%
echo %C_BOLD%[3] EXIT%C_RESET%
echo.
echo ^G
set /p "choice=Select an option: "

if "%choice%"=="1" goto :SEARCH
if "%choice%"=="2" goto :BROWSE
if "%choice%"=="3" exit /b
goto :WELCOME

:: --- SEARCH LOGIC ---
:SEARCH
cls
echo %C_CYAN%--- SEARCH NOVA DATABASE ---%C_RESET%
set "query="
set /p "query=Enter Name (e.g. Sirius, Andromeda, Orion): "
if "%query%"=="" goto :WELCOME

:: Trim trailing spaces
:TRIM_QUERY
if "!query:~-1!"==" " (
    set "query=!query:~0,-1!"
    goto :TRIM_QUERY
)
if "%query%"=="" goto :WELCOME

:: Convert M<num> or M <num> to Messier <num>
set "testChar=%query:~0,1%"
if /i "%testChar%"=="M" (
    set "rest=%query:~1%"
    if "!rest:~0,1!"==" " set "rest=!rest:~1!"
    set "isNum=1"
    for /f "delims=0123456789" %%x in ("!rest!") do set "isNum=0"
    if "!isNum!"=="1" set "query=Messier !rest!"
)

set "found=0"
echo.
echo %C_GRAY%Searching for "%query%"...%C_RESET%

:: Search in the data block
for /f "tokens=1-9 delims=|" %%a in ('findstr /i /c:"%query%" "%~nx0"') do (
    set "ok=0"
    if /i "%%b"=="STAR" set "ok=1"
    if /i "%%b"=="GALAXY" set "ok=1"
    if /i "%%b"=="PLANET" set "ok=1"
    if /i "%%b"=="NEBULA" set "ok=1"
    if /i "%%b"=="CLUSTER" set "ok=1"
    
    if "!ok!"=="1" (
        set "found=1"
        call :DISPLAY "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" "%%g" "%%h" "%%i"
    )
)

if "!found!"=="0" (
    echo.
    echo %C_RED%No results found for "%query%".%C_RESET%
    echo %C_GRAY%Please check the spelling or try a shorter name.%C_RESET%
    pause
)
goto :WELCOME

:: --- DISPLAY LOGIC ---
:DISPLAY
set "name=%~1"
set "cat=%~2"
set "spec=%~3"
set "lum=%~4"
set "size=%~5"
set "evol=%~6"
set "dist=%~7"
set "color=%~8"
set "sizeTier=%~9"

:: Determine Temperature based on Spec Type
set "temp=N/A"
if "!cat!"=="STAR" (
    set "firstChar=!spec:~0,1!"
    if /i "!firstChar!"=="O" set "temp=> 30,000 K (Extremely Hot)"
    if /i "!firstChar!"=="B" set "temp=10,000 - 30,000 K (Very Hot)"
    if /i "!firstChar!"=="A" set "temp=7,500 - 10,000 K (Hot)"
    if /i "!firstChar!"=="F" set "temp=6,000 - 7,500 K (Warm)"
    if /i "!firstChar!"=="G" set "temp=5,200 - 6,000 K (Moderate/Yellow)"
    if /i "!firstChar!"=="K" set "temp=3,700 - 5,200 K (Cool/Orange)"
    if /i "!firstChar!"=="M" set "temp=2,400 - 3,700 K (Very Cool/Red)"
    
    :: Fallback estimates for Luminosity/Size if N/A
    if "!lum!"=="N/A" (
        if /i "!firstChar!"=="O" set "lum=~50,000 L"
        if /i "!firstChar!"=="B" set "lum=~2,000 L"
        if /i "!firstChar!"=="A" set "lum=~60 L"
        if /i "!firstChar!"=="F" set "lum=~6 L"
        if /i "!firstChar!"=="G" set "lum=~1.2 L"
        if /i "!firstChar!"=="K" set "lum=~0.5 L"
        if /i "!firstChar!"=="M" set "lum=~0.08 L"
    )
    if "!size!"=="N/A" (
        if /i "!firstChar!"=="O" set "size=~12 R"
        if /i "!firstChar!"=="B" set "size=~8 R"
        if /i "!firstChar!"=="A" set "size=~2.4 R"
        if /i "!firstChar!"=="F" set "size=~1.5 R"
        if /i "!firstChar!"=="G" set "size=~1.0 R"
        if /i "!firstChar!"=="K" set "size=~0.7 R"
        if /i "!firstChar!"=="M" set "size=~0.3 R"
    )
)

:: Set Color ANSI
set "COL_CODE=%C_WHITE%"
if /i "%color%"=="Blue" set "COL_CODE=%C_BLUE%"
if /i "%color%"=="White" set "COL_CODE=%C_WHITE%"
if /i "%color%"=="Yellow" set "COL_CODE=%C_YELLOW%"
if /i "%color%"=="Orange" set "COL_CODE=%C_ORANGE%"
if /i "%color%"=="Red" set "COL_CODE=%C_RED%"
if /i "%color%"=="Cyan" set "COL_CODE=%C_CYAN%"
if /i "%color%"=="Green" set "COL_CODE=%C_GREEN%"
if /i "%color%"=="Purple" set "COL_CODE=%C_PURPLE%"
if /i "%color%"=="Gray" set "COL_CODE=%C_GRAY%"

cls
echo %C_CYAN%==========================================================%C_RESET%
echo %C_BOLD%  NOVA DEEP SPACE SCAN: %name%%C_RESET%
echo %C_CYAN%==========================================================%C_RESET%
echo.
echo  %C_WHITE%[BASIC INFORMATION]%C_RESET%
echo  - CATEGORY:      %cat%
echo  - DISTANCE:      %dist%
echo.
echo  %C_WHITE%[STELLAR CHARACTERISTICS]%C_RESET%
echo  - SPECTRAL TYPE: %spec% (Temperature Class)
echo  - TEMPERATURE:   %temp%
echo  - LUMINOSITY:    %lum% (Absolute Brightness)
echo  - RADIUS/SIZE:   %size% (Physical Dimension)
echo.
echo  %C_WHITE%[EVOLUTIONARY DATA]%C_RESET%
echo  - STAGE:         %evol% (Current Life Cycle)
echo.
echo %C_CYAN%==========================================================%C_RESET%
echo.
echo %C_YELLOW%VISUAL REPRESENTATION:%C_RESET%
echo.
echo ^G

:: Try to display high-detail asset from category folders
set "assetPath="
set "baseDir=%~dp0image ASCII assets"
if /i "%cat%"=="STAR" for %%f in ("%baseDir%\Stars\*.txt") do set "assetPath=%%~ff"
if /i "%cat%"=="GALAXY" for %%f in ("%baseDir%\Galaxies\*.txt") do set "assetPath=%%~ff"
if /i "%cat%"=="PLANET" if /i "%spec%"=="Gas Giant" set "assetPath=%baseDir%\planets\GasGiant.txt"
if /i "%cat%"=="PLANET" if /i "%spec%"=="Terrestrial" set "assetPath=%baseDir%\planets\Terrestrial.txt"
if /i "%cat%"=="PLANET" if /i "%spec%"=="Ice Giant" set "assetPath=%baseDir%\planets\IceGiant.txt"
if /i "%cat%"=="PLANET" if /i "%spec%"=="Dwarf" set "assetPath=%baseDir%\planets\Dwarf.txt"
if /i "%cat%"=="NEBULA" for %%f in ("%baseDir%\Nebulas\*.txt") do set "assetPath=%%~ff"

if defined assetPath (
    if exist "!assetPath!" (
        echo %COL_CODE%
        type "!assetPath!"
        echo %C_RESET%
    ) else (
        call :DRAW_CIRCLE "%sizeTier%" "%COL_CODE%"
    )
) else (
    call :DRAW_CIRCLE "%sizeTier%" "%COL_CODE%"
)

echo.
echo %C_GRAY%Press any key to return...%C_RESET%
pause >nul
exit /b

:: --- CIRCLE DRAWING ENGINE (PERFECT CIRCLES) ---
:DRAW_CIRCLE
set "tier=%~1"
set "c_code=%~2"
echo %c_code%

if "%tier%"=="1" (
    echo.
    echo      ( )
    echo.
)
if "%tier%"=="2" (
    echo.
    echo      .---.
    echo     (     )
    echo      '---'
    echo.
)
if "%tier%"=="3" (
    echo.
    echo       .-----.
    echo     .'       '.
    echo     ^|         ^|
    echo     '.       .'
    echo       '-----'
    echo.
)
if "%tier%"=="4" (
    echo.
    echo         .--------.
    echo      .'            '.
    echo     /                \
    echo     ^|                ^|
    echo     \                /
    echo      '.            .'
    echo         '--------'
    echo.
)
if "%tier%"=="5" (
    echo.
    echo           .------------.
    echo        .'                '.
    echo      /                    \
    echo     ^|                      ^|
    echo     ^|                      ^|
    echo      \                    /
    echo        '.                .'
    echo           '------------'
    echo.
)
echo %C_RESET%
exit /b

:: --- BROWSE CATEGORIES ---
:BROWSE
set "bcat="
set "bchoice="
cls
echo %C_CYAN%--- BROWSE NOVA ---%C_RESET%
echo [1] Stars
echo [2] Galaxies
echo [3] Planets
echo [4] Nebulas
echo [5] Clusters
echo [6] Back
echo.
set /p "bchoice=Select: "
if "%bchoice%"=="1" set "bcat=STAR"
if "%bchoice%"=="2" set "bcat=GALAXY"
if "%bchoice%"=="3" set "bcat=PLANET"
if "%bchoice%"=="4" set "bcat=NEBULA"
if "%bchoice%"=="5" set "bcat=CLUSTER"
if "%bchoice%"=="6" goto :WELCOME
if not defined bcat goto :BROWSE

cls
echo %C_YELLOW%Showing %bcat%s (Enter name to view details):%C_RESET%
echo.
set "count=0"
for /f "tokens=1 delims=|" %%a in ('findstr "|%bcat%|" "%~nx0"') do (
    set /a "count+=1"
    echo  - %%a
    if !count! GEQ 30 (
        echo ... and many more. Use Search for specific ones.
        goto :BROWSE_POST
    )
)
:BROWSE_POST
echo.
set "sq="
set /p "sq=Enter full name to view or [B] to go back: "
if /i "%sq%"=="B" goto :BROWSE
call :SEARCH_SPECIFIC "%sq%"
goto :BROWSE

:SEARCH_SPECIFIC
set "target=%~1"
set "foundInSpecific=0"

if "%target%"=="" goto :BROWSE

:: Trim trailing spaces
:TRIM_TARGET
if "!target:~-1!"==" " (
    set "target=!target:~0,-1!"
    goto :TRIM_TARGET
)
if "%target%"=="" goto :BROWSE

:: Convert M<num> or M <num> to Messier <num>
set "testChar=%target:~0,1%"
if /i "%testChar%"=="M" (
    set "rest=%target:~1%"
    if "!rest:~0,1!"==" " set "rest=!rest:~1!"
    set "isNum=1"
    for /f "delims=0123456789" %%x in ("!rest!") do set "isNum=0"
    if "!isNum!"=="1" set "target=Messier !rest!"
)

for /f "tokens=1-9 delims=|" %%a in ('findstr /i /c:"%target%|" "%~nx0"') do (
    set "ok=0"
    if /i "%%b"=="STAR" set "ok=1"
    if /i "%%b"=="GALAXY" set "ok=1"
    if /i "%%b"=="PLANET" set "ok=1"
    if /i "%%b"=="NEBULA" set "ok=1"
    if /i "%%b"=="CLUSTER" set "ok=1"
    
    if "!ok!"=="1" (
        set "foundInSpecific=1"
        call :DISPLAY "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" "%%g" "%%h" "%%i"
    )
)
if "!foundInSpecific!"=="0" (
    echo.
    echo %C_RED%No information found for "%target%".%C_RESET%
    pause
)
goto :BROWSE

:: --- DATABASE SECTION ---
:: Format: Name|Category|SpecType|Luminosity|Size|Evolution|Distance|Color|SizeTier
:: DO NOT REMOVE THE "GOTO :EOF" ABOVE OR BATCH WILL TRY TO EXECUTE THE DATA
goto :EOF

Sirius|STAR|A1V|25.4 L|1.71 R|Main Sequence|8.6 ly|White|3
Canopus|STAR|A9II|10,700 L|71 R|Bright Giant|310 ly|White|4
Alpha Centauri A|STAR|G2V|1.5 L|1.2 R|Main Sequence|4.37 ly|Yellow|3
Arcturus|STAR|K1.5III|170 L|25 R|Red Giant|36.7 ly|Orange|4
Vega|STAR|A0V|40 L|2.3 R|Main Sequence|25 ly|White|3
Capella|STAR|G3III|78 L|12 R|Giant|42.9 ly|Yellow|4
Rigel|STAR|B8Ia|120,000 L|78 R|Blue Supergiant|860 ly|Blue|5
Procyon|STAR|F5IV|6.9 L|2 R|Subgiant|11.4 ly|White|3
Achernar|STAR|B6Vep|3,150 L|6.7 R|Main Sequence|139 ly|Blue|4
Betelgeuse|STAR|M1-M2Ia|126,000 L|887 R|Red Supergiant|640 ly|Red|5
Hadar|STAR|B1III|41,700 L|13 R|Giant|390 ly|Blue|4
Altair|STAR|A7V|10.6 L|1.6 R|Main Sequence|16.7 ly|White|3
Aldebaran|STAR|K5III|439 L|44 R|Red Giant|65.3 ly|Orange|4
Antares|STAR|M1.5Iab|75,900 L|680 R|Red Supergiant|550 ly|Red|5
Spica|STAR|B1III|20,500 L|7.4 R|Main Sequence|250 ly|Blue|4
Pollux|STAR|K0III|43 L|8.8 R|Giant|33.7 ly|Orange|3
Fomalhaut|STAR|A3V|16.6 L|1.8 R|Main Sequence|25 ly|White|3
Deneb|STAR|A2Ia|196,000 L|203 R|Blue-White Supergiant|2,600 ly|White|5
Mimosa|STAR|B0.5III|34,000 L|8.4 R|Giant|280 ly|Blue|4
Regulus|STAR|B7V|288 L|3 R|Main Sequence|79 ly|Blue|3
Adhara|STAR|B2II|38,700 L|13.9 R|Bright Giant|430 ly|Blue|4
Castor|STAR|A1V|30 L|2.3 R|Main Sequence|51 ly|White|3
Gacrux|STAR|M3.5III|1,500 L|84 R|Red Giant|88 ly|Red|4
Shaula|STAR|B2IV|9,600 L|8 R|Subgiant|570 ly|Blue|4
Bellatrix|STAR|B2III|6,400 L|5.7 R|Giant|250 ly|Blue|4
Elnath|STAR|B7III|700 L|4.2 R|Giant|130 ly|Blue|3
Miaplacidus|STAR|A2IV|210 L|5.8 R|Subgiant|110 ly|White|3
Alnilam|STAR|B0Ia|375,000 L|42 R|Blue Supergiant|2,000 ly|Blue|5
Alnair|STAR|B6V|250 L|3.4 R|Main Sequence|101 ly|Blue|3
Alnitak|STAR|O9.7Ib|100,000 L|20 R|Blue Supergiant|1,260 ly|Blue|5
Alioth|STAR|A1V|108 L|4 R|Main Sequence|81 ly|White|3
Mirphak|STAR|F5Ib|5,000 L|68 R|Supergiant|510 ly|Yellow|4
Dubhe|STAR|K0III|470 L|30 R|Giant|123 ly|Orange|4
Wezen|STAR|F8Ia|50,000 L|215 R|Yellow Supergiant|1,600 ly|Yellow|5
Sargas|STAR|F1II|1,800 L|26 R|Bright Giant|329 ly|Yellow|4
Kaus Australis|STAR|B9.5III|375 L|6.8 R|Giant|143 ly|Blue|4
Avior|STAR|K3III|1,050 L|153 R|Giant|600 ly|Orange|5
Alkaid|STAR|B3V|700 L|3.4 R|Main Sequence|101 ly|Blue|3
Menkalinan|STAR|A2IV|95 L|2.8 R|Subgiant|81 ly|White|3
Atria|STAR|K2IIb|5,500 L|130 R|Bright Giant|415 ly|Orange|5
Alhena|STAR|A1IV|160 L|4.9 R|Subgiant|109 ly|White|3
Peacock|STAR|B2IV|2,100 L|4.8 R|Subgiant|183 ly|Blue|3
Alsephina|STAR|A1V|90 L|2.9 R|Main Sequence|80 ly|White|3
Mirzam|STAR|B1II|34,000 L|9.7 R|Bright Giant|500 ly|Blue|4
Alphard|STAR|K3III|780 L|50 R|Giant|177 ly|Orange|4
Polaris|STAR|F7Ib|1,260 L|37.5 R|Supergiant|433 ly|Yellow|4
Hamal|STAR|K2III|91 L|15 R|Giant|66 ly|Orange|4
Algieba|STAR|K1III|180 L|23 R|Giant|130 ly|Orange|4
Diphda|STAR|K0III|145 L|17 R|Giant|96 ly|Orange|4
Nunki|STAR|B2.5V|3,300 L|4.5 R|Main Sequence|228 ly|Blue|3
Menkent|STAR|K0III|45 L|10 R|Giant|61 ly|Orange|3
Mirach|STAR|M0III|1,995 L|100 R|Red Giant|197 ly|Red|5
Alpheratz|STAR|B8IV|240 L|2.7 R|Subgiant|97 ly|Blue|3
Saiph|STAR|B0.5Iab|65,000 L|22 R|Blue Supergiant|650 ly|Blue|5
Kochab|STAR|K4III|390 L|42 R|Red Giant|131 ly|Orange|4
Rasalhague|STAR|A5III|25 L|2.6 R|Giant|48 ly|White|3
Algol|STAR|B8V|182 L|2.7 R|Main Sequence|90 ly|Blue|3
Tiaki|STAR|B3V|600 L|3.4 R|Main Sequence|101 ly|Blue|3
Alsuhail|STAR|K4III|1,050 L|153 R|Giant|600 ly|Orange|5
Sun|STAR|G2V|1.0 L|1.0 R|Main Sequence|0 ly|Yellow|2
Proxima Centauri|STAR|M5.5Ve|0.0017 L|0.15 R|Main Sequence|4.24 ly|Red|1
Barnard's Star|STAR|M4V|0.0035 L|0.2 R|Main Sequence|5.96 ly|Red|1
Wolf 359|STAR|M6.5V|0.001 L|0.16 R|Main Sequence|7.8 ly|Red|1
Lalande 21185|STAR|M2V|0.025 L|0.39 R|Main Sequence|8.3 ly|Red|1
Luyten 726-8 A|STAR|M5.5V|0.00006 L|0.14 R|Main Sequence|8.7 ly|Red|1
Luyten 726-8 B|STAR|M6V|0.00004 L|0.14 R|Main Sequence|8.7 ly|Red|1
Ross 154|STAR|M3.5Ve|0.0038 L|0.24 R|Main Sequence|9.7 ly|Red|1
Ross 248|STAR|M6V|0.002 L|0.16 R|Main Sequence|10.3 ly|Red|1
Epsilon Eridani|STAR|K2V|0.34 L|0.74 R|Main Sequence|10.5 ly|Orange|2
Lacaille 9352|STAR|M0.5V|0.033 L|0.46 R|Main Sequence|10.7 ly|Red|1
Ross 128|STAR|M4V|0.0036 L|0.21 R|Main Sequence|11.0 ly|Red|1
EZ Aquarii A|STAR|M5V|0.0005 L|0.11 R|Main Sequence|11.1 ly|Red|1
61 Cygni A|STAR|K5V|0.15 L|0.67 R|Main Sequence|11.4 ly|Orange|2
61 Cygni B|STAR|K7V|0.085 L|0.59 R|Main Sequence|11.4 ly|Orange|2
Struve 2398 A|STAR|M3V|0.005 L|0.35 R|Main Sequence|11.5 ly|Red|1
Groombridge 34 A|STAR|M1.5V|0.011 L|0.34 R|Main Sequence|11.6 ly|Red|1
Epsilon Indi A|STAR|K5V|0.22 L|0.73 R|Main Sequence|11.8 ly|Orange|2
Tau Ceti|STAR|G8.5V|0.52 L|0.79 R|Main Sequence|11.9 ly|Yellow|2
Luyten's Star|STAR|M3.5V|0.0045 L|0.26 R|Main Sequence|12.2 ly|Red|1
Kapteyn's Star|STAR|M1V|0.012 L|0.29 R|Main Sequence|12.8 ly|Red|1
Lacaille 8760|STAR|M2Ve|0.072 L|0.51 R|Main Sequence|12.9 ly|Red|1
Kruger 60 A|STAR|M3V|0.01 L|0.35 R|Main Sequence|13.1 ly|Red|1
Ross 614 A|STAR|M4.5V|0.004 L|0.25 R|Main Sequence|13.3 ly|Red|1
Gliese 687|STAR|M3V|0.021 L|0.41 R|Main Sequence|14.8 ly|Red|1
Gliese 674|STAR|M2.5V|0.029 L|0.42 R|Main Sequence|14.8 ly|Red|1
Gliese 876|STAR|M3.5V|0.012 L|0.38 R|Main Sequence|15.2 ly|Red|1
Gliese 832|STAR|M1.5V|0.026 L|0.48 R|Main Sequence|16.1 ly|Red|1
Andromeda Galaxy|GALAXY|Spiral|26 Billion L|110,000 ly|Spiral|2.5 Million ly|Cyan|5
Milky Way|GALAXY|Barred Spiral|10 Billion L|52,850 ly|Barred Spiral|0 ly|Cyan|5
Triangulum Galaxy|GALAXY|Spiral|0.4 Billion L|30,000 ly|Spiral|2.7 Million ly|Cyan|5
Sombrero Galaxy|GALAXY|Spiral|800 Billion L|25,000 ly|Spiral|29 Million ly|Cyan|5
Whirlpool Galaxy|GALAXY|Spiral|10 Billion L|30,000 ly|Spiral|23 Million ly|Cyan|5
Centaurus A|GALAXY|Lenticular|50 Billion L|30,000 ly|Lenticular|12 Million ly|Cyan|5
Bode's Galaxy|GALAXY|Spiral|20 Billion L|45,000 ly|Spiral|11.8 Million ly|Cyan|5
Cigar Galaxy|GALAXY|Starburst|5 Billion L|18,500 ly|Starburst|11.5 Million ly|Cyan|5
Pinwheel Galaxy|GALAXY|Spiral|30 Billion L|85,000 ly|Spiral|21 Million ly|Cyan|5
Black Eye Galaxy|GALAXY|Spiral|10 Billion L|26,000 ly|Spiral|17 Million ly|Cyan|5
Cartwheel Galaxy|GALAXY|Ring|N/A|75,000 ly|Ring|500 Million ly|Cyan|5
Large Magellanic Cloud|GALAXY|Satellite|1.5 Billion L|14,000 ly|Satellite|158,000 ly|Cyan|4
Small Magellanic Cloud|GALAXY|Satellite|0.5 Billion L|7,000 ly|Satellite|200,000 ly|Cyan|4
Orion Nebula|NEBULA|H II Region|2,000 L|12 ly|Star-forming|1,344 ly|Purple|4
Crab Nebula|NEBULA|SNR|75,000 L|5.5 ly|Supernova Remnant|6,523 ly|Red|3
Eagle Nebula|NEBULA|H II Region|N/A|70 ly|Star-forming|5,700 ly|Green|5
Horsehead Nebula|NEBULA|Dark Nebula|N/A|3.5 ly|Dark Cloud|1,375 ly|Gray|3
Carina Nebula|NEBULA|H II Region|N/A|230 ly|Star-forming|8,500 ly|Cyan|5
Ring Nebula|NEBULA|Planetary|200 L|1.3 ly|End of Life|2,567 ly|Blue|3
Helix Nebula|NEBULA|Planetary|100 L|2.5 ly|End of Life|655 ly|Purple|3
Cat's Eye Nebula|NEBULA|Planetary|10,000 L|0.2 ly|End of Life|3,300 ly|Cyan|3
Lagoon Nebula|NEBULA|H II Region|N/A|110 ly|Star-forming|4,100 ly|Red|5
Trifid Nebula|NEBULA|H II Region|N/A|21 ly|Star-forming|5,200 ly|Blue|4
Dumbbell Nebula|NEBULA|Planetary|100 L|1.4 ly|End of Life|1,360 ly|Green|3
Rosette Nebula|NEBULA|H II Region|N/A|65 ly|Star-forming|5,200 ly|Red|5
Mercury|PLANET|Terrestrial|0|2,439 km|Active|0.000015 ly|Gray|1
Venus|PLANET|Terrestrial|0|6,051 km|Active|0.00004 ly|Yellow|1
Earth|PLANET|Terrestrial|0|6,371 km|Active|0 ly|Blue|1
Mars|PLANET|Terrestrial|0|3,389 km|Active|0.00002 ly|Red|1
Jupiter|PLANET|Gas Giant|0|69,911 km|Active|0.00008 ly|Orange|2
Saturn|PLANET|Gas Giant|0|58,232 km|Active|0.00015 ly|Yellow|2
Uranus|PLANET|Ice Giant|0|25,362 km|Active|0.0003 ly|Cyan|2
Neptune|PLANET|Ice Giant|0|24,622 km|Active|0.0004 ly|Blue|2
Pluto|PLANET|Dwarf|0|1,188 km|Active|0.0006 ly|Gray|1
Messier 1|NEBULA|SNR|75,000 L|5.5 ly|Supernova Remnant|6,500 ly|Red|3
Messier 2|CLUSTER|Globular|N/A|175 ly|Aged|37,500 ly|White|4
Messier 3|CLUSTER|Globular|N/A|180 ly|Aged|33,900 ly|White|4
Messier 4|CLUSTER|Globular|N/A|75 ly|Aged|7,200 ly|Red|4
Messier 5|CLUSTER|Globular|N/A|165 ly|Aged|24,500 ly|White|4
Messier 6|CLUSTER|Open|N/A|12 ly|Young|1,600 ly|Blue|3
Messier 7|CLUSTER|Open|N/A|25 ly|Young|980 ly|Blue|3
Messier 8|NEBULA|H II Region|N/A|110 ly|Star-forming|4,100 ly|Red|5
Messier 9|CLUSTER|Globular|N/A|90 ly|Aged|25,800 ly|White|4
Messier 10|CLUSTER|Globular|N/A|83 ly|Aged|14,300 ly|White|4
Messier 11|CLUSTER|Open|N/A|25 ly|Young|6,200 ly|White|3
Messier 12|CLUSTER|Globular|N/A|75 ly|Aged|15,700 ly|White|4
Messier 13|CLUSTER|Globular|N/A|145 ly|Aged|25,100 ly|Blue|4
Messier 14|CLUSTER|Globular|N/A|100 ly|Aged|30,000 ly|White|4
Messier 15|CLUSTER|Globular|N/A|175 ly|Aged|33,600 ly|White|4
Messier 16|NEBULA|H II Region|N/A|70 ly|Star-forming|7,000 ly|Green|5
Messier 17|NEBULA|H II Region|N/A|15 ly|Star-forming|5,500 ly|Purple|4
Messier 18|CLUSTER|Open|N/A|17 ly|Young|4,900 ly|Blue|3
Messier 19|CLUSTER|Globular|N/A|140 ly|Aged|28,700 ly|White|4
Messier 20|NEBULA|H II Region|N/A|20 ly|Star-forming|5,200 ly|Blue|4
Messier 21|CLUSTER|Open|N/A|13 ly|Young|4,250 ly|Blue|3
Messier 22|CLUSTER|Globular|N/A|99 ly|Aged|10,600 ly|Yellow|4
Messier 23|CLUSTER|Open|N/A|18 ly|Young|2,150 ly|White|3
Messier 24|CLUSTER|Star Cloud|N/A|330 ly|Part of Milky Way|10,000 ly|Yellow|5
Messier 25|CLUSTER|Open|N/A|13 ly|Young|2,000 ly|White|3
Messier 26|CLUSTER|Open|N/A|22 ly|Young|5,000 ly|White|3
Messier 27|NEBULA|Planetary|100 L|1.4 ly|End of Life|1,360 ly|Green|3
Messier 28|CLUSTER|Globular|N/A|60 ly|Aged|17,900 ly|White|4
Messier 29|CLUSTER|Open|N/A|11 ly|Young|4,000 ly|Blue|3
Messier 30|CLUSTER|Globular|N/A|93 ly|Aged|27,100 ly|White|4
Messier 31|GALAXY|Spiral|26 Billion L|110,000 ly|Spiral|2.5 Million ly|Cyan|5
Messier 32|GALAXY|Elliptical|N/A|6,500 ly|Elliptical|2.6 Million ly|Cyan|3
Messier 33|GALAXY|Spiral|0.4 Billion L|30,000 ly|Spiral|2.7 Million ly|Cyan|5
Messier 34|CLUSTER|Open|N/A|14 ly|Young|1,500 ly|White|3
Messier 35|CLUSTER|Open|N/A|11 ly|Young|2,800 ly|White|3
Messier 36|CLUSTER|Open|N/A|14 ly|Young|4,100 ly|Blue|3
Messier 37|CLUSTER|Open|N/A|24 ly|Young|4,400 ly|Yellow|3
Messier 38|CLUSTER|Open|N/A|21 ly|Young|4,200 ly|White|3
Messier 39|CLUSTER|Open|N/A|7 ly|Young|800 ly|White|3
Messier 40|STAR|Double Star|N/A|N/A|Double Star|510 ly|Yellow|1
Messier 41|CLUSTER|Open|N/A|25 ly|Young|2,300 ly|White|3
Messier 42|NEBULA|H II Region|2,000 L|12 ly|Star-forming|1,340 ly|Purple|4
Messier 43|NEBULA|H II Region|N/A|N/A|Star-forming|1,600 ly|Purple|3
Messier 44|CLUSTER|Open|N/A|15 ly|Young|577 ly|Yellow|3
Messier 45|CLUSTER|Open|N/A|17 ly|Young|444 ly|Blue|4
Messier 46|CLUSTER|Open|N/A|30 ly|Young|5,400 ly|White|3
Messier 47|CLUSTER|Open|N/A|12 ly|Young|1,600 ly|Blue|3
Messier 48|CLUSTER|Open|N/A|23 ly|Young|1,500 ly|White|3
Messier 49|GALAXY|Elliptical|N/A|160,000 ly|Elliptical|60 Million ly|Cyan|5
Messier 50|CLUSTER|Open|N/A|20 ly|Young|3,200 ly|White|3
Messier 51|GALAXY|Spiral|10 Billion L|30,000 ly|Spiral|23 Million ly|Cyan|5
Messier 52|CLUSTER|Open|N/A|19 ly|Young|5,000 ly|White|3
Messier 53|CLUSTER|Globular|N/A|220 ly|Aged|58,000 ly|White|4
Messier 54|CLUSTER|Globular|N/A|300 ly|Aged|87,000 ly|White|4
Messier 55|CLUSTER|Globular|N/A|100 ly|Aged|17,300 ly|White|4
Messier 56|CLUSTER|Globular|N/A|84 ly|Aged|32,900 ly|White|4
Messier 57|NEBULA|Planetary|200 L|1.3 ly|End of Life|2,300 ly|Blue|3
Messier 58|GALAXY|Barred Spiral|N/A|N/A|Spiral|62 Million ly|Cyan|5
Messier 59|GALAXY|Elliptical|N/A|N/A|Elliptical|60 Million ly|Cyan|5
Messier 60|GALAXY|Elliptical|N/A|120,000 ly|Elliptical|55 Million ly|Cyan|5
Messier 61|GALAXY|Spiral|N/A|100,000 ly|Spiral|52 Million ly|Cyan|5
Messier 62|CLUSTER|Globular|N/A|100 ly|Aged|22,200 ly|White|4
Messier 63|GALAXY|Spiral|N/A|98,000 ly|Spiral|37 Million ly|Cyan|5
Messier 64|GALAXY|Spiral|10 Billion L|26,000 ly|Spiral|17 Million ly|Cyan|5
Messier 65|GALAXY|Barred Spiral|N/A|90,000 ly|Spiral|35 Million ly|Cyan|5
Messier 66|GALAXY|Barred Spiral|N/A|95,000 ly|Spiral|36 Million ly|Cyan|5
Messier 67|CLUSTER|Open|N/A|12 ly|Aged|2,700 ly|Yellow|3
Messier 68|CLUSTER|Globular|N/A|106 ly|Aged|33,300 ly|White|4
Messier 69|CLUSTER|Globular|N/A|61 ly|Aged|29,700 ly|White|4
Messier 70|CLUSTER|Globular|N/A|65 ly|Aged|29,300 ly|White|4
Messier 71|CLUSTER|Globular|N/A|27 ly|Aged|13,000 ly|White|3
Messier 72|CLUSTER|Globular|N/A|106 ly|Aged|55,400 ly|White|4
Messier 73|CLUSTER|Asterism|N/A|N/A|Asterism|2,500 ly|White|2
Messier 74|GALAXY|Spiral|N/A|95,000 ly|Spiral|32 Million ly|Cyan|5
Messier 75|CLUSTER|Globular|N/A|134 ly|Aged|67,500 ly|White|4
Messier 76|NEBULA|Planetary|N/A|1.2 ly|End of Life|3,400 ly|Blue|3
Messier 77|GALAXY|Spiral|N/A|170,000 ly|Spiral|47 Million ly|Cyan|5
Messier 78|NEBULA|Reflection|N/A|4 ly|Star-forming|1,600 ly|Blue|4
Messier 79|CLUSTER|Globular|N/A|118 ly|Aged|41,000 ly|White|4
Messier 80|CLUSTER|Globular|N/A|95 ly|Aged|32,600 ly|White|4
Messier 81|GALAXY|Spiral|20 Billion L|45,000 ly|Spiral|11.8 Million ly|Cyan|5
Messier 82|GALAXY|Starburst|5 Billion L|18,500 ly|Starburst|11.5 Million ly|Cyan|5
Messier 83|GALAXY|Barred Spiral|N/A|55,000 ly|Spiral|15 Million ly|Cyan|5
Messier 84|GALAXY|Lenticular|N/A|N/A|Lenticular|60 Million ly|Cyan|5
Messier 85|GALAXY|Lenticular|N/A|125,000 ly|Lenticular|60 Million ly|Cyan|5
Messier 86|GALAXY|Lenticular|N/A|N/A|Lenticular|52 Million ly|Cyan|5
Messier 87|GALAXY|Elliptical|N/A|120,000 ly|Elliptical|53 Million ly|Cyan|5
Messier 88|GALAXY|Spiral|N/A|130,000 ly|Spiral|47 Million ly|Cyan|5
Messier 89|GALAXY|Elliptical|N/A|N/A|Elliptical|50 Million ly|Cyan|5
Messier 90|GALAXY|Spiral|N/A|165,000 ly|Spiral|58 Million ly|Cyan|5
Messier 91|GALAXY|Barred Spiral|N/A|100,000 ly|Spiral|63 Million ly|Cyan|5
Messier 92|CLUSTER|Globular|N/A|109 ly|Aged|26,700 ly|White|4
Messier 93|CLUSTER|Open|N/A|10 ly|Young|3,600 ly|Blue|3
Messier 94|GALAXY|Spiral|N/A|50,000 ly|Spiral|16 Million ly|Cyan|5
Messier 95|GALAXY|Barred Spiral|N/A|75,000 ly|Spiral|33 Million ly|Cyan|5
Messier 96|GALAXY|Spiral|N/A|100,000 ly|Spiral|31 Million ly|Cyan|5
Messier 97|NEBULA|Planetary|N/A|0.9 ly|End of Life|2,030 ly|Cyan|3
Messier 98|GALAXY|Spiral|N/A|160,000 ly|Spiral|44 Million ly|Cyan|5
Messier 99|GALAXY|Spiral|N/A|80,000 ly|Spiral|50 Million ly|Cyan|5
Messier 100|GALAXY|Spiral|N/A|107,000 ly|Spiral|55 Million ly|Cyan|5
Messier 101|GALAXY|Spiral|30 Billion L|85,000 ly|Spiral|21 Million ly|Cyan|5
Messier 102|GALAXY|Lenticular|N/A|60,000 ly|Lenticular|50 Million ly|Cyan|5
Messier 103|CLUSTER|Open|N/A|15 ly|Young|10,000 ly|White|3
Messier 104|GALAXY|Spiral|800 Billion L|25,000 ly|Spiral|29 Million ly|Cyan|5
Messier 105|GALAXY|Elliptical|N/A|N/A|Elliptical|32 Million ly|Cyan|5
Messier 106|GALAXY|Spiral|N/A|135,000 ly|Spiral|23 Million ly|Cyan|5
Messier 107|CLUSTER|Globular|N/A|80 ly|Aged|20,900 ly|White|4
Messier 108|GALAXY|Spiral|N/A|100,000 ly|Spiral|45 Million ly|Cyan|5
Messier 109|GALAXY|Barred Spiral|N/A|180,000 ly|Spiral|83 Million ly|Cyan|5
Messier 110|GALAXY|Elliptical|N/A|17,000 ly|Elliptical|2.7 Million ly|Cyan|4
HR 1|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 2|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 3|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 4|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 5|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 6|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 7|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 8|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 9|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 10|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 11|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 12|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 13|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 14|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 15|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 16|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 17|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 18|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 19|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 20|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 21|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 22|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 23|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 24|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 25|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 26|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 27|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 28|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 29|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 30|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 31|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 32|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 33|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 34|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 35|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 36|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 37|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 38|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 39|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 40|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 41|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 42|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 43|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 44|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 45|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 46|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 47|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 48|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 49|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 50|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 51|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 52|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 53|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 54|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 55|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 56|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 57|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 58|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 59|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 60|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 61|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 62|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 63|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 64|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 65|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 66|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 67|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 68|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 69|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 70|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 71|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 72|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 73|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 74|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 75|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 76|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 77|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 78|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 79|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 80|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 81|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 82|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 83|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 84|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 85|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 86|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 87|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 88|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 89|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 90|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 91|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 92|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 93|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 94|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 95|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 96|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 97|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 98|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 99|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 100|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 101|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 102|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 103|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 104|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 105|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 106|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 107|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 108|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 109|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 110|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 111|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 112|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 113|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 114|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 115|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 116|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 117|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 118|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 119|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 120|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 121|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 122|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 123|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 124|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 125|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 126|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 127|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 128|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 129|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 130|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 131|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 132|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 133|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 134|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 135|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 136|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 137|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 138|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 139|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 140|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 141|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 142|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 143|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 144|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 145|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 146|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 147|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 148|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 149|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 150|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 151|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 152|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 153|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 154|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 155|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 156|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 157|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 158|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 159|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 160|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 161|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 162|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 163|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 164|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 165|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 166|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 167|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 168|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 169|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 170|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 171|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 172|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 173|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 174|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 175|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 176|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 177|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 178|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 179|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 180|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 181|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 182|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 183|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 184|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 185|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 186|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 187|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 188|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 189|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 190|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 191|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 192|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 193|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 194|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 195|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 196|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 197|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 198|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 199|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 200|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 201|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 202|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 203|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 204|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 205|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 206|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 207|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 208|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 209|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 210|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 211|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 212|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 213|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 214|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 215|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 216|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 217|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 218|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 219|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 220|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 221|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 222|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 223|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 224|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 225|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 226|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 227|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 228|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 229|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 230|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 231|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 232|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 233|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 234|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 235|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 236|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 237|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 238|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 239|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 240|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 241|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 242|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 243|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 244|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 245|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 246|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 247|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 248|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 249|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 250|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 251|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 252|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 253|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 254|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 255|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 256|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 257|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 258|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 259|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 260|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 261|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 262|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 263|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 264|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 265|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 266|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 267|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 268|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 269|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 270|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 271|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 272|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 273|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 274|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 275|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 276|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 277|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 278|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 279|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 280|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 281|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 282|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 283|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 284|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 285|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 286|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 287|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 288|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 289|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 290|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 291|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 292|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 293|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 294|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 295|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 296|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 297|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 298|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 299|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 300|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 301|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 302|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 303|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 304|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 305|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 306|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 307|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 308|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 309|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 310|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 311|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 312|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 313|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 314|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 315|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 316|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 317|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 318|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 319|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 320|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 321|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 322|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 323|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 324|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 325|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 326|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 327|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 328|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 329|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 330|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 331|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 332|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 333|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 334|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 335|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 336|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 337|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 338|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 339|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 340|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 341|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 342|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 343|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 344|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 345|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 346|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 347|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 348|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 349|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 350|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 351|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 352|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 353|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 354|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 355|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 356|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 357|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 358|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 359|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 360|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 361|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 362|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 363|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 364|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 365|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 366|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 367|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 368|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 369|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 370|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 371|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 372|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 373|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 374|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 375|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 376|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 377|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 378|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 379|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 380|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 381|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 382|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 383|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 384|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 385|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 386|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 387|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 388|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 389|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 390|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 391|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 392|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 393|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 394|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 395|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 396|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 397|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 398|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 399|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 400|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 401|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 402|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 403|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 404|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 405|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 406|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 407|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 408|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 409|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 410|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 411|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 412|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 413|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 414|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 415|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 416|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 417|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 418|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 419|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 420|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 421|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 422|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 423|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 424|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 425|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 426|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 427|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 428|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 429|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 430|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 431|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 432|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 433|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 434|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 435|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 436|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 437|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 438|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 439|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 440|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 441|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 442|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 443|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 444|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 445|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 446|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 447|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 448|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 449|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 450|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 451|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 452|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 453|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 454|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 455|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 456|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 457|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 458|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 459|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 460|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 461|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 462|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 463|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 464|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 465|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 466|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 467|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 468|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 469|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 470|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 471|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 472|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 473|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 474|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 475|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 476|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 477|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 478|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 479|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 480|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 481|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 482|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 483|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 484|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 485|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 486|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 487|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 488|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 489|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 490|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 491|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 492|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 493|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 494|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 495|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 496|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 497|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 498|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 499|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 500|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 501|STAR|K0III|N/A|N/A|Giant|200 ly|Orange|3
HR 502|STAR|A0V|N/A|N/A|Main Sequence|150 ly|White|2
HR 503|STAR|G5V|N/A|N/A|Main Sequence|80 ly|Yellow|2
HR 504|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 505|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 506|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 507|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 508|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 509|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 510|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 511|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 512|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 513|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 514|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 515|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 516|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 517|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 518|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 519|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 520|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 521|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 522|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 523|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 524|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 525|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 526|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 527|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 528|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 529|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 530|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 531|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 532|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 533|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 534|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 535|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 536|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 537|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 538|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 539|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 540|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 541|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 542|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 543|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
HR 544|STAR|M2V|N/A|N/A|Main Sequence|35 ly|Red|1
HR 545|STAR|F6V|N/A|N/A|Main Sequence|95 ly|White|2
HR 546|STAR|G2III|N/A|N/A|Giant|145 ly|Yellow|3
HR 547|STAR|A5IV|N/A|N/A|Subgiant|125 ly|White|2
HR 548|STAR|B8IV|N/A|N/A|Subgiant|480 ly|Blue|3
HR 549|STAR|K4III|N/A|N/A|Giant|210 ly|Orange|3
HR 550|STAR|M5III|N/A|N/A|Giant|330 ly|Red|4
HR 551|STAR|F0IV|N/A|N/A|Subgiant|135 ly|White|2
HR 552|STAR|G5V|N/A|N/A|Main Sequence|65 ly|Yellow|2
HR 553|STAR|A2IV|N/A|N/A|Subgiant|115 ly|White|2
HR 554|STAR|B2IV|N/A|N/A|Subgiant|620 ly|Blue|3
HR 555|STAR|K3V|N/A|N/A|Main Sequence|48 ly|Orange|2
HR 556|STAR|M0V|N/A|N/A|Main Sequence|28 ly|Red|1
HR 557|STAR|F5IV|N/A|N/A|Subgiant|105 ly|White|2
HR 558|STAR|G3V|N/A|N/A|Main Sequence|42 ly|Yellow|2
HR 559|STAR|A7IV|N/A|N/A|Subgiant|145 ly|White|2
HR 560|STAR|B5IV|N/A|N/A|Subgiant|370 ly|Blue|3
HR 561|STAR|K0III|N/A|N/A|Giant|175 ly|Orange|3
HR 562|STAR|M3V|N/A|N/A|Main Sequence|32 ly|Red|1
HR 563|STAR|F8IV|N/A|N/A|Subgiant|115 ly|White|2
HR 564|STAR|G0V|N/A|N/A|Main Sequence|38 ly|Yellow|2
HR 565|STAR|A1III|N/A|N/A|Giant|155 ly|White|3
HR 566|STAR|B9III|N/A|N/A|Giant|460 ly|Blue|3
HR 567|STAR|K2III|N/A|N/A|Giant|205 ly|Orange|3
HR 568|STAR|M4V|N/A|N/A|Main Sequence|22 ly|Red|1
HR 569|STAR|F2V|N/A|N/A|Main Sequence|85 ly|White|2
HR 570|STAR|G6III|N/A|N/A|Giant|165 ly|Yellow|3
HR 571|STAR|A3III|N/A|N/A|Giant|145 ly|White|3
HR 572|STAR|B3III|N/A|N/A|Giant|580 ly|Blue|3
HR 573|STAR|K5III|N/A|N/A|Giant|230 ly|Orange|3
HR 574|STAR|M6III|N/A|N/A|Giant|350 ly|Red|4
HR 575|STAR|F0III|N/A|N/A|Giant|135 ly|White|3
HR 576|STAR|G1V|N/A|N/A|Main Sequence|52 ly|Yellow|2
HR 577|STAR|A5III|N/A|N/A|Giant|165 ly|White|3
HR 578|STAR|B7III|N/A|N/A|Giant|410 ly|Blue|3
HR 579|STAR|K3III|N/A|N/A|Giant|195 ly|Orange|3
HR 580|STAR|M1V|N/A|N/A|Main Sequence|26 ly|Red|1
HR 581|STAR|F5III|N/A|N/A|Giant|115 ly|White|3
HR 582|STAR|G5V|N/A|N/A|Main Sequence|48 ly|Yellow|2
HR 583|STAR|A2III|N/A|N/A|Giant|135 ly|White|3
HR 584|STAR|B2III|N/A|N/A|Giant|650 ly|Blue|4
HR 585|STAR|K4V|N/A|N/A|Main Sequence|58 ly|Orange|2
HR 586|STAR|M2V|N/A|N/A|Main Sequence|34 ly|Red|1
HR 587|STAR|F8V|N/A|N/A|Main Sequence|92 ly|White|2
HR 588|STAR|G0III|N/A|N/A|Giant|142 ly|Yellow|3
HR 589|STAR|A7III|N/A|N/A|Giant|172 ly|White|3
HR 590|STAR|B5III|N/A|N/A|Giant|382 ly|Blue|3
HR 591|STAR|K1V|N/A|N/A|Main Sequence|42 ly|Orange|2
HR 592|STAR|M0III|N/A|N/A|Giant|212 ly|Red|4
HR 593|STAR|F1V|N/A|N/A|Main Sequence|102 ly|White|2
HR 594|STAR|G2V|N/A|N/A|Main Sequence|32 ly|Yellow|2
HR 595|STAR|A3V|N/A|N/A|Main Sequence|112 ly|White|2
HR 596|STAR|B8V|N/A|N/A|Main Sequence|432 ly|Blue|3
HR 597|STAR|K2III|N/A|N/A|Giant|182 ly|Orange|3
HR 598|STAR|M3V|N/A|N/A|Main Sequence|24 ly|Red|1
HR 599|STAR|F6V|N/A|N/A|Main Sequence|98 ly|White|2
HR 600|STAR|G3III|N/A|N/A|Giant|152 ly|Yellow|3
HR 1011|STAR|B3V|N/A|N/A|Main Sequence|500 ly|Blue|3
HR 1012|STAR|F2V|N/A|N/A|Main Sequence|120 ly|White|2
HR 1013|STAR|M2III|N/A|N/A|Giant|300 ly|Red|4
HR 1014|STAR|K5V|N/A|N/A|Main Sequence|60 ly|Orange|2
HR 1015|STAR|A1V|N/A|N/A|Main Sequence|90 ly|White|2
HR 1016|STAR|B8V|N/A|N/A|Main Sequence|400 ly|Blue|3
HR 1017|STAR|G0V|N/A|N/A|Main Sequence|70 ly|Yellow|2
HR 1018|STAR|F8V|N/A|N/A|Main Sequence|110 ly|White|2
HR 1019|STAR|M1III|N/A|N/A|Giant|250 ly|Red|4
HR 1020|STAR|A2V|N/A|N/A|Main Sequence|100 ly|White|2
HR 1021|STAR|K2III|N/A|N/A|Giant|180 ly|Orange|3
HR 1022|STAR|B5V|N/A|N/A|Main Sequence|350 ly|Blue|3
HR 1023|STAR|G8V|N/A|N/A|Main Sequence|50 ly|Yellow|2
HR 1024|STAR|A5V|N/A|N/A|Main Sequence|130 ly|White|2
HR 1025|STAR|K1V|N/A|N/A|Main Sequence|40 ly|Orange|2
HR 1026|STAR|B2V|N/A|N/A|Main Sequence|600 ly|Blue|3
HR 1027|STAR|M0III|N/A|N/A|Giant|220 ly|Red|4
HR 1028|STAR|F0V|N/A|N/A|Main Sequence|140 ly|White|2
HR 1029|STAR|G2V|N/A|N/A|Main Sequence|30 ly|Yellow|2
HR 1030|STAR|A3V|N/A|N/A|Main Sequence|110 ly|White|2
HR 1031|STAR|B9V|N/A|N/A|Main Sequence|450 ly|Blue|3
HR 1032|STAR|K3III|N/A|N/A|Giant|160 ly|Orange|3
HR 1033|STAR|M3III|N/A|N/A|Giant|280 ly|Red|4
HR 1034|STAR|F5V|N/A|N/A|Main Sequence|100 ly|White|2
HR 1035|STAR|G5III|N/A|N/A|Giant|150 ly|Yellow|3
HR 1036|STAR|A7V|N/A|N/A|Main Sequence|120 ly|White|2
HR 1037|STAR|B7V|N/A|N/A|Main Sequence|380 ly|Blue|3
HR 1038|STAR|K0V|N/A|N/A|Main Sequence|45 ly|Orange|2
HR 1039|STAR|M4III|N/A|N/A|Giant|310 ly|Red|4
HR 1040|STAR|F8III|N/A|N/A|Giant|140 ly|White|3
HR 1041|STAR|G0III|N/A|N/A|Giant|130 ly|Yellow|3
HR 1042|STAR|A1V|N/A|N/A|Main Sequence|85 ly|White|2
HR 1043|STAR|B6V|N/A|N/A|Main Sequence|420 ly|Blue|3
HR 1044|STAR|K2V|N/A|N/A|Main Sequence|55 ly|Orange|2
HR 1045|STAR|M1V|N/A|N/A|Main Sequence|25 ly|Red|1
HR 1046|STAR|F2III|N/A|N/A|Giant|170 ly|White|3
HR 1047|STAR|G8III|N/A|N/A|Giant|160 ly|Yellow|3
HR 1048|STAR|A0IV|N/A|N/A|Subgiant|110 ly|White|2
HR 1049|STAR|B3IV|N/A|N/A|Subgiant|550 ly|Blue|3
HR 1050|STAR|K1III|N/A|N/A|Giant|190 ly|Orange|3
