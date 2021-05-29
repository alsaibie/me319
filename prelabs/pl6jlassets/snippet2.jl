using DSP
using FFTW 
 # Only use to plot FFT

F  = fft(NoisyData) |> fftshift
freqs = DSP.fftfreq(length(t), 1.0/T) |> fftshift
p = plot(freqs, abs.(F), title = "Spectrum", lw=3, xlim=(0, +250), xlabel="Frequency", ylabel="Amplitude", label="FFT") 

plot!(p, framestyle=:origin, xguide="Time (s)", yguide="A", linecolor=colors, title="", background_color=:transparent, foreground_color=:black, size=(800, 400); grid=true, minorgrid=true) #hide

savefig("snippet2.svg") #hide