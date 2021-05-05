@def title = "Lab 2 - Getting familiar with PlatformIO and Arduino"
@def hascode = true

# Lab 2 - C++ With Arduino

## Overview
In this assignment you will continue to carry out a number of C++ exercises, but in the context of the microcontroller.  
Before attempting this assignment, make sure you go through the [Prelab 2](/prelabs/prelab2/index.html) first. Ensure you can compile and flash your code onto the MCU.

## Tools Required
- VSCode with PlatformIO Extension
- STM32 Nucleo F401RE Board 
- USB Type A to USB Mini-B Connector

## References
1. [REF03 STM32 Nucleo-64 boards User Manual](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
2. Lab Report Submission Guidelines
3. ME319 Prelab 2

## Project Creation & Submission
For this assignment, it is suggested that you create a single project with multiple main*.cpp files, inside the src folder, for each question below.
You only need to submit the (`mainQ1.cpp`, `mainQ2.cpp`, etc) files for this assignment.

To have one project with multiple source files, where you only compile one at a time, you need to configure platformio.ini to only compile the file you want. Replace the content of the platformio.ini with this, then change mainQ1.cpp to the file name you wish to compile. The last line (`src_filter`) basically tells the platformio configurator to remove all `main*.cpp` from the compile list, then add only the specific `mainQ1.cpp` file. If we don’t add this filter line, all the files inside the folder src will be compiled.

```ini
[env:nucleo_f401re]
platform = ststm32
board = nucleo_f401re
framework = arduino
src_filter = -<main*.cpp> +<mainQ1.cpp>
```

## Questions
### 1. Basic Calculator
For this question you will complete the code for a basic calculator that performs addition, subtraction, multiplication and division. You will input the mathematical operation through the serial terminal to the microcontroller, the microcontroller will determine the type of operation, compute the result then send the result back to the PC. 

The format in which you will send the command is NumOpNum (E.g.: `4+3`), the code in the template already takes care of parsing the first number, the operation and the second number. Your task is to determine the type of operation requested (out of the basic 4 math operations), then perform the operation and return the result through the serial terminal. Hint: Use a switch statement

Question Template
```cpp
#include <Arduino.h>
/* Basic Calculator */
void setup()
{
  Serial.begin(9600);
}

void loop(){

  while(Serial.available() > 0){
    int numA = Serial.parseInt();
    char MathOp = Serial.read();
    int numB = Serial.parseInt();
    /* TBC */
  }
}
```
### 2. Object Oriented Programming
In this example you will practice building a class to represent a light switch that blinks with different patterns. This might be an overkill for the functionality of a light but the concepts can be extended to more advanced applications. 

What we have is a LightSwitch class that holds the values of the LED pin, the mode (pattern mode). It also has a function to set the switch on (LED on) or off (LED off). A function to set the mode of blinking and functions to grab the private variables as well. Review the structure of the template and complete the following tasks:

1. Complete the definition of the class constructor. More specifically, assign the `_ledpin` value, then apply default values for the remaining class internal variables (`_mode`, `_switch_state`)
2. Declare and then define functions to grab each of the internal variables (`getMode()`, `getState()`), these functions only return the internal variables of the class object (since the internal variables are private they can not be accessed directly, so we use a getter function).
3. Apply the pattern by calling the function delay then passing the amount of delay based on the mode and pattern counter sequence, then toggle the LED by applying the `setSwitch()` function. Hint: You can pass `setSwitch` the inverse of what getState() gives. No bitwise XOR needed.

To test your program, the LED on board the STM32Nucleo should blink with the first pattern. If you press the user button long enough the mode will switch, and a new pattern will be seen and so on. 

Question Template
```cpp
#include <Arduino.h>

#define Mode1 0
#define Mode2 1
#define Mode3 2

uint16_t blink_pattern[3][4] = {{100, 400, 800, 1600}, {200, 200, 200, 800}, {250, 250, 250, 250}};

class LightSwitch {
   uint8_t _ledpin;
   uint8_t _mode;
   bool  _switch_state;
   public:
    LightSwitch(uint8_t pinNumber);
    void setSwitch(bool On);
    void setMode(uint8_t mode);
    
    /* TBC */

};

LightSwitch::LightSwitch(uint8_t pinNum) { 
  /* TBC */
  
  pinMode(_ledpin, OUTPUT);
 };


void LightSwitch::setSwitch(bool On){
  digitalWrite(_ledpin, On);
  _switch_state = On;
}

void LightSwitch::setMode(uint8_t mode){
_mode = mode;
};


LightSwitch Light(LED_BUILTIN);

void setup() {
    Serial.begin(9600);
    pinMode(USER_BTN, INPUT);
}

void loop() {

  /* change mode with long press */
  delay(100);

  static uint16_t counter = 0; /* to track the button press */
  static uint8_t pattern_counter = 0; /* to iterate over the pattern */

  if(!digitalRead(USER_BTN)){
    counter++;
  }
  else
  { counter = 0; }

  if (counter * 400 > 2000){ /* Not the best way to check time elapsed but works in a way */
    uint8_t current_mode = Light.getMode();
    if(current_mode == Mode3){
      Light.setMode(Mode1); /* Start again from Mode 1 */
    }
    else { Light.setMode(current_mode + 1); } /* or increase mode number */
    counter = 0;
    Serial.print("Mode Change to: "); Serial.println(Light.getMode());  
  }
  
  pattern_counter++;
  if (pattern_counter == 4) pattern_counter = 0; /* zero after end of pattern length */
  /* TBC */
}
```

### 3. Bitwise Operation
In this problem you will apply some bitwise operation magic to emulate patterned switching of a bank of LED. So assuming you have a bank of 8 LEDs, you will define a sweep function where the LED strip will look as if its scrolling to the left or to the right. You will define a function to toggle chosen bits and a function to clear or set bits. Then, you will combine them to create a pattern. 

You don’t have yet a strip of LEDs, so you will emulate the affect by printing 8 characters through the serial terminal where ‘|’ represents an ON LED and ‘-‘ represents an OFF LED. The printing function is already define for you. So perform the following:
- Define the `sweep_bank()` function. It takes the current bank state of byte size (representing in bits the off and on state of each of 8 LEDs) and the direction of the sweep. The function, based on the direction of sweep should store the value (left or right), then you can sweep by shifting the bits (left or right) by 1, then you bring back the last bit. Because if you didn’t save the last bit it will drop off and be lost when bit shifting.
- Define the `toggle_bank()` function. The function takes the bank values by reference and the bitmask. This is a straightforward toggle operation. 
- Define the `set_clear_bank()` function. Based on the bool value (true or false) it will either clear all the bits of the bank or set all the bits of the bank.
- Given the above functions, create your own pattern. For example you may want to make a full sweep of the LED bank (8 consecutive shifts), then blink (toggle) a few times and then repeat the process. Be creative. 

Question Template
```cpp
#include <Arduino.h>

uint8_t LED_Bank = 0x80;
#define LEFT 1
#define RIGHT 0

void setup() { Serial.begin(9600); }

void sweep_bank(uint8_t &bank, uint8_t dir) {
    /* TBC */

}

void toggle_bank(uint8_t &bank, uint8_t bitmask) {
    /* TBC */

}

void set_clear_bank(uint8_t &bank, bool on) {
    /* TBC */
}

void print_bank(uint8_t &bank){
    uint8_t bank_characters[8];
    for (uint8_t k = 8; k >0; --k){
        bank_characters[k-1] = (bank & (1<<(k-1))? '|' : '-');
        Serial.print((char)bank_characters[k-1]);
    }
    Serial.println();
}

void loop() {

    delay(1000);
    print_bank(LED_Bank);
    sweep_bank(LED_Bank, RIGHT);
    /* TBC */
}
```