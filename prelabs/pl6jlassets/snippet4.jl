ωc_list = [5, 20, 100]
p = repeat([plot(1)], 3, 2)

function Butter_LP(order, ωc)
    F = digitalfilter(Lowpass(ωc; fs = 1/T),Butterworth(order))
    return F
end

function Filter_to_TF(F::ZeroPoleGain, T)
    zpk(F.z, F.p, F.k, T)
end
function Filter_to_TF(F::ZeroPoleGain)
    zpk(F.z, F.p, F.k)
end

ButterError = zeros(length(ωc_list))

for (idx, ωc) in enumerate(ωc_list) 
    # Construct the first order continuous filter
    Fbutter = Butter_LP(2, ωc);
    @show global H = Filter_to_TF(Fbutter)

    global FilteredDataButter = filt(Fbutter, NoisyData)

    ButterError[idx] = sqrt(mean((OriginalData-FilteredDataButter).^2))
    
    global psignal = plot(t, NoisyData, label="Noisy")
    plot!(psignal, t, FilteredDataButter, label="Filtered")
    plot!(psignal, t, OriginalData, label="Original")

    p[idx, 1] = psignal
    p[idx, 2] = bodeplot(H, title = "\$ ω_c = $ωc rad/s\$")

end

pl = plot(p..., layout = (2,3), size=(1200, 600))
plot!(pl, background_color=:transparent, foreground_color=:black, size=(1200, 600); grid=true, minorgrid=true) #hide

savefig("snippet4.svg") #hide