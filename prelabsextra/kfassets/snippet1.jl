using Plots
using DifferentialEquations

# Pendulum Parameters
m = 0.5;  # Mass of the pendulum
b = 0.25; # Damping Coefficient
L = 2.8;  # Length of the Pendulum 
g = 9.81; # Gravitational Constant, the average nominal value on Earth,
          # not necessarily where you are standing right now. In fact, the gravitational constant varies 0.7% 
          # across different earth locations, but let's get back to our lesson. 


function pendulum!(dx, x, p, t)
    dx[1] = x[2]; 
    dx[2] = -b/(m*L)*x[2] - g/L * sin(x[1])
end


θₒ = π/4;
ωₒ = 0;
xₒ = [θₒ, ωₒ];

Δt = 0.1; 

tspan = (0.0, 10.0)

prob = ODEProblem(pendulum!,xₒ,tspan)
sol = solve(prob, saveat = Δt)

p = plot(sol,linewidth=2, label=["θ [rad]" "ω [rad/s]"],layout=(2,1))
plot!(p, framestyle=:origin, xguide="Time (s)", linecolor=colors, title="", background_color=:transparent, foreground_color=:black, size=(800, 400); grid=true, minorgrid=true) #hide

savefig(joinpath(@__DIR__, "output", "snippet1.svg")) #hide
