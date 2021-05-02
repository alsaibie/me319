@def title = "Prelab 4 - Introduction to Timers"
@def hascode = true

# Prelab 4: Introduction to Timers

**Please review Part I Lecture 6 TIM before attempting this prelab.**
~~~
<iframe src="https://player.vimeo.com/video/544201407" width="640" height="360" frameborder="0" allowfullscreen></iframe>
~~~

In this prelab, we will become familiar with utilizing the timers on the microcontroller for: 
1. Periodic function calls
2. Generating a signal and 
3. Reading a signal frequency.

Create a PlatformIO project for Nucleo STM32F401RE with the Arduino framework. Name it Prelab4, preferably.

Remember to add the `src_filter` instruction in the platform.ini file as shown.
```
[env:nucleo_f401re]
platform = ststm32
board = nucleo_f401re
framework = arduino
src_filter = -<main*.cpp> +<mainE1.cpp>
```
We will not be doing most of the low-level configuration of the timers. We will instead, use the stm32duino (Arduino for stm32), which provides a nice abstraction for setting up the timers.

You can find the template code for the prelab here. 
## Example 1: Using timers to generate a periodic function call

In Example 1 (`mainE1.cpp`), you will find a program for using Timer 1 to control a function call.

`mainE1.cpp`
```cpp
#include <Arduino.h>
#include <HardwareTimer.h> 
/*
 *  Example 1: Use a Timer to call a function (interrupt callback) at a specific
 *  rate
 */

/* Timer Interrupt Callback Function
 Automatically Called on TIM OVerflow */
void Update_IT_callback() {
    /* Toggle LED */
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}
 

void setup() {
    pinMode(LED_BUILTIN, OUTPUT);

    /* We create a new Timer Object Pointer */
    HardwareTimer *Timer1 = new HardwareTimer(TIM1);

    Timer1->setOverflow(2, HERTZ_FORMAT);
    
    /* We specify the function we want executed when Timer 1 interrupt occurs
    On other words, what function is called everytime Timer 1 overflows */
    Timer1->attachInterrupt(Update_IT_callback);

    Timer1->resume(); /* Start/Resume Timer 1 */
}

void loop() {
    /* Nothing to do here. The Timer HARDWARE, will take care of calling
       the right function periodically */
}
```
The timer is configured to rollover at a specific rate. This is controlled by both the number of counts (period) and the count rate.

Whenever the rollover (overflow) occurs, an interrupt is issued. We tie a function we call a **callback** function to this interrupt, so that whenever this interrupt occurs the function is called automatically.

In other words, by controlling the timer period and count rate, we control the frequency at which the callback function is executed.

Normally, you would have to setup the timer count rate (prescaler value) and autoload value (overflow, or period) separately. The stm32duino **HardwareTimer** library provides a function call to do both: `setOverflow()`, where if you provide the overflow rate in Hertz or milliseconds format, it will set both: the timer period (autoload value) and count rate (prescaler).

The reason it is called a prescaler is that it takes the timer clock frequency, which could be the CPU clock frequency and scales it down by a factor termed **prescaler**.

With the function `attachInterrupt(callback_function_name)`, we pass the callback function.

The callback function simply toggles the LED. So by controlling the rate at which the callback function is called, we control the LED blinking frequency.

Flash example 1 and observe the LED blinking frequency. Try to change the blinking frequency.

## Example 2: Using timers to generate a signal

In Example 2 (`mainE2.cpp`), we use a timer to generate a square wave signal.

`mainE2.cpp`
```cpp
#include <Arduino.h>
#include <HardwareTimer.h>
/*
 *  Example 2: Use a Timer to generate a PWM Signal
 *  Ouput the PWM to drive LED
 *  LED Pin is PA5 - On TIM2 Channel 1
 */

void setup() {
        pinMode(PA5, OUTPUT);
        uint32_t pwmChannel = TIM_CHANNEL_1 + 1 ; /* arduino channel idx starts from 1, not 0 */
        /* We create a new Timer Object */
        HardwareTimer *TimerPWM = new HardwareTimer(TIM2);

        /* Configure the timer mode to output compare pwm */
        TimerPWM->setMode(pwmChannel, TIMER_OUTPUT_COMPARE_PWM1, PA5);
        /* Set the overflow: the signal frequency/time period */
        
        TimerPWM->setOverflow(200E3, MICROSEC_FORMAT); /* 1E3microsec = 1ms */
        /* Set duty cycle */

        TimerPWM->setCaptureCompare(pwmChannel, (0xFFFF>>1), /* Right shift halves the number */
                                    RESOLUTION_16B_COMPARE_FORMAT); /* 50% Duty Cycle */
        TimerPWM->resume(); /* Start/Resume Timer 1 */
    
    /* The Timer HARDWARE will generate the PWM signal to
     * control the LED. CPU can sleep, no callback function required as well. */
}

void loop() {
    /* Nothing to do here.  */
}
```
The timer overflow rate controls the output signal frequency, while the compare value controls the duty cycle. For a square wave signal, the duty cycle is 50%, so the compare value is always half the autoload value for a square wave signal.

In addition to setting up the timer overflow (autoload value), and since we are controlling an output pin. We need to configure the proper pin as a timer channel pin. **PA5**, which controls the built-in LED, happens to be a pin that can have an alternate function as timer channel pin, specifically **Timer 2 Channel 1.** We can generate a square wave signal to blink the LED using timers.

Again, the Arduino framework does most of the work of configuring the pin for us. Once we call setMode() and give it the channel number, timer mode and pin name it will perform the GPIO AF configuration.

Note that the hardware peripheral generates the signal. There is absolutely no CPU overhead consumed in toggling the signal after the peripheral has been configured.

Flash Example 2 and observe the LED blinking frequency. Try to change the blinking frequency.

## Example 3: Using timers to read a signal frequency

In Example 3 (`mainE3.cpp`) we combine Examples 1 and 2 and add an input capture routine to measure a square wave signal frequency.

`mainE3.cpp`
```cpp
#include <Arduino.h>
#include <HardwareTimer.h>
/*
 *  Example 3: Use a Timer to measure the the frequency of a square wave signal
 *  The frequency measurement will be published every 1s
 *  PWM Signal generated on pin PA0, which should be connected to pin PA3
 */

/* On TIM2 Ch1 - same as LED Pin (LED will be controlled too) */
#define PWM_Output_Pin PA5
#define PWM_Input_Pin PA6 /* On TIM3 Ch1, Output pin must be on different timer than input pin */

volatile uint32_t LastPeriodCapture = 0, CurrentCapture;
uint32_t input_count_freq = 0;
volatile float FrequencyMeasured;
volatile uint32_t rolloverCompareCount = 0;
HardwareTimer *TimerIC;
uint32_t pwmInChannel;

/* Timer Interrupt Callback Function
 Automatically Called on Periodic Timer OVerflow */
void Periodic_IT_callback() {
    Serial.println((String) "PWM Measured Frequency = " + FrequencyMeasured +
                   "Hz");
}

/* When a rising edge is detected, this function is called */
void TIMINPUT_Capture_Rising_IT_callback() {
    CurrentCapture = TimerIC->getCaptureCompare(pwmInChannel);
    /* frequency computation */
    if (CurrentCapture > LastPeriodCapture && rolloverCompareCount == 0) {
        /* f_signal = f_count / number_of_counts */
        FrequencyMeasured =
            (float)input_count_freq / (CurrentCapture - LastPeriodCapture);
    } else if (rolloverCompareCount > 0) {
        /* There is an overflow, need to offset capture value by 0xFFFF, the
         * overflow value */
        FrequencyMeasured =
            (float)input_count_freq / (0xFFFF * rolloverCompareCount +
                                CurrentCapture - LastPeriodCapture);
    }

    LastPeriodCapture = CurrentCapture;
    rolloverCompareCount = 0;
}

/* Keep count of # of rollovers to consider in frequency calculation */
void Rollover_IT_callback() { rolloverCompareCount++; }

void setup() {
    Serial.begin(9600);

    /* We create 3 timers: General (Periodic), Output Compare (PWM), Input
     * Capture (Frequency Measure) */

    /* Create and Configure Periodic Timer to Serial Print at a low rate */
    HardwareTimer *TimerPeriodic = new HardwareTimer(TIM1);
    TimerPeriodic->setOverflow(1, HERTZ_FORMAT);
    TimerPeriodic->attachInterrupt(Periodic_IT_callback);
    TimerPeriodic->resume(); /* Start Timer */

    /*
     * Create and Configure Output Compare (PWM)
     * */
    HardwareTimer *TimerPWM = new HardwareTimer(TIM2);
    uint32_t pwmOutChannel = TIM_CHANNEL_1 + 1;
    TimerPWM->setMode(pwmOutChannel, TIMER_OUTPUT_COMPARE_PWM1, PWM_Output_Pin);
    TimerPWM->setOverflow(10, HERTZ_FORMAT); /* Hertz */
    TimerPWM->setCaptureCompare(pwmOutChannel, 50,
                                PERCENT_COMPARE_FORMAT); /* 50% Duty Cycle */
    TimerPWM->resume();

    /*
     * Create and Configure Input Capture (Frequency Measure)
     * */
    TimerIC = new HardwareTimer(TIM3);
    pwmInChannel = TIM_CHANNEL_1 + 1;
    TimerIC->setMode(pwmInChannel, TIMER_INPUT_FREQ_DUTY_MEASUREMENT,
                     PWM_Input_Pin);
    uint32_t PrescalerFactor = 100;
    TimerIC->setPrescaleFactor(PrescalerFactor);
    TimerIC->setOverflow(0xFFFF);  /* Max Period value to have the largest
                                    * possible time to detect rising edge and
                                    * avoid timer rollover */
    /* the attachInterrupt function has two methods: one for counter overflow,
     * one for input detect */
    TimerIC->attachInterrupt(pwmInChannel, TIMINPUT_Capture_Rising_IT_callback);
    TimerIC->attachInterrupt(Rollover_IT_callback);
    TimerIC->resume();

    /* Compute f_count for the Input Compare Timer, only once */
    input_count_freq =
        TimerIC->getTimerClkFreq() / TimerIC->getPrescaleFactor();
}

void loop() { 
    /* Nothing to do here. 
     * We could have placed the Serial Print routine here instead of a periodic timer 
     */
}
```
Here we use three timers. TIM1 is configured to execute a periodic function that will send the latest frequency measurement to the PC via serial. The configuration is similar to that of Example 1 . TIM2 is used to generate a square wave signal, just like Example 2. And TIM3, which is added in this example, is configured to measure the square wave signal we generate.

Before trying out this example. Make sure to connect pin PA5 (Output) to pin PA6 (Input) via a jumper cable.

~~~
<center><img src="/prelabs/pl4assets/image1.png" style="max-width:720px"></center>~~~ 

If we have the count frequency of a timer, and we keep track of the timer counter values at each rising edge of the signal, we can convert this into a signal frequency measurement. The timer automatically saves the counter value of its running timer whenever an edge is detected, then issues an interrupt to the CPU to come and grab this saved value.

In the figure below, the timer captures one rising edge when the counter is at 0x55 and the next rising edge at 0xA1. So, `0x4C` ($76_{10}$) timer counts is the length of the input signal. By using the timer count frequency, we can calculate the signal frequency.

$$f_{\text{square wave signal}} = \frac{f_{\text{timer count}}}{CounterValue@RisingEdge - CounterValue@PreviousRisingEdge}$$

~~~
<br>
<center><img src="/prelabs/pl4assets/image2.png" style="max-width:720px"></center>~~~ 

Input Capture works by first configuring the period (overflow / autoload value) and count rate (prescaler). Usually, we set the overflow to the maximum value possible. In the case of the 16-bit TIM3, the largest count value is 0xFFFF. This is to minimize the number of overflows. The count rate (prescaler) determines the measurement resolution. A high count rate means the frequency measurement has a high resolution, but at the expense of more frequency overflows.

The issue with the overflow when measuring frequency, is that the 2^nd consecutive count can occur after an overflow, meaning the second count value will either be lower than the first counter value or higher by passing completely full circle or more. This occurs more often when the count frequency is high and/or the input signal frequency is low. This issue can be easily resolved by keeping track of the number of overflows that occurred between two edge detection events, then performing some math to calculate the actual number of counts between two edge detection events.

The figure below shows an example of when an overflow occurs during consecutive edge detections. The actual number of counts between two rising edges is (`0xFF -- 0xFD -- 0x02`), assuming `0xFF` is the overflow value here.

There are two callback functions we tie to TIM3 interrupt, one is for retrieving the captured edge event counter value and performing the frequency calculation and the 2^nd^ callback function is called when an overflow occurs, and in it we increment the overflow counter. We reset the overflow counter after we account for the overflow in the frequency calculation.

Flash example 3, then open a serial terminal to observe the calculated frequency measurement. Then try changing the square wave frequency and observe the result.

Note again that there is no code inside `loop()` The timers hardware is doing the heavy lifting and only two callback functions are called only in response to events.
~~~
<center><img src="/prelabs/pl4assets/image3.png" style="max-width:720px"></center>~~~ 
