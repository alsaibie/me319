using ControlSystems, Statistics

s = tf("s")
ωc_list = [5, 20, 100]
p = repeat([plot(1)], 3, 2)

function tfdata(G::TransferFunction)
    num = G.matrix[1].num.coeffs
    den = G.matrix[1].den.coeffs
    return num, den
end

LpError = zeros(length(ωc_list))

for (idx, ωc) in enumerate(ωc_list) 
    # Construct the first order continous filter
    @show H = 1 / (s/ωc + 1);
    # Convert to discrete
    @show Hz = c2d(H,T)
    # Grab the num / den coefficients of the discrete T.F.
    (a, b) = tfdata(Hz);
    FilteredData1stOrder = zeros(length(OriginalData));

    for m = 2:length(NoisyData)
        FilteredData1stOrder[m] = - b[1] * FilteredData1stOrder[m-1] + a[1] * NoisyData[m-1];
    end
    # Compute the mean square error between the original signal and the filtered signal
    LpError[idx] = sqrt(mean((OriginalData-FilteredData1stOrder).^2))
    
    psignal = plot(t, NoisyData, label="Noisy")
    plot!(psignal, t, FilteredData1stOrder, label="Filtered")
    plot!(psignal, t, OriginalData, label="Original")
    plot!(psignal, framestyle=:origin, xguide="Time (s)", yguide="A", linecolor=colors, title="", background_color=:transparent, foreground_color=:black, size=(800, 400); grid=true, minorgrid=true) #hide

    p[idx, 1] = psignal
    p[idx, 2] = bodeplot(H, title = "\$ ω_c = $ωc rad/s\$")

end

p = plot(p..., layout = (2,3), size=(1200, 600))
plot!(p, background_color=:transparent, foreground_color=:black, size=(1200, 600); grid=true, minorgrid=true) #hide

savefig("snippet3.svg") #hide