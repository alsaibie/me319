[num,den] = tfdata(HzF, 'v');
FilteredDataNotch = filter(num, den, NoisyData);
LpNotchError = immse(OriginalData,FilteredDataNotch);
subplot(2,1,1)
bode(HzF)
subplot(2,1,2)
plot(t,NoisyData, 'Color', [.1 .2 .1], 'LineWidth', 0.5); hold on;
plot(t,FilteredDataNotch, 'LineWidth', 2);
plot(t,OriginalData, 'LineWidth', 2);
hold off; 
legend('Noisy', 'Filtered', 'Pure' );
xlabel('Time');