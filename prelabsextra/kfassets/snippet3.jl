@show A = [0 1; -g/L -b/(m*L)]
B = [0; 0]; C = [1 0; 0 1];

n = 2; # Number of States
m = 2; # Number of Outputs
points = length(t); # Number of measurements 

@show Q = [0.1^2 0; 0 0.25^2];
@show R = [σ_θ^2 0; 0 σ_ω^2]

P = zeros(n, n, points);
K = zeros(n, m, points);

P[:,:,1] = diagm([0.01^2, 0.01^2]);

x̂ = zeros(n, points);
x̂[:,1] = xₒ;

r = zeros(m, points); # Innovation 

for k in 2:length(t)
    # Time update a.k.a Prediction a.k.a State Propagation
    Ṗ = A * P[:,:,k-1] + P[:,:,k-1] * A' + Q;
    ẋ = A * x̂[:,k-1];

    P̃ = P[:,:,k-1] + Ṗ * Δt
    x̃ = x̂[:,k-1] +  ẋ * Δt

    # Kalman Gain. Larger gains puts a heavier weight on the measurement and vice versa.
    K[:,:,k] = P̃*H' * inv( H*P̃*H' + R);
    
    # Measurements Update 
    r[:,k] = sol_noisy[:,k] - H * x̃;   # Innovation: Error between measurement and "predicted" measurement.
    x̂[:,k] = x̃ + K[:,:,k] * r[:,k];    # aposteriori state estimate update
    P[:,:,k] = (I - K[:,:,k] * H) * P̃; # aposteriori error covariance update
end

kf_estimate_error = (sol_noisy - x̂);