ωc_lp = 75; # Hz
F_lp = Butter_LP(1, ωc_lp)

F_notch_1 = iirnotch(4*f1, 30; fs = 1/T)
F_notch_2 = iirnotch(16*f1, 30; fs = 1/T)

F_Notch = F_notch_1 * F_notch_2;
F_lp_Notch = F_Notch * SecondOrderSections(F_lp)

@show HLP = minreal(Filter_to_TF(ZeroPoleGain(F_lp_Notch)))

global FilteredDataLPNotch = filt(F_lp_Notch, NoisyData)

LPNotchError = sqrt(mean((OriginalData-FilteredDataLPNotch).^2))

global psignal = plot(t, NoisyData, label="Noisy")
plot!(psignal, t, FilteredDataLPNotch, lw=3, label="Filtered")
plot!(psignal, t, OriginalData, lw=3, label="Original")

p1 = psignal
p2 = bodeplot(HLP, title = "\$ ω_c = $ωc_lp rad/s\$")

pl = plot(p1, p2, layout = (2,1), size=(1200, 600))
plot!(pl, background_color=:transparent, foreground_color=:black, size=(1200, 600); grid=true, minorgrid=true) #hide

savefig("snippet5.svg") #hide

