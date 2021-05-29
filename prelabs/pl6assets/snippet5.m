wc = [5, 20, 100]; %Hz
l= length(wc);
fig = figure();
fig.Position = [573 438 1500 600];

for k=1:l
    [numS,denS] = besself(2, wc(k));
    H = tf(numS,denS);
    Hz = c2d(H,T);
    [num,den] = tfdata(Hz, 'v');
    FilteredDataBessel = filter(num, den, NoisyData);
    BesselError(k) = immse(OriginalData,FilteredDataBessel);
    %BLOTTING
    subplot(2,3,k)
    bode(H)
    subplot(2,3,k+3)
    plot(t,NoisyData, 'Color', [.1 .2 .1], 'LineWidth', 0.5); hold on;
    plot(t,FilteredDataBessel, 'LineWidth', 2);
    plot(t,OriginalData, 'LineWidth', 2);
    hold off; 
    legend( 'Noisy', 'Filtered', 'Pure');
    xlabel('Time');
end