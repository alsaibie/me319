@def title = "Prelab 9 Realtime Motor Control"
@def hascode = true

# Prelab 9: Realtime Motor Control

In this lab we will learn how to implement a feedback controller, in order to perform both speed and position control on a conventional brushed DC motor. 
We will apply what we learned about timers in lab 4 to implement a feedback control structure.

## Tools Required 
1. STM32 Nucleo F401RE Board 
2. USB Type A to USB Mini-B Connector
3. X-Nucleo-IKS01A2
4. X-Nucleo-IHM04A1 

## References
1. [REFC1 XNUCLEO IHM04A1 Quick Start Guide](/assets/reference_docs/REFC1_XNUCLEO_IHM04A1_Quick_Start_Guide.pdf)
2. [REFC2 XNUCLEO IHM04A1 mbed pinout v1](/assets/reference_docs/REFC2_XNUCLEO_IHM04A1_mbed_pinout_v1.jpg)
3. [REFC3 XNUCLEO IHM04A1 Databrief](/assets/reference_docs/REF03_STM32_Nucleo-64_boards_User_Manual.pdf)
4. [REFC4 L6206 DMOS DUAL FULLBRIDGE DRIVER](/assets/reference_docs/REFC4_L6206_DMOS_DUAL_FULLBRIDGE_DRIVER.pdf)
5. [REFC5 MAGNETIC ENCODER](/assets/reference_docs/REFC5_MAGNETIC_ENCODER.pdf)
6. [REFC6A Motor Specifications 290-006\_ig220019x00015r\_ds](/assets/reference_docs/REFC6A_Motor_Specifications_290-006_ig220019x00015r_ds.pdf)
7. [REFC6B Motor Specifications_290-008\_ig220053x00085r\_ds](/assets/reference_docs/REFC6B_Motor_Specifications_290-008_ig220053x00085r_ds.pdf)
8. Lab Report Submission Guidelines

~~~
<center><img src="/prelabs/pl9assets/motor.gif" style="max-width:420px"></center>~~~

## Conventional DC Motor
A DC motor is a commonly used actuator in numerous systems. A Brushed DC motor, which we will be using in this lab, consists of a housing, bearings on which the output shaft is supported, stator (non-rotating part) that encompass the magnets and then the rotor which combines the drive shaft, the coils that current flows through and generate an Electromagnetic Force, the commutator that sends the current to the armature and brushes that force current through the coils.

## Motor Driver
A common and universally used brushed DC motor driving circuit is known as an H-Bridge circuit. The circuit allows for routing the current from the power supply through the motor by way of operating four transistors resembling the letter H. A motor driver normally encompasses the H-Bridge circuit along with power and driving logic. As shown on the following figure.

~~~
<center><img src="/prelabs/pl9assets/motordriver.png" style="max-width:780px"></center>~~~

In the figure, OUT1 and OUT2 are connected to the motor terminals. IN1 and IN2 are inputs from the microcontroller. The A and B denote two Full H-Bridge drivers on the chip, capable of driving two bidirectional brushed DC motors. The transistors used in the H-Bridge circuit are N-Channel Power MOSFETs (NFETs). EN is a driver enable input, this pin must be set to HIGH in order to enable output to the motor.
The gate logic of the motor driver chip switches the NFET pairs according to the inputs IN1 and IN2. If IN1 is high and IN2 is low, OUT1 is connected to Vs and OUT2 is connected to GND. Vs is the motor supply voltage. If IN1 is driven by a PWM signal, the motor will be supplied with a voltage matching the frequency and duty cycle of the PWM signal. L6206 H-Bridge Truth Table shows the logic of the output pins based on the inputs. 


~~~
<center><img src="/prelabs/pl9assets/truthtable.png" style="max-width:780px"></center>~~~

## Quadrature Encoder

Also known as an optical sensor, an opto-interrupter is composed of an emitter, detector and a rotating disk with slots that allow light to go through. As the disk rotates, the light is blocked and unblocked from the detector as the slots come in and leave from in-between the emitter and detector. The disk can be attached to a motor shaft and by observing the opto-interrupter signal, the speed of the motor can be measured. This setup is also referred to as a motor encoder.

The rotary disks can have more than one slot, the more slots there are the higher the resolution in measuring speed and position. A quadrature encoder is one where the rotating part is composed of two offset slotted disks. The offset is normally 90o, this is also known as the phase lag. 

Each disk is considered a channel, and when the motor is rotating in one direction, one channel will lead the other by a quarter of a period and vice versa for the other direction. A quadrature encoder can be used not only to measure speed and position of the motor but also the direction of rotation, Figure Quadrature Encoder. 


~~~
<center><img src="/prelabs/pl9assets/QuadratureEncoder.svg" style="max-width:780px"></center><br>~~~

In this lab, we will be using a quadrature encoder to measure the position, speed and direction of the motor. 

## Timers
We know by now that a microcontroller requires a source of fixed frequency oscillation, a ticking source, in order to operate. Now imagine you have a register that stores the number of ticks the microcontroller observes. If you know the frequency of the ‘ticks’ and the count of the ticks, you then have a way of tracking elapsed time. In the bare minimum form, this is what a timer is: a register that keeps track of tick counts (time). 

Timers can trigger processor interrupts if a certain period of time has elapsed, either once or periodically. This can be used to trigger a periodic ISR, so we can have a function called specifically at a set and deterministic rate. Without having to deal with the uncertainty in the delay and length of execution in the main while loop. We will use this feature to trigger an ISR at a specific rate to perform the motor feedback control function. 

Timers can also be used to trigger an ISR if they detect a rising, falling edge or both for a connected input signal, and the timers can also save the time at which that event occurs. We will use this feature to detect the encoder pulses and measure the motor speed. 

Timers can also be used to change the state of an output pin after a certain period of time has elapsed, which we will use to generate a PWM signal to drive the motor.

## General Timer: Periodic Interrupt Service Routines

We can use a timer to periodically call a function (callback function or interrupt service routine) at a specific frequency. If set, the mcu will be “interrupted” from executing the instruction at hand and jump to execute this function call (service the interrupt), with some exceptions: if the instruction at hand is part of a non-maskable interrupt, meaning it cannot be interrupted, or part of an interrupt that holds a higher priority than the one interrupting. 
The while(1) loop inside the main() function is maskable and has the lowest priority, so it will always be interrupted by interrupts, if they are used. 

The timer can be configured to count at the same rate as the clock of the microcontroller, or at a scaled down rate. A timer is also given a period, and this can range from 1 up to the size of the timer count register. If the timer is 16-bit for example, the period can be up to 2^{16}-1 . The timer counts to the value of the period and then resets to 0 and starts again, or if the timer is set to count down, then it will start from the period value and count down to zero and then start again. 

A standard implementation would use this count overflow event (reaching the period value if in count-up mode or reaching 0 in count-down mode) to trigger an interrupt, and that interrupt will be used to call a function. 

As an example, let’s say we configure a timer to count at 1kHz, give it a period of 0xFF. Let’s configure it as a countdown timer. So it would count from 0xFF down to zero and then start from 0xFF again as shown on Figure 5 Countdown Timer Example. Every time it reaches zero it would issue a flag, which would then call a function. At what rate is this function called? What is the precision of this function call rate?

<!-- Function Call Rate =\frac{Timer_Frequency}{Timer_Period}=\frac{1kHz}{255}=3.92Hz

Precision =\frac{1}{Timer_Frequency}=\frac{1}{1000Hz}=\mp1ms\mp SystemClockPrecision -->

Note that the precision of the timer is also governed by the precision of the system clock (the osc clock source). 

## Output Compare: PWM Mode

Output compare refers to the use of timers to change the state of a digital output pin. The name may sound like a misnomer, it’s not the output that is compared, it’s the timer counter value that is compared to some set value and the output is set accordingly. Used to generate a PWM signal, the timer counter frequency and period can be set to produce a PWM signal with a specific frequency and resolution. The pulse or compare value is used to set the output to HIGH or LOW depending on the polarity of the PWM Timer configuration. 
For example, if we wish to generate a PWM signal with 10kHz frequency, 10-bit resolution, and 60% duty cycle, we would set it as follows:

<!-- Timer_Period=2^{10}-1

Timer_Frequency=PWM_Frequency\times Timer_Period=10000\times\left(2^{10}-1\right)=10.23MHz

Timer_Compare\thinsp\thinsp\left(Pulse\right)=\frac{60}{100}Timer_Period=613 -->

## Input Capture: Encoder Mode 

In input capture mode, the timer peripheral would be used to either capture the time (timer counter value) when an input signal has changed state, or the number of times the input signal has changed states. The timer can be configuring to track input signal changes from LOW to HIGH, this is called rising edge detection. Or configured to track input signal changes from HIGH to LOW, falling edge. It can also be used to detect both rising and falling edges. 

In the microcontroller used in this lab, there is a Quadrature Encoder Interface mode, as a special Input Capture mode, that can be used. When configured, a pair of input channels (for the two encoder channels) are tracked as well as their transition states to determine the direction of rotation. Depending on the direction of rotation, the counter would either count up, or count down. The timer counter register would store the number of times the encoder edges have been detected. 

If the encoder timer counter is read twice within a specific time interval, the motor speed can be calculated, given we account for the ratio of encoder lines per revolution and any gearboxes installed on the motor.
So, we can the timer can either be used to record the encoder counts, or can record when the encoder transition occurred. 

## Electrical Connections

For this lab we will be using the X-Nucleo-IHM04A1 Expansion board, which hosts the L6206 motor driver IC. The board stacks on top of the Nucleo F401RE microcontroller board using the Arduino connection headers. Connect the motor terminals (red and black wire) to Bridge A (A+ and A-) of the board, polarity doesn’t matter, as the motor will just spin in the opposite direction. Connect the 12V power supply to the Input of the IHM04A1 expansion board, but polarity matters here obviously. The expansion board already connects IN1A and IN2A to pins PB_4 and PB_5 of the microcontroller, respectively. 
To connect the encoder, connect the blue wire (ENC Channel A) to pin PA_B and purple wire (ENC Channel B) to pin PA_9. Connect the green wire to GND and the brown to +5V. 

~~~
<center><img src="/prelabs/pl9assets/IHM04A1pinout.jpg" style="max-width:680px"></center><br>~~~

The L6206 IC also offers motor current sensing, and the expansion board connects Bridge A’s current sensing output to pin PA\_6.

~~~
<center><img src="/prelabs/pl9assets/MotorDriverShieldWiring.jpg" style="max-width:680px"></center><br>~~~

## Feedback Control

A cascaded controller will be used to control the position of the motor, the inner loop is a PID speed feedback controller, also known as a rate controller, the outer loop is a proportional position controller. As shown on Figure 8 Cascaded Position and Speed Control Block Diagram 

~~~
<center><img src="/prelabs/pl9assets/bdiagram.png" style="max-width:780px"></center><br>~~~

## Motor Command
The outputs of the microcontroller to control the motor are two PWM signals, in addition to the enable signal. As explained in Section ‎5, one of the PWM pins should be set to LOW (0% duty cycle), and the other one given a PWM signal with a duty cycle proportional to the supply voltage desired. To rotate the motor in the opposite direction, the latter output is set LOW while the former is given the required duty cycle. 

