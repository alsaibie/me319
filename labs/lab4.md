@def title = "Lab 4 - Timers and Interrupts"
@def hascode = true

# Lab 4 - Timers and Interrupts

## Overview
In this assignment you will be practicing setting up timers and interrupts.

Before attempting this assignment, make sure you go through the [Prelab 4](/prelabs/prelab4/) document first.

## Tools Required
- VSCode with PlatformIO Extension
- STM32 Nucleo F401RE Board 
- USB Type A to USB Mini-B Connector
- Jumper Wire

## References
1. [REF03 STM32 Nucleo-64 boards User Manual](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
2. [REF01 STM32F401RE Datasheet](/assets/assets/reference_docs/REF01_STM32F401RE_DATASHEET.pdf)
3. [REF02 STM32F401RE Reference Manual](/assets/reference_docs/REF02_STM32F401xBC_and_STM32F401xDE_Reference_Manual.pdf)
4. Lab Report Submission Guidelines
5. [ME319 Prelab 4](/prelabs/prelab4/)

## Project Creation & Submission

For this assignment, it is suggested that you create a single project with multiple `main*.cpp` files, inside the `src` folder, for each question below.

You only need to submit the (`mainQ1.cpp`, `mainQ2.cpp`, etc) files for this assignment.

To have one project with multiple source files, where you only compile one at a time, you need to configure platformio.ini to only compile the file you want. Replace the content of the platformio.ini with this, then change mainQ1.cpp to the file name you wish to compile. The last line (src_filter) basically tells the platformio configurator to remove all `main*.cpp` from the compile list, then add only the specific mainQ1.cpp file. If we don't add this filter line, all the files inside the folder `src` will be compiled.
```cpp
[env:nucleo_f401re]
platform = ststm32
board = nucleo_f401re
framework = arduino
src_filter = -<main*.cpp> +<mainQ1.cpp>
```

## Questions

### 1. PWM Sweep
For this task you need to create 2 timers, one periodic and one for generating a PWM signal.

On the STM32F401x there are 8 timers. You can choose any timer to be the source of the periodic callback, but you can only choose specific timers for generating PWM signals, depending on the timers' capability and depending on the output pins available for use.

~~~
<center><img src="/labs/l4media/Table4DatasheetTimerFeatures.svg" style="max-width:780px"></center>~~~ 


We want to use the PWM signal to control the built-in LED, PA5, which can only be connected to Channel 1 of TIM2 (other pins may be connected to either of two channels of two timers).
~~~
<center><img src="/labs/l4media/Table9Datasheet_AltFunctions.svg" style="max-width:780px"></center>~~~ 

Following the examples from prelab 4. Create a periodic timer to execute a callback function @ 5Hz and setup another timer to generate a PWM signal on the LED pin (PA5).

In the periodic callback function perform the following routine:

Sweep up/down/up/down and repeate the duty cycle of the PWM signal. In other words, increment the duty cycle of the PWM signal by small increments at every callback call to the periodic interrupt, from 0 to 100, then decrement from 100 to 0 and repeat.

Experiment with different PWM increment/decrement values and different periodic function callback frequency, in order to observe a gradual change of brightness of the LED as you sweep the duty cycle.

Note: You need to make the pwm timer instance global so you can access it in the setup() and callback functions. See the TimerIC example in Example 3 of Prelab 4.

### 2. GPIO Interrupt
Create a GPIO event interrupt to count the number of times the user button is pressed inside the interrupt callback function. Also print to the serial stream the latest count value.

Also program a routine that would reset the press count value, if the button was pressed for longer than 2 seconds. 

Hint: Once you enter the interrupt callback function, put a while loop to keep track of the time elapsed while the button remains pressed, so either the button is
un-pressed or more than 2 seconds have passed. You can use the Arduino function millis() that would return the time elapsed in milliseconds since the MCU had booted.

If the counter value was reset, print to the serial stream that the reset occurred.

For the counter variable, use a static variable inside the callback function.