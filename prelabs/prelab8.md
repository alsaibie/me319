@def title = "Prelab 8"
@def hascode = true
# Prelab 8: Motor Dynamics and Control Simulation

In this prelab, we will model a Conventional DC Motor and simulate it with a PWM input. Then we will apply a discrete PID controller to control the velocity of the motor. A MATLAB Live Script is available [here](/prelabs/pl8assets/ME319_Prelab8_DC_Motor_Dynamics.mlx) to get you started. 

## Motor Model

A conventional DC Motor can be modeled as part electrical part mechanical, together termed as an electromechanical system. As shown in the following figure. 

\fig{/prelabs/pl8assets/Electromechanical_DCMotror_Diagram_S}
~~~<br>~~~

The motor can be modeled as a second order system with the transfer function, where input is voltage and output is angular velocity. 

$$
\dfrac{\Omega (s)}{E_a(s)} = \dfrac{K_T}{JLs^2+(JR+DL)s+(DR+K_TK_E)}
$$

where, 

$J$ is the motor load's inertia in $Kg\cdot m^2$

$D$ is the motor viscous friction constant in $N\cdot m \cdot s$

$K_E$ is the back EMF constant in $V/(rad \cdot s)$

$K_T$ is the motor torque constant in $N\cdot \frac{m}{A}$

$R$ is the electrical resistance of the motor in $Ohms$

$L$ is the electrical inductance of the motor in $H$

Let's simulate the response of the motor to a step input. The input here would be $E_a=1V$. A step voltage input is analogous to suddenly switching the motor on. 

\input{matlab}{/prelabs/pl8assets/snippet1.m}
Output:
\input{plaintext}{/prelabs/pl8assets/snippet1.out}
\fig{/prelabs/pl8assets/snippet1}

## PWM Signal as input
When using a microcontroller to regulate the voltage applied to a motor, it is likely that a PWM signal is used, the PWM signal will control a switching semiconductor or an H-Bridge motor driver circuit for instance. Let's look at the affect of changing the PWM signal frequency on the motor response to a step input. 

A function [`pwm`](/prelabs/pl8assets/pwm.m) is provided which returns an array of timed input values.

Here is the emulated PWM signal.

\input{matlab}{/prelabs/pl8assets/snippet2.m}
\fig{/prelabs/pl8assets/snippet2}

Let's simulate the response of the DC motor to a PWM signal with varying frequencies. 

\input{matlab}{/prelabs/pl8assets/snippet3.m}
\fig{/prelabs/pl8assets/snippet3}

The motor behaves as an electromechanical low-pass filter. When high frequency inputs are supplied, the motor attenuates the AC components and responds to the DC components, which, for a PWM signal, is the average value of the signal. The general recommendation for choosing a PWM frequency is to stay above the human audible range, away from the natural frequencies of the components in the motor control sysem, but not have the frequency too high as it will degrate the efficiency of the switching semiconductors. 

## Feedback Control

To control the speed of the motor precisely, and consequently its position, feedback control is required. Assuming the availability of a sensor to measure the actual speed of the motor, we can apply a PID controller to achieve a specific transient and steady-state response. The feedback control on the motor with the PID controller can be modeled in the s-domain and simulated with the transfer function of the system. 

The transfer function of the PID controller is given as
$$
G_{PID}(s)=\dfrac{K_ds^2+K_ps+K_i}{s}
$$

Assuming unity feedback (ignoring sensor dynamics) the closed-loop system, i.e. the complete new system with the motor and controller in feedback becomes:

$$
G_{cl}(s)=\dfrac{G_c(s)G_p(s)}{1+G_c(s)G_p(s)}
$$

Using the function `feedback()` from the Control Systems Toolbox in matlab, this can be calculated from $G_c$ and $G_p$ as `feedback(Gc*Gp,1)`, or computed directly using the above equation.

Let's simulate the closed-loop response of the motor with the PID controller, to control the speed of the motor. 


\input{matlab}{/prelabs/pl8assets/snippet4.m}
\fig{/prelabs/pl8assets/snippet4}

## Numerical Integration 
The above simple simulation is good for understanding the dynamic response characteristics of a system and the general form of the controller suitable. Often times, the real system has added constraints and nonlinearities that can not be modeled in the transfer function. It's almost always better to resort to the good ol' basic numerical integration method to simulate the dynamics of the system. 

The numerical integration simulation is also a discrete setup, which is similar in form to what occurs on the microcontroller. When we apply a PID controller on a motor using a microcontroller what we have is a continuous "plant" and a discrete, or digital, controller. 

The continuous PID control law in the time domain is given as

$$
u(t) = K_p e(t) + K_i \int{e(t) dt} + K_d \dot{e}(t)
$$

The continuous PID controller form *can* be used in the code of the microcontroller. The integral of the error and the derivative of the error can each be computed numerically, by numerical integration and numerical differentiation respectively. But a better approach is to use the discrete form of the PID controller. 

### Digital PID Controller
Similar to how we converted a continuous filter transfer function into a discrete filter transfer function then onto a difference equation, we can apply the same thing and derive the following discrete PID control law

> A filter, a motor or a controller are all dynamic systems that have an input and output and can be modeled as a transfer function, both in the continuous-domain or digital-domain

$$
u[k] = u[k-1] + a\,e[k] + b\,e[k-1] + c\, e[k-2]
$$

Note that the error is not differentiated nor integrated, all is needed is the current and past two values of the error, as well as the last output of the controller $u$

The gains $a,b,c$ are the digital PID controller gains, they are a function of the continuous PID gain $K_p, K_i, K_d$ in addition to the sampling time $T_s$ of the controller (the time-period at which the controller is calculated or executed):

$a=K_p+K_i\dfrac{T_S}{2}+\dfrac{K_d}{T_S}$,

$b=-K_p+K_i\dfrac{T_S}{2}-\dfrac{2K_d}{T_S}$,

$c=\dfrac{K_d}{T_S}$

To simulate the system response, we need a time domain model of the motor dynamics, with the state (we include current here as well to see its response)

$x=\begin{bmatrix} \Omega \\ \dot{\Omega} \\ I \end{bmatrix} = \begin{bmatrix} x_1 \\ x_2 \\ x_3 \end{bmatrix}$

$$
\dot{x} = \begin{bmatrix} \dot{\Omega} \\ \ddot{\Omega} \\ \dot{I}\end{bmatrix} = 
\begin{bmatrix} \dot{\Omega} \\ \dfrac{1}{JL}(K_T E_a - (DR+K_TK_E)\Omega -(JR+DL)\dot{\Omega} ) \\ (E_a - K_E \Omega - RI) / L
\end{bmatrix} = 
\begin{bmatrix} x_2 \\ \dfrac{1}{JL}(K_T E_a - (DR+K_TK_E)x_1-(JR+DL)x_2 ) \\ (E_a - K_E x_1 - Rx_3) / L
\end{bmatrix} 
$$

\input{matlab}{/prelabs/pl8assets/snippet5.m}
\fig{/prelabs/pl8assets/snippet5}


## Saturation

Notice how the voltage spikes initially, well, in reality you aren't likely to a have a power supply source that provides this amount of voltage, or you may not want to exceed a certain voltage for other reasons (max current). This saturation constraint produces a nonlinear behavior, but it is easy to simulate it given the setup we have. 

Assume the voltage can not exceed a magnitude of $10V$

\input{matlab}{/prelabs/pl8assets/snippet6.m}
\fig{/prelabs/pl8assets/snippet6}

As you can see, adding the saturation limit makes the simulation significantly more realistic. For the motor with the saturation limits applied, the gains can be retuned to produce a balanced input values. 

## Improvement to the model

In addition to saturation limits, and assuming the motor parameters are verified to reflect those of the actual motor being simulated, there are additional improvements to the model that are possible 

 - Model the sensor dynamics and noise. This can be done by simulating the encoder as a separate system that feeds in pulsed signals based on the motor position and velocity. Or the improvement of the model can be done by adding random noise on the sensor reading $e=r-(\Omega + w)$ where $w \sim  N(0, \sigma)$
 - The motor dynamics are in the continuous domain, so a more accurate numerical integration technique may need to be used to propogate the system states. 
 - The time-period at which the control law is computed should match what is achieved on the micrcontroller (the periodic callback function frequency).
 - The friction (damping) effects are nonlinear in reality. They can be modeled and simulated more accurately. Also, static vs kinetic rotational friction.
 - If a gearbox is used, it also introduces nonlinearities in the model. 
 - Acceleration limits may be required by the application. If the motor is used in a factory or robotic manipulator, it may be unsafe to accelerate beyond a certain limit.

### How much reality is enought?
It depends on what you are trying to do. If it is fairly simple to setup the experiment on the real motor, it would make more sense to head straight and try the controller on the micrcontroller directly. In fact, with experimentation, the model in the simulation can be adjusted and tuned to reflect reality. 