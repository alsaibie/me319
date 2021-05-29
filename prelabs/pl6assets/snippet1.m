Fs = 1000;
T = 1 / Fs;
L = 1000;
t = (0:L-1)*T;
A = 3;
f1 = 5; % Hz - Base frequency
% Base Signal
OriginalData = A * sin(2*pi* f1 * t);

% Add Higher Frequency Components
NoisyData = OriginalData + 0.2*A*sin(2*pi*f1*4*t) +  0.2*A*sin(2*pi*f1*16*t);
% Add random noise
NoisyData = NoisyData + 0.25*A*randn(1, length(t));

figure();
plot(t,OriginalData, 'LineWidth',3, 'color', 'k'); xlabel('Time [s]'); ylabel('Amplitude'); grid on; hold on;
plot(t,NoisyData); 
legend('Pure Signal', 'Noisy Signal')
hold off;