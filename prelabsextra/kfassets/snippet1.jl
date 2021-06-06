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
t = sol.t

function draw_pendulum(θ_list)
    L = 1;
    local p = plot()
    for θ in θ_list
        plot!(p, [0,L*sin(θ)], [0,-L*cos(θ)],size=(300,300),xlim=(-1.2*L,1.2*L),ylim=(-L*1.2,1),ms=2, markershape = :hexagon,label ="", axis = []);
        plot!(p, [L*sin.(θ)], [-L*cos.(θ)], ms=8, markershape = :circle, label ="", aspect_ratio = :equal, showaxis = false);
    end
    return p
end

anim = @animate for i ∈ 1:length(t)
    panim = draw_pendulum([sol[1,i]])
    local p = plot(sol[1:i], lw=2, label=["θ [rad]" "ω [rad/s]"], layout=(2,1))
    plot!(p, framestyle=:origin, xguide="Time (s)", linecolor=colors, title="", size=(800, 400); grid=true, minorgrid=true, xlim=[0,10], ylim=[-2,2]) #hide
    plot(panim, p, layout=grid(1, 2, widths=[0.35 , .65]), size=size=(800, 400))
end

gif(anim, "snippet1.gif", fps = 100) #hide

savefig(joinpath(@__DIR__, "output", "snippet1.svg")) #hide
