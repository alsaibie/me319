using Plots

Fs = 1000;
T = 1 / Fs;
L = 1000;
t = range(0, L*T, step = T)
A = 3;
f1 = 5; # Hz - Base frequency
# Base Signal
OriginalData = A * sin.(2*pi* f1 * t);

# Add Higher Frequency Components
NoisyData = OriginalData + 0.2*A*sin.(2*pi*f1*4*t) +  0.2*A*sin.(2*pi*f1*16*t);
# Add random noise
NoisyData = NoisyData + 0.25*A*randn(length(t));

p = plot(t, OriginalData, lw = 4, label="Original")
plot!(p, t, NoisyData, label = "Noisy")
plot!(p, framestyle=:origin, xguide="Time (s)", yguide="A", linecolor=colors, title="", background_color=:transparent, foreground_color=:black, size=(800, 400); grid=true, minorgrid=true) #hide

savefig("snippet1.svg") #hide
