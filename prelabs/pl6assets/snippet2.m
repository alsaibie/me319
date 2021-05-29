y = fft(NoisyData);
L = length(t);
P2 = abs(y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2 * P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f(1:end/2),P1(1:end/2)); xlabel('Frequency [Hz]'); ylabel('|P1|');