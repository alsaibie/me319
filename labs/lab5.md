@def title = "Lab 5 - Communications"
@def hascode = true

# Lab 4 - Timers and Interrupts

## Overview
In this assignment you will be practicing exchanging information between the PC and microcontroller.

Before attempting this assignment, make sure you go through the prelab 5 document first.

## Tools Required
- VSCode with PlatformIO Extension
- MATLAB (Julia or Python also OK)
- STM32 Nucleo F401RE Board 
- USB Type A to USB Mini-B Connector

## References
1. [REF03 STM32 Nucleo-64 boards User Manual](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
2. [REF01 STM32F401RE Datasheet](/assets/assets/reference_docs/REF01_STM32F401RE_DATASHEET.pdf)
3. [REF02 STM32F401RE Reference Manual](/assets/reference_docs/REF02_STM32F401xBC_and_STM32F401xDE_Reference_Manual.pdf)
4. Lab Report Submission Guidelines
5. [ME319 Prelab 5](/prelabs/prelab5/)

## Project Creation & Submission

For this assignment, it is suggested that you create a single project with multiple `main*.cpp` files, inside the **src** folder, for each question below.

You only need to submit the (`mainQ1.cpp`, `mainQ2.cpp`, etc) files for this  assignment. As well as the your PC client scripts (`ScriptQ1.m`, `ScriptQ2.m`)

To have one project with multiple source files, where you only compile one at a  ime, you need to configure `platformio.ini` to only compile the file you want. Replace the content of the `platformio.ini` with this, then change `mainQ1.cpp` to the file name you wish to compile. The last line (src_filter) basically tells the platformio configurator to remove all `main*.cpp` from the compile list, then add only the specific mainQ1.cpp file. If we don't add this filter line, all the files inside the folder **src** will be compiled.

```ini
[env:nucleo_f401re]
platform = ststm32
board = nucleo_f401re
framework = arduino
src_filter = -<main*.cpp> +<mainQ1.cpp>
monitor_speed = 250000 
lib_deps = bblanchon/ArduinoJson @ ^6.17.3
```

## Questions

### 1. Parsing and Serializing Data between PC and MCU
You are given a MATLAB Script and a code template for the microcontroller. The MATLAB scripts emulates a GPS message and sends it to the microcontroller via the serial port in the following form: 

```
$GPS,time,lat,lon,speed
```

\input{plaintext}{/labs/l5assets/L5Script.m}


This is similar to the format of actual GPS sensor messages, but the units, length of message and additional info are different.

The job of the microcontroller is to parse the GPS message and save the parsed values into a local message struct. Then use JSON to serialize the message struct and send it back to the PC.

The MATLAB script will receive and decode the JSON messages from the microcontroller and then update an animated plot of a GPS position.

~~~
<center><img src="/labs/l5assets/LAB5CommsMessageProcess.svg" style="max-width:720px"></center>~~~ 

The MATLAB script is complete. Your task is to complete two parts in the
microcontroller code:

1.  Parse the GPS message received and save into the message struct.
    - The parsing is partially done for you, complete it. Look up the standard library functions `strtok()`, and `atof()` to understand how to parse a message.

2.  Serialize the GPS message struct into a JSON object and send it back to the PC.
    - The prelab examples should be sufficient. Check the MATLAB script to confirm the order and format required for the message.

\input{cpp}{/labs/l5assets/mainQ1template.cpp}
