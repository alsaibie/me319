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
z = sol_noisy;

for k in 2:length(t)
    # Time update a.k.a Prediction a.k.a State Propagation
    Ṗ = A * P[:,:,k-1] + P[:,:,k-1] * A' + Q; 
    ẋ = A * x̂[:,k-1];

    # Integrate to propagate apriori state and apriori covariance
    x̂⁻ = x̂[:,k-1] +  ẋ * Δt
    P⁻ = P[:,:,k-1] + Ṗ * Δt

    # Kalman Gain. Larger gains puts a heavier weight on the measurement and vice versa.
    K[:,:,k] = P⁻*H' * inv( H*P⁻*H' + R);
    
    # Measurements Update 
    x̂[:,k] = x̂⁻ + K[:,:,k] *(z[:,k] - H * x̂⁻);  # aposteriori state estimate update
    P[:,:,k] = (I - K[:,:,k] * H) * P⁻;         # aposteriori error covariance update
end

kf_e = (sol - x̂);
kf_e_rms = [rms(kf_e[1,:]),  rms(kf_e[2,:])]
@show kf_e_rms

anim = @animate for i ∈ 1:length(t)
    local p = plot(sol[1:i], lw=2, label=["θ [rad]" "ω [rad/s]"], layout=(2,1))
    scatter!(p, t[1:i], sol_noisy[:,1:i]', label=["θ measured [rad]" "ω measured [rad/s]"], ms=1, layout=(2,1))
    plot!(p, t[1:i], x̂[:,1:i]', label=["θ estimated [rad]" "ω estimated [rad/s]"], lw=2, layout=(2,1))
    plot!(p, framestyle=:origin, xguide="Time (s)", linecolor=colors, title="", size=(800, 400); grid=true, minorgrid=true, xlim=[0,10], ylim=[-2,2]) #hide
end

gif(anim, "snippet3.gif", fps = 100) #hide

savefig(joinpath(@__DIR__, "output", "snippet3.svg")) #hide