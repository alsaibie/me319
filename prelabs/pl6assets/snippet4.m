wc = [5, 20, 100]; %Hz
l= length(wc);
fig = figure();
fig.Position = [500 400 1920 1080];

for k=1:l
    % The built-in butter function from the signal processing toolbox is
    % used
    [numS,denS] = butter(2, wc(k), 'low', 's');
    % Construct the continous T.F
    H = tf(numS,denS);
    Hz = c2d(H,T)
    [num,den] = tfdata(Hz, 'v');
    
    % Apply the filter() - the filter function applies the difference
    % equation on the supplied data
    FilteredDataButter = filter(num, den, NoisyData);
    ButterError(k) = immse(OriginalData,FilteredDataButter);
    
    %BLOTTING
    subplot(2,3,k)
    bode(H)
    subplot(2,3,k+3)
    plot(t,NoisyData, 'Color', [.1 .2 .1], 'LineWidth', 0.5); hold on;
    plot(t,FilteredDataButter, 'LineWidth', 2);
    plot(t,OriginalData, 'LineWidth', 2);
    hold off; 
    legend('Noisy', 'Filtered - Butter', 'Pure');
    xlabel('Time');
end
