using LinearAlgebra
σ_θ = .25;
σ_ω = .5;
t = sol.t 
rms(x) = norm(x)/sqrt(length(x))
noise = [σ_θ*randn(length(t))'; σ_ω*randn(length(t))'] 
sol_noisy = zeros(size(sol))
sol_noisy = sol + noise
ϵ = (sol-sol_noisy)
ϵ_rms = [rms(ϵ[1,:]),  rms(ϵ[2,:])]

# p = plot(framestyle=:origin, xguide="Time (s)", linecolor=colors, title="", background_color=:transparent, foreground_color=:black, size=(800, 400); grid=true, minorgrid=true) #hide

anim = @animate for i ∈ 1:length(t)
    local p = plot(sol[1:i], linewidth=2, label=["θ [rad]" "ω [rad/s]"], layout=(2,1), framestyle=:origin, xguide="Time (s)", linecolor=colors, title="", size=(800, 400); grid=true, minorgrid=true)
    scatter!(p, t[1:i], sol_noisy[:,1:i]', label=["θ measured [rad]" "ω measured [rad/s]"], ms=1, layout=(2,1))
    plot!(p, xlim=[0,10], ylim=[-2,2])
end

gif(anim, "snippet2.gif", fps = 100)

savefig(joinpath(@__DIR__, "output", "snippet2.svg")) #hide