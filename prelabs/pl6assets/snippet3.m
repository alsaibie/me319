s = tf('s');
wc = [5, 20, 100];
l= length(wc);
fig = figure();
fig.Position = [500 400 1920 1080];

for k=1:l
    % Construct the first order continous filter
    H = 1 / (s/wc(k) + 1);
    % Convert to discrete
    Hz = c2d(H,T)
    % Grab the num / den coefficients of the discrete T.F.
    [num,den] = tfdata(Hz, 'v');
    a = num
    b = den
    FilteredData1stOrder = zeros(1,length(OriginalData));

    for m = 2:length(NoisyData)
        FilteredData1stOrder(m) = - b(2) * FilteredData1stOrder(m-1) + a(2) * NoisyData(m-1);
    end
    %Compute the mean square error between the original signal and the filtered signal
    LpError(k) = immse(OriginalData,FilteredData1stOrder); 
    
    %BLOTTING
    subplot(2,3,k)
    % We'll also plot the Bode diagram of the continous filter
    bode(H)
    subplot(2,3,k+3)
    plot(t,NoisyData, 'Color', [.1 .2 .1], 'LineWidth', 0.5); hold on;
    plot(t,FilteredData1stOrder, 'LineWidth', 2);
    plot(t,OriginalData, 'LineWidth', 2);
    hold off; 
    legend('Noisy', 'Filtered', 'Original');
    xlabel('Time');
end