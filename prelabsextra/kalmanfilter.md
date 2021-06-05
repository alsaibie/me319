
@def title = "Lab 5 Extra - Introduction to Kalman Filtering"

# Kalman Filter
## Pendulum Dynamics
We will explore the use of a Kalman Filter to estimate the state of a free pendulum starting from an initial state with damped oscillation. We will first explore the use of a linear Kalman Filter based on a linearized model of the pendulum dynamics. Then, we will look at using an Extended Kalman Filter to estimate the states.

The following are the dynamics of the system:
$$\dot{x} =\left\lbrack \begin{array}{c}
\dot{\theta} \\
\ddot{\theta} 
\end{array}\right\rbrack =\left\lbrack \begin{array}{c}
\dot{\theta} \\
\frac{-b}{\mathit{\text{mL}}}\dot{\theta} -\frac{g}{L}\sin \left(\theta \right)
\end{array}\right\rbrack$$

Let's integrate this over a fixed time interval with an initial state. 


\input{julia}{/prelabsextra/kfassets/snippet1.jl}
\input{plaintext}{/prelabsextra/kfassets/output/snippet1.txt}
\fig{/prelabsextra/kfassets/snippet1}

Now let us assume we want to measure the angular position and angular velocity, but we don't have a sophisticated measurement device and so the measurements are noisy. Let's assume the measurement noise is white, Gaussian, not correlated and with zero-mean. Let's add that affect onto the process. Assume the measurements are taken at a sample time of *Tm*


\input{julia}{/prelabsextra/kfassets/snippet2.jl}
\input{plaintext}{/prelabsextra/kfassets/output/snippet2.txt}
\fig{/prelabsextra/kfassets/snippet2}

Now this may be an exaggeratted noise, we can change the standard deviation of the measurement noise to make it better or worst, but let's keep it and see how well a Kalman Filter can perform.

## Linear Kalman Filter
We clearly don't have a decent measurement system, let's try to apply a Kalman Filter to better estimate our states. Here is a summary of the Kalman Filter for a Discrete Time-Variant Linear System.
## TODO: change to continuous
Given the dynamic system:
$$x_k =F_{k-1} x_{k-1} +G_{k-1} u_{k-1} +w_{k-1}$$
$$y_k =H_k x_k +v_k$$
$$w_k \sim N\left(0,R\right)$$
$$v_k \sim{N(0, Q)}$$

Initialized as follows:
$${\hat{x} }_0^+ =E\left(x_0 \right)$$
$$P_0^+ =E\left\lbrack \left(x_0 -{\hat{x} }_0^+ \right){\left(x_0 -{\hat{x} }_0^+ \right)}^T \right\rbrack$$

And for each k=1,2,...
Perform a time-update
$$P_k^- =F_{k-1} P_{k-1}^+ F_{k-1}^T +Q_{k-1}$$
$${\hat{x} }_k^- =F_{k-1} {\hat{x} }_{k-1}^+ +G_{k-1} u_{k-1}$$

And then a measurement-update
$$K_k =P_k^- H_k^T {\left(H_k P_k^- H_k^T +R_k \right)}^{-1}$$
$${\hat{x} }_k^+ ={\hat{x} }_k^- +K_k \left(y_k -H_k {\hat{x} }_k^- \right)$$
$$P_k^+ \text{ }=\left(I-K_k H_k \right)P_k^- {\left(I-K_k H_k \right)}^T +K_k R_k K_k^T$$
$$=\left(I-K_k H_k \right)P_k^-$$

Since our system is time-invariant, F, G, and H are constant matrices. We have to linearize our system before we use the Kalman Filter above, let's assume a small angle approximation, this would result in the system:
$$\dot{x} \left(t\right)=\text{Ax}\left(t\right)+w\left(t\right)=\left\lbrack \begin{array}{c}
0 & 1\\
-\frac{g}{L} & -\frac{b}{\mathit{\text{mL}}}
\end{array}\right\rbrack \left\lbrack \begin{array}{c}
\theta \\
\dot{\theta} 
\end{array}\right\rbrack +w\left(t\right)$$
$$y_k =\left\lbrack \begin{array}{c}
1 & 0\\
0 & 1
\end{array}\right\rbrack \left\lbrack \begin{array}{c}
\theta \\
\dot{\theta} 
\end{array}\right\rbrack +v_k$$

The Kalman Filter above is for a discrete system, but our system is a continuos one, we can either discretize our dynamical system or use a continuous Kalman Filter form, the measurement model will remain discrete either way. Let's go ahead and discretize our model using control-package functions with dt=Ts.

\input{julia}{/prelabsextra/kfassets/snippet3.jl}
<!-- \input{plaintext}{/prelabsextra/kfassets/output/snippet3.txt} -->
<!-- \fig{/prelabsextra/kfassets/snippet3} -->

