@def title = "Lab 3 - Low Level GPIO Control"
@def hascode = true

# Lab 3 -  Low Level GPIO Control

## Overview
In this assignment, you will learn how to interface with the microcontroller at the register level. You will extend the GPIO Blinky example where we used the `stm32f401x.h` header and convert it into an LED switch example. Then you will refractor your routine into what looks like an equivalent Arduino framework routine. 

Before attempting this assignment, make sure you go through the Prelab 3 document first. 

## Tools Required
- VSCode with PlatformIO Extension
- STM32 Nucleo F401RE Board 
- USB Type A to USB Mini-B Connector

## References
1. [REF03 STM32 Nucleo-64 boards User Manual](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
2. [REF01 STM32F401RE Datasheet](/assets/assets/reference_docs/REF01_STM32F401RE_DATASHEET.pdf)
3. [REF02 STM32F401RE Reference Manual](/assets/reference_docs/REF02_STM32F401xBC_and_STM32F401xDE_Reference_Manual.pdf)
4. Lab Report Submission Guidelines
5. ME319 Prelab 3
  
## Project Creation & Submission
For this assignment, it is suggested that you create a single project with multiple main*.cpp files, inside the src folder, for each question below.
You only need to submit the (`mainQ1.c`, `mainQ2.c`, etc) files for this assignment.

To have one project with multiple source files, where you only compile one at a time, you need to configure platformio.ini to only compile the file you want. Replace the content of the platformio.ini with this, then change mainQ1.cpp to the file name you wish to compile. The last line (src_filter) basically tells the platformio configurator to remove all main*.cpp from the compile list, then add only the specific mainQ1.c file. If we don’t add this filter line, all the files inside the folder src will be compiled.

```ini
[env:nucleo_f401re]
platform = ststm32
board = nucleo_f401re
framework = stm32cube ; Note we are using stm32cube here, not arduino
src_filter = -<main*.c> +<mainQ1.c>
```

## Questions
### 1. LED Switch
Starting from the 3rd example prelab3 (`mainE3.c`), instead of a timed LED blinky code, turn the program into an LED switch. Where the built-in switch connected to PC13 will act as a switch to turn on the LED. PC13 lives in GPIO port C. You will need to 
-	Enable GPIO Port C
-	Set GPIO Port C Pin 13 as input (by default it should be)
-	Read GPIO Port C IDR register Pin 13. 
Remember that the built-in switch is connected in negative logic, (LOW: Switch is pressed, HIGH: Not pressed)

`mainQ1_template.c`
```cpp
#include "stm32f401xe.h"

/***
 * Blinky Program - LED connected to PA5
 * */

int main(void) {
    /* Enable GPIOA Clock */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN; /* Ref RCC_AHB2ENR register */
    /* Set Port A Pin 5 as Output */
    GPIOA->MODER |= (1 << GPIO_MODER_MODE5_Pos); /* Ref GPIOx_MODER register */
    while (1) {
        /* Set LED Pin High */
        GPIOA->ODR |= (1 << GPIO_ODR_OD5_Pos); /* Ref GPIOx_ODR register*/
        /* Dumb Delay: wait x number of clock cycles */
        for (int k = 0; k<1000000; k++){__asm("nop");}
        /* Set LED Pin Low */
        GPIOA->ODR &= ~(1 << GPIO_ODR_OD5_Pos); /* Ref GPIOx_ODR register*/
        /* Dumb Delay */
        for (int k = 0; k<1000000; k++){__asm("nop");}
    }
}
```
### How to read a pin
Remember that you can treat the register (content of) as a variable. If you wanted to read the state of the 3rd bit only, what would you do?

You would need to clear all the other bits and leave the one of interest. So if the register contains `0b0010X011`, and you are only interested in the 3rd bit, you would want this to be conveted to `0b0000X000` where `X` could be `1` or `0`. If `X` is zero then the whole number is equal to zero, if it is `1` the number is not equal to one, it's equal to 8, but more generally it is NOT zero. What bitwise operation is required to do this? And how?


### 2. Arduino-like LED Switch Code
You will need to complete Question 1 first.

You are given a template code (`mainQ2_template.c`). Defined inside the `setup()` and `loop()` functions, the code that you would normally have if you were using the arduino framework, to have an LED switch code. 

Your job is to define the following functions, in order for the program to work: `pinMode()`, `digitalWrite()` and `digitalRead()`

You can hardcode the register names for the input and output pins inside the functions (The Arduino framework uses a look up map to find the registers for which the pin belongs to).

You will use `pinMode()` for two pins, an input and output, so you will need to distinguish which pin you have. While `digitalWrite()` and `digitalRead()` each will expect one known pin number. 

`mainQ2_template.c`

```cpp
#include "stm32f401xe.h"

/***
 * Blinky Switch Program
 * LED connected to PA5
 * Switch connected to PC13 (Negative Logic)
 * */

#define PA5 0x05
#define PC13 0x2D
#define OUTPUT 1
#define INPUT 0
#define HIGH 1
#define LOW 0

void pinMode(int _pin, int _mode) {
    /* TBC */

}

void digitalWrite(int _pin, int _v) {
    /* TBC */

}

int digitalRead(int _pin) {
    /* TBC */
}

void setup() {
    pinMode(PA5, OUTPUT);
    pinMode(PC13, INPUT);
}

void loop() {
    int buttonState = digitalRead(PC13);
    if (buttonState == LOW) {
        digitalWrite(PA5, HIGH);
    } else {
        digitalWrite(PA5, LOW);
    }
}

/* A similar routine is preconfigured in the Arduino framework inside the main function */
int main(void) {
    setup();
    while (1) {
        loop();
    }
}
```