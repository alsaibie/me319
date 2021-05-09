@def title = "Part I L6 - Interrupts"
@def hascode = true

# Part I L6 - Interrupts
## Lecture Video
Part A
~~~
<iframe src="https://player.vimeo.com/video/543112104" width="780" height="438" frameborder="0" allowfullscreen></iframe>
~~~

[Lecture Handout](/part_i/ME319_-_Mechatronics_-_Part_I_Lecture_7_Interrupts.pdf)

Next: [Part I L8 - Communications](../lecture8/)  

## Objectives
- Introduce the concepts of interrupts
- Overview some of different ways interrupts are used on a microcontroller 

## Why interrupts?
The main purpose of microcontroller devices is to respond to external stimuli and control external components. But how do we program the device to monitor and/or respond to external stimulus? How does it know that an external event has occured?
What if, for example we wanted to:
- Run a motor every time someone presses a button
- Sound an alarm if an emergency button is pressed
- Rotate a stepper motor until a limit switch activates
- Each time a GPS signal is received, log data to flash memory

## Polling vs Interrupts
### Polling
One mechanism to do this is called polling or busy-wait synchronization. The idea is that you continuously check a variable in a loop to see if has changed. Then combine that action with an if-statement to perform something depending on the variable value. 

For example, loop and continuously check if user presses button, if the button is pressed, then perform is certain action, you can choose to wait as well for when the user releases the button by also continuously checking for the variable indicating the button is released. 

### Drawbacks of polling
There are several drawbacks to polling. The software is tied up checking a certain address and cannot do other tasks (inefficient computation). And if we are waiting on multiple possible events, it becomes cumbersome to establish priority between those checks (you can use a scheduler or rtos system there). If the mcu is only waiting for long periods for an event, this is an extremely inefficient use of power (inefficient power consumption). Ideally, we would like to be able to put the microcontroller in low power mode while waiting

~~~
<center><img src="/part_i/lecture7_media/PollingLoop.svg" style="max-width:725px"></center>~~~

### Interrupts
Interrupts are a way for software, processor, peripheral to flag or notify each other. They are a critical and powerful feature of processors.

> Interrupts enable high level of real-time control

An interrupt, as the name suggests, interrupts the processor. The processor would have to respond and service this interrupt. Peripherals can use this interruption feature to indicate key status. Peripherals **can** be set to be polled by the program, but they can also be configured to issue interrupts to the processor. 

An interrupt is an asynchronous switch in the processor execution. 

>Asynchronous means that it occurs on demand, not with some specific timing (like polling)


~~~
<br><br>
<center><img src="/part_i/lecture7_media/InterruptLoopA.svg" style="max-width:780px"></center>~~~

~~~
<br><br>
<center><img src="/part_i/lecture7_media/InterruptLoop_B.svg" style="max-width:780px"></center>~~~


### GPIO Switch

Here is an example where the GPIO is configured such that the pin where the user button is connected to issues an interrupt when the button is pressed. When this interrupt is issued, the callback function `switch_callback()` is called. 

>Callback is a term used to only describe a function behavior. A function that is meant to be executed as a response to an event. There isn't anything special its syntax. It's just a function.

```cpp
/* Example: Interrupt Based LED Switch (Soft-Latching) 
*  Using the arduino API, it's very convenient to setup an external event interrupt
*/
#include <Arduino.h>
/* Callback function for whenever the User Button is pressed */
void switch_callback(void) { digitalToggle(LED_BUILTIN); }

void setup() {
    pinMode(USER_BTN, INPUT);
    pinMode(LED_BUILTIN, OUTPUT);
    /* attach the Low/Falling event (Negative logic on Nucleo Button) 
     * to a callback function. 
     * */
    attachInterrupt(USER_BTN, switch_callback, LOW);
}
void loop() {/* Nothing else to be done */}
```

### ADC Example
~~~
<br><br>
<center><img src="/part_i/lecture7_media/ADC_Interrupt_Loop.svg" style="max-width:780px"></center>~~~  
## Interrupts on peripherals
Most hardware features on the MCU can generate interrupts and can have an associated ISR, including:
- Analog-to-digital converter
- Flash memory controller
- Timers
- UARTs
- GPIO ports
- I2C
- Serial Peripheral Interface

Basically, any peripheral that would benefit from flagging the CPU on specific events, likely has an interrupt issuing capability. 

## Configuring interrupts
By default, if you do not explicitly enable an interrupt, code executes serially, and no interrupts will occur. Except for system level interrupts (faults, power loss, stack overflow, etc), those are hardcoded in the microcontroller and usually have the highest of the highest priority over other interrupts. 

>The microcontroller may be able to issue an interrupt in the case of low voltage supply to it. A mission critical mechatronic system would benefit from this, as a programmer, you can call some safeguard routines at this instant. 

Setting up an interrupt and defining appropriate ISR to run when a nonsystem level interrupt occurs is your responsibility as a programmer of the MCU. 

Deciding when to use interrupts, and when to use polling, is your choice as software developer. 

As a general guide, use polling when I/O structure is simple and fixed. And use interrupts when I/O timing is variable and/or structure is complex.

## Interrupts Priority
Potentially, your code may have several interrupts enabled at one time. 

For example, you may have one interrupt for ADC conversion and one interrupt for edge-triggered GPIO pin. What happens if both events happen at same time?  While a third ISR (interrupt service routine, a.k.a callback function) is being executed (a.k.a the interrupt being **serviced**).

Or, if GPIO event happens when ADC ISR is executing? This is why you must define interrupt priority when enabling an interrupt


>Servicing the interrupt is a term used in the embedded world. Usually, the way the interrupt works is that it sets a flag (sets a bit) in some register and tells the processor that some interrupt occurs. The processor would jump to a position in a table where all interrupts are listed, called interrupt vector table, and if you've configured a specific callback function (ISR routine), the processor will go to that function, it would go to a generic default function. And before returning to the main function, you have to clear that flag (clears the bit) in the interrupts register. The whole process is called Servicing the Interrupt. If using the Arduino API or STM32Cube, some of the servicing work is carried by the APIs. 

### Priority Rules
- If an ISR of higher priority is running and lower priority interrupt is triggered, ISR of lower priority will wait for the higher priority ISR to finish, then start afterwards.
- If an ISR of lower priority is running and higher priority interrupt is triggered, ISR of higher priority takes over, runs to completion, and returns execution to lower priority ISR

- ISR is akin to an interrupt callback function. The reason it is called an “interrupt service routine” is that once it is executed the interrupt flag is cleared: it has been serviced, and then it lives happily ever after, until it is flagged again that is. 

## Interrupts on STM32F401x
The subsystem on ARM microprocessor that handles interrupts is called Nested Vectored Interrupt Controllers (NVIC) 
Quoted from the datasheet
```
STM32F401x devices embed a nested vectored interrupt controller able to 
- manage 16 priority levels, and 
- handle up to 62 maskable interrupt channels 
- plus the 16 interrupt lines of the Cortex®-M4 with FPU.

• Closely coupled NVIC gives low-latency interrupt processing
• Interrupt entry vector table address passed directly to the core
• Allows early processing of interrupts
• Processing of late arriving, higher-priority interrupts
• Support tail chaining
• Processor state automatically saved
• Interrupt entry restored on interrupt exit with no instruction overhead

This hardware block provides flexible interrupt management features with minimum interrupt latency.
```

## Disabling Interrupts
Sometimes you really do not want main code to pause execution. For instance, if you are doing some sort of critical task such as sending a control input to a mechanism. Or sending a serial packet via UART, or initializing port configurations. You don't want to pause in the middle of those small task chunks once they started. So you can over a small code section disable all interrupts and enable the interrupts again when finished. 


## Processor Interrupt-Based Threading
Single core CPUs can only do one instruction at a time. One way to parallelize the program is through the use of scheduled (periodic) and event-based interrupts, with different priority levels.

Higher priority ISRs can pause lower priority ISRs. Except for Non-Maskable interrupts (usually reserved for hardware errors).
~~~
<br><br>
<center><img src="/part_i/lecture7_media/ProcessorThread.svg" style="max-width:780px"></center>~~~  

## Interrupts on Timer Peripheral
The Timer (TIM) peripheral covered previously can generate several types of interrupts, including:

- Overflow Interrupt: Every time the counter completes one lap (period completed). 
    - This is the interrupt used to issue a periodic callback function
- Input Capture Interrupt: Every time an edge is detected from an input.
  - This can be used to measure input signal frequency.
- Output Compare Interrupt: Every time the compare value is reached.
