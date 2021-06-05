
@def title = "Lab 6 Extra - Introduction to Kalman Filter"
@def hascode = true

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

Now this may be an exaggerated noise level, we can change the standard deviation of the measurement noise to make it better or worst, but let's keep it and see how well a Kalman Filter can perform.

## Linear Kalman Filter
We clearly don't have a decent measurement system, let's try to apply a Kalman Filter to better estimate our states. Here is a summary of the Kalman Filter for a Continuous-Discrete Time-Invariant Linear System.

The continuous part is the model or process (the pendulum is a continuous system) and the discrete part is the measurement (we take readings at discrete intervals).

Given the dynamic system:

\begin{eqnarray}
  \dot{x} = A x + B u + G w\\\\
  y_k =H_k x_k + v_k \\\\
  w(t) \sim N(0, Q)\\\\
  v_k \sim{N(0, R)}\\
\end{eqnarray}

Initialized as follows:

$\hat{x}(0)=E(x_0)=\bar{x}_0\\$
$P(0)= E[(x_0 -\hat{x}(0))(x_0 -\hat{x}(0))^T]=P_0\\$

The time-update (process-update) is in the continuous domain

$$\dot{P}=AP + PA^T + GQG^T$$

$$\dot{\hat{x}} = A \hat{x}^+ + B u$$

Numerically integrate with $\Delta t$ as the time step

$P^- = P + \dot{P}\Delta t\\\\$

$\hat{x}^-=\hat{x} + \dot{\hat{x}} \Delta t\\$

And then a measurement-update in discrete form

$K_k =P_k^- H_k^T {(H_k P_k^- H_k^T +R_k )}^{-1}\\\\$
$P_k^+=(I-K_k H_k )P_k^- {(I-K_k H_k )}^T +K_k R_k K_k^T=(I-K_k H_k )P_k^-\\$
${\hat{x} }_k^+ ={\hat{x} }_k^- +K_k (y_k -H_k {\hat{x} }_k^- )\\\\$

We have to linearize our pendulum system before we use the Kalman Filter above, let's assume a small angle approximation, this would result in the system:

\begin{eqnarray}
\dot{x} \left(t\right)=\text{Ax}\left(t\right)+w\left(t\right)=\left\lbrack \begin{array}{c}
0 & 1\\
-\frac{g}{L} & -\frac{b}{\mathit{\text{mL}}}
\end{array}\right\rbrack \left\lbrack \begin{array}{c}
\theta \\
\dot{\theta} 
\end{array}\right\rbrack +w\left(t\right)\\\\
y_k =\left\lbrack \begin{array}{c}
1 & 0\\
0 & 1
\end{array}\right\rbrack \left\lbrack \begin{array}{c}
\theta \\
\dot{\theta} 
\end{array}\right\rbrack +v_k
\end{eqnarray}

\input{julia}{/prelabsextra/kfassets/snippet3.jl}
\input{plaintext}{/prelabsextra/kfassets/output/snippet3.txt}
\fig{/prelabsextra/kfassets/snippet3}


What's happening above is that state is propagated by using our knowledge of the pendulum physics (the model), which results in the apriori estimate $\hat{x}^-$. 

The covariance matrix $P$ is also propagated through time using the model physics (the $A$ matrix), the covariance matrix holds the stochastic information of each state and the statistical relationship of the states. 

Notice that in the situation above, it is independent of the state. In fact, it can be precalculated off-line, and it can converge after a time-period.
```julia
# Time update a.k.a Prediction a.k.a State Propagation
Ṗ = A * P[:,:,k-1] + P[:,:,k-1] * A' + Q; 
ẋ = A * x̂[:,k-1];

P⁻ = P[:,:,k-1] + Ṗ * Δt
x⁻ = x̂[:,k-1] +  ẋ * Δt
```
The time-update step can be done multiple times before the measurement update occurs. You can do 5 process updates for every measurement update. Measurement updates can be synchronous or asynchronous as well. 

When a new measurement is ready, we perform the **measurement update** step. We compute the Kalman gain which is a function of the covariance matrix, the sensor (output matrix $H$) and the $R$ matrix which holds the stochastic specification of the measurement model.

```julia
# Kalman Gain. Larger gains puts a heavier weight on the measurement and vice versa.
K[:,:,k] = P⁻*H' * inv( H*P⁻*H' + R);
```
>Think of the Kalman Gain as a weighting factor for the measurement versus the process (the estimate from the physics: the integration of the model). If, stochastically, we trust the process more than the measurement, the gain would be low. If we trust the measurement more, then the gain would be high. 

Then we use the gain to compute the estimate of the state, called the **aposteriori** based on the steps above it. As well as update the aposteriori of the covariance matrix

```julia
# Measurements Update 
x̂[:,k] = x̂⁻ + K[:,:,k] *(z[:,k] - H * x̂⁻);  # aposteriori state estimate update
P[:,:,k] = (I - K[:,:,k] * H) * P⁻;         # aposteriori error covariance update
```