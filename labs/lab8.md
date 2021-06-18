@def title = "Lab 8 - Cascaded Motor Control"
@def hascode = true

# Lab 8 - Online Digital Filtering
In this assignment you will be extending the work in the prelab, to apply position control on the motor. 

Before attempting this assignment, make sure you go through the [Prelab 8](/prelabs/prelab8/)  first.

## Tools Required
- MATLAB v 2016b or higher, with Control System Toolbox

## Project Creation & Submission

You will work within a single MATLAB Live Script file, add your comments and code within it and submit only a single *.mlx file + a single pdf exported from the Live Script (From Live Editor Tab, click on the save drop down menu and select Export as PDF).

## Assignment Tasks and Questions

With the closed-loop velocity control system we have already, we can wrap another control loop around it for position control, as shown on Figure 1. If velocity controller,  $G_{c1} (s)$ produces a good velocity response (stable, good transient response with zero steady-state error), the outer-loop controller $G_{c2}(s)$ can be a simple proportional controller. Practically, the position controller will scale the position error to produce a desired reference velocity. 

\fig{/labs/l8assets/CascadedControllers_Position_Velocity_Motor_Control}

### 1. Cascaded Position Control

Simulate the position control loop below to a step input, using a proportional controller for $G_{c2}(s)$.

You already have $G_{cl}$ for the velocity control system, you only need to add an integrator and produce a new $G_{clp}(s)$ and then simulate using `step()`

\fig{/labs/l8assets/CascadedControllers_Position_Velocity_Motor_Control_reduced}

### 2. Numerical Integration Simulation

Within the numerical integration simulation setup, augment the model of the motor to include position. You will need to add another (fourth state) representing position. Then keeping the PID velocity controller in place, add the position controller (proportional control). Your new reference input is now position, the old velocity reference input is now calculated as an output from your position controller. 

The output of the position controller: 

$u_{pos}=r_{vel}=K_{p\,pos} e_{pos}=K_{p\,pos} (r_{pos}-x_1)$, 

where $x_1$ represents position, and $r_{vel}$ is what is applied into the velocity PID controller.ز

We are here assuming both position control and velocity control occur at the same rate. In practice, the velocity control loop is usually executed at a higher rate than the position control loop. 
