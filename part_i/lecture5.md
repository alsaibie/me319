@def title = "Part I L5 - GPIO"
@def hascode = true

# Part I L5 - General Purpose Input Output

## Lecture Video
~~~
<iframe src="https://player.vimeo.com/video/540099285" width="780" height="438" frameborder="0" allowfullscreen></iframe>
~~~
[Lecture Handout](/part_i\/ME319_-_Mechatronics_-_Part_I_Lecture_5_GPIO.pdf)

Next: [Part I L6 - Timers](../lecture6/)  

## Objectives
- Review the basic components of the GPIO Peripheral
- Become familiar with the microcontroller reference manual
- Walk through a blinky routine at different abstraction levels

### What is a GPIO

GPIO, which stands for General Purpose Input Output, provides a basic way to interface the MCU with the outside world. It's a name of a peripheral that allows for setting pin directions is input or output, it allows for setting the value of output pins, Logic High or Logic Low, and it allows for reading the state of input pins.  

GPIO Pins belong to Ports, On STM32F401x there are up to 16 pins per port
On STM32F401x, most pins are GPIO by default (on reset), some pins are set for special functions on reset (JTAG). All input pins are 5V-Tolerant even though the MCU operates on 3.3V. There are 15 GPIO Blocks. Ports A - Port Q [No Port I or Port O], each pin has an internal optional weak pull-up or pull-down resisters.

### Example 
~~~
<center><img src="/part_i/lecture5_media/GPIOExampleLEDSwitch.svg" style="max-width:425px"></center>~~~

Pin PA1 and PA0 are both configured as GPIO pins. 

PA1 is read as "Port A Pin 1", and similarly PA0 is read "Port A Pin 0"
PA1 is set as an output pin while PA0 as set as an input pin.

When PA1 is set High (Logic 1) the **LED** turns on. And when the switch **SW** is pressed, pin PA0 reads logic 1 (High). An output pin is **set** and an input pin is **read**.
The GPIO Peripheral usually has multiple ports, which have multiple pins.

## Alternate Functions

GPIO Pins also refer to programmable pins in general (non-fixed func pins: GND, 5V, etc), so every pin that is programmed for a general GPIO or other peripheral function is still referred to as a GPIO pin. 
GPIO pins can be configured for alternative functions such as: UART,I2C,ADC,DAC etc.
Table 9 in the datasheet lists the alternate functions each pin can have. A has a physical identification on the MCU package and it can only serve one function at a time. 
E.g. Pins PA0 and PA1 can have one of 4 alternative digital functions:
1. Timer2 Ch 1
2. Timer 5 Ch 2
3. USART Clear To Send
4. or Event Out (Interrupt Pin) 

~~~
<center><img src="/part_i/lecture5_media/Table9Datasheet_AltFunctions.svg" style="max-width:780px"></center>~~~

## Current Capabilities
Pins can drive low current external devices, such as LEDs or other integrated circuits, they are not capable of driving higher load devices. A GPIO pin on an MCU can not provide enough current to light a 60W light bulb or turn even a small DC motor. 
~~~
<center><img src="/part_i/lecture5_media/Table12Datasheet_ElectricalChar.svg" style="max-width:780px"></center>~~~

To drive high current devices such as a light bulb, an external driver is required. The pin signal from the MCU acts as a trigger to the switch. E.g. Use a transistor to light LED. The transistor is turned "on" or "off" by the signal from the MCU, but the current passing through the LED from the power supply does not go through the MCU. The idea is similar when using electrical relay switches. You can use multiple GPIO pins to control your home windows shutter with the help of electrical relays. 

~~~
<center><img src="/part_i/lecture5_media/GPIOExampleLEDSwitch.svg" style="max-width:425px"></center>~~~


## Pull-down and Pull-Up Resistors
To ensure deterministic binary logic, a pull up or pull down resistor is used. The resistor guarantees the logic is inverted when the source is not connected, and that the value is not “floating”.

Consider the switch above connected to PA0. When the switch is not pressed, the path of least resistance is through the resistor R2 guaranteeing that the signal will be connected to ground (Logic Low, or 0) and when the switch is pressed, the path of least resistance is through the switch and not the resistor R2 and the signal is then guaranteed to equal $V_s$ (Logic High, or 1). This resistor is called a pull-down resistor, it "pulls" the signal down to ground making it normally low. 

Positive Logic: Pin normally connected to ground through pull-down resistor, so pin reads low. When source is connected, pin reads high.

Negative Logic: Pin normally connected to source through pull-up resistor, connecting to ground sets pin low.

Weak:- high resistance (weak current drain)

~~~
<center><img src="/part_i/lecture5_media/PullResistors.svg" style="max-width:525px"></center>~~~

## Microcontroller Registers - An Overview

Program code interacts with hardware through changing bits inside registers. A register is a memory location inside the microcontroller. 
Interface with the outside world on a microcontroller is done through registers, whether reading or writing to them. Registers can be Read-Only, or Read-Write.
The STM32F401RE is a 32bit microcontroller, and so each register is technically composed of 32 bit-fields. But not all registers use the full 32-bit space. 

A typical register address looks like
				**0x4002 0000**

The above happens to be the base address for GPIO Port A. Reading a datasheet, you will find that GPIO registers are listed by their offset from some base address.

## Example Register

Each GPIO peripheral (port) has a similar set of registers. Here is one common register to every GPIO port, the **GPIO Mode Register**. It is used to set the mode of each pin. Note that two bits are required here to set the mode of the pin belonging to that register. 
~~~
<center><img src="/part_i/lecture5_media/Register_GPIOMODER.svg" style="max-width:785px"></center>~~~

> Example: we write 01 in bits [11:10] if we want to set Pin 5 as an output pin. This is basically what the Arduino function: **pinMode(PA5, OUTPUT);** does

## Register: Addressing

On STM32 MCUs, a base address is given for a peripheral and then the list offsets from that address for each register. 
Given GPIO Port A base address: 0x4002 0000. The GPIOs mode registers (GPIOx\_MODER) address offset is 0x00, and the output data register (GPIOx\_ODR) address offset is 0x14
Then:
GPIO mode register address for Port A (GPIOA\_MODER) is then:

**0x4002 0000    (= 0x4002 0000 + 0x00)**

GPIO output type register address for Port A (GPIOA\_ODR) is then

**0x4002 0014    (= 0x4002 0000 + 0x14)**

If the base address of GPIO Port B is: 0x40020400, 
What is the GPIOB\_ODR address?

## Blinky Example on STM32Nucleo

To execute a basic blinky routine without using any library, and by direct accesss to registers, we need to do the following on STM32F401RE. The LED is connected to PA5: Port A Pin 5
1. Enable the GPIO Port A clock, in effect turning on the GPIO Port (See RCC Register)
2. Set the GPIO Port A Pin 5 as output (See GPIOA_MODER Register)
3. Set the GPIO Port A Pin 5 output to 1 (High) to turn LED On, or set it to 0 (Low) to switch it off
4. Have some delay routine in between the Ons and Offs
Let’s see the relevant registers and see how we can execute a blinky code.
The concepts learned will extend to advanced peripherals.

### RCC Register

RCC which stands Reset and Clock Control with a base address: 0x4002 3800. This register is specific to peripherals, and it needs to be configured in order to enable (turn on) the GPIO port. By default, peripherals are switched off (clock source to peripheral disabled). We can turn each peripheral clock on/off separately. 

Specifically, the RCC_AHB1 peripheral clock enable register is where GPIO Port A is enabled. 
~~~
<center><img src="/part_i/lecture5_media/Register_RCCABHR.svg" style="max-width:785px"></center>~~~

### GPIO Mode Register
Through the GPIO Mode register we set individual pins either as: Input, Output, Analog or Alternate Function (AF, e.g. UART, USB, PWM, TIM, etc)

~~~
<center><img src="/part_i/lecture5_media/Register_GPIOMODER.svg" style="max-width:785px"></center>~~~

### GPIO ODR Register

ODR, which stands for Output Data Register. This register is manipulated in order to set pins high or low, in effect turning the LED on and off. Note that all the pins of a specific GPIO port are set through the 16-bits of the GPIO port's ODR register. For example the ODR register for GPIO port A is referred to as GPIO**A**\_ODR and it has an address 

**0x4002 0014    (= 0x4002 0000 + 0x14)**
~~~
<center><img src="/part_i/lecture5_media/Register_GPIOODR.svg" style="max-width:785px"></center>~~~

### GPIO IDR Register
There are other registers for manipulating GPIO, which you can review on the Reference Manual ([REF02](/assets/reference_docs/REF02_STM32F401xBC_and_STM32F401xDE_Reference_Manual.pdf))
Here, GPIO_IDR is the GPIO Input Data Register for example, which is where you would read the state of an *input* pin. 

~~~
<center><img src="/part_i/lecture5_media/Register_GPIOIDR.svg" style="max-width:785px"></center>~~~

### GPIO Registers
Here is a summary of the GPIO registers available on STM32F401RE
- GPIOx_MODER
  - Mode Register (Input, Output, AF, Analog)
- GPIOx_OTYPER
  - Output Type (Push-pull or Open-drain)
- GPIOx_OSPEEDR
  - Output Speed (Low, Medium, High, Very High Speed)
- GPIOx_PUPDR
  - Pull-up/Pull-down Register
- GPIOx_IDR
  - Input Data Register
- GPIOx_ODR
  - Output Data Register
- GPIOx_BSRR
  - Bit Set / Reset
- GPIOx_LCKR
  - Port Configuration Lock
- GPIOx_AFRL
  - Alternate Function Low Register
- GPIOx_AFRH
  - Alternate Function High Register


## Headerless Blinky Example on STM32Nucleo
In C, this is the code to perform a blinky routine. Program Size: 220 Bytes

```cpp
/* Look Ma!, no headers */
#define GPIOARCCR (*(volatile int *)(0x40023800 + 0x30))
#define GPIOAMODER (*(volatile int *)0x40020000)
#define GPIOAODR (*(volatile int *)(0x40020000 + 0x14))

int main(void) {
    /* Enable GPIOA Clock */
    GPIOARCCR |= 1; /* Ref RCC_AHB2ENR register */
    /* Set Port A Pin 5 as Output */ 
    GPIOAMODER |= (1 << 10); /* Ref GPIOx_MODER register */
    while (1) {
        /* Set LED Pin High */
        GPIOAODR |= (1 << 5); /* Ref GPIOx_ODR register*/
        /* Dumb Delay: wait x number of clock cycles */
        for (int k = 0; k<1000000; k++){__asm("nop");}
        /* Set LED Pin Low */
        GPIOAODR &= ~(1 << 5); /* Ref GPIOx_ODR register*/
        /* Dumb Delay */
        for (int k = 0; k<1000000; k++){__asm("nop");}
    }
}
```

>This is the lowest level programming in C, any lower and you will have to program in assembly. Not portable to other MCUs in the same family 

## Register Address Addressing

What is this gibberish? `#define GPIOAODR (*(volatile int *)(0x40020000 + 0x14))` ?

This is creating a macro: GPIOAODR to access the GPIO Port A Output Data R
The address itself is 0x40020014, but in C/C++ this is just a number, so we need to tell the compiler that we want to represent and access the value **in** that **address**, so, in order to do that we have to: 

1. Cast the hex number to 32bit pointer, now we have a pointer (address only)
   - `#define GPIOAODR (int *)(0x40020000 + 0x14)`
2. Make it volatile, to tell compiler that its value might change by hardware, so don't optimize. 
   - `#define GPIOAODR (volatile int *)(0x40020000 + 0x14)`
3. Then dereference it using *, to act on the value stored **IN** the address
   - `#define GPIOAODR (*(volatile int *)(0x40020000 + 0x14))`

## Blinky Example on STM32Nucleo with stm32f401xe definitions
Supplied with the microcontroller is a header that has macro definitions for all the different registers and bitmasks for our specific microcontroller. This header doesn't add functions but only handy macros in order not to have to read the reference and manually find what the address location is, but instead, just use the macro definitions. Use expressive words instead of numbers. 

The exact same code as before, but we use the provided macro definitions for the addresses, address shifts and bitmasks (exactly similar binary as before). Note that we use the `stm32f401xe.h` header file.

```cpp
#include "stm32f401xe.h"

int main(void) {
    /* Enable GPIOA Clock */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN; /* Ref RCC_AHB2ENR register */
    /* Set Port A Pin 5 as Output */
    GPIOA->MODER |= (1 << GPIO_MODER_MODE0_Pos); /* Ref GPIOx_MODER register */
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
>Still Low-Level C but with the help of macro definitions (at no extra memory overhead charge)

### Blinky Example on STM32Nucleo with STM32Cube HAL
ST provides an abstraction for their MCUs called STM32Cube, this is a blinky routine using their abstraction. Program Size: 404 Bytes

The STM32Cube is a C library that has many functions defined for setting and interacting with the MCU. 

```cpp
#include "stm32f4xx_hal.h" /* We don't include the specific stm32f401xe header, but just the HAL */
#include "stm32f4xx.h"
#define LED_GPIO_CLK_ENABLE()                  __HAL_RCC_GPIOA_CLK_ENABLE()

int main(void){
  HAL_Init(); /* Initialize the HAL Drivers */
  
  LED_GPIO_CLK_ENABLE(); /* Enable GPIO A Clock */
  GPIO_InitTypeDef GPIO_InitStruct; 
  GPIO_InitStruct.Pin = GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct); /* The pin configuration is done through a function */

  while (1)
  {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5); /* HAL provides a toggle pin function */
    HAL_Delay(1000); /* As well as a delay function (milliseconds) */
  }
}
```
>Higher Lower Level C Code, this is the recommended level for commercial/professional programming of MCU. Portable across other STM32 MCUs


### Blinky Example on STM32Nucleo with Arduino

And this is the blinky code using the Arduino framework

Program Size: 12404 Bytes. Abstraction comes at a cost!
```cpp
#include <Arduino.h>

void setup() { pinMode(LED_BUILTIN, OUTPUT); }

void loop() {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(200);
}
```
>A good level of abstraction. Good for education / hobbyist / prototyping / quick lab instruments. Portable across all MCUs that have  an Arduino adoption

## Other available frameworks
- CMSIS: Cortex Microcontroller Software Interface Standard
  - Developed by ARM
  - Universal across other ARM Cortex MCU, not just ST
- SPL: Standard Peripheral Library
  - Developed by ST for ST based ARM MCUs
- HAL ST: Hardware Abstraction Layer ST
  - Developed by ST for ST based ARM MCUs, with focus on abstraction
- Arduino
  - Developed for hobbyists and prototypists
  - Become so popular, that manufacturers provide support for it 

## Standard Peripheral Library /  STM32Cube
Modern microcontrollers pack a lot of features and peripherals. Configuring peripherals through direct register access becomes cumbersome for a programmer. Using manufacturers provided standard libraries “framework” is becoming standard practice. Libraries abstract away differences between microcontrollers so code can be more portable. If you run out of stock on an STM32F4x board, you can move to an STM32F7 board much faster with the HAL than if you used the standard peripheral library or even harder if you only used the board defintions header file. 

HAL: Hardware Abstraction Layer
Libraries are practically more proof tested with fewer bugs

## How to know what to do and where to find information?
Configuring and programming an MCU is not a straight-forward or linear process. It comes with experience, but it's a rewarding experience. There are multiple references and tools that must be used concurrently
With STM32Nucleo for example, we use:
- [Datasheet](/assets/reference_docs/REF01_STM32F401RE_DATASHEET.pdf), which gives the "specs"
- [Reference Manual](/assets/reference_docs/REF02_STM32F401xBC_and_STM32F401xDE_Reference_Manual_Table38_Vector_Table.pdf) , A guide on how to configure and use the MCU
  - Registers Information
  - Possible Configurations
  - Used by developers

- [User Manual for STM32 Nucleo](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
- Framework User Manual (e.g. [HAL and LL User Manual](/assets/reference_docs/REF05_Description_of_STM32F4_HAL_and_LL_drivers.pdf))
- Example Code for framework selected
- Consult developer community

Next: [Part I L6 - Timers](../lecture6/)  