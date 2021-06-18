duty = 50;
frequency = 10;
t_length = 4 / frequency;
[t, u] = pwm(duty, frequency, t_length);
plot(t,u, 'LineWidth',3, 'color', 'k'); xlabel('Time [s]'); ylabel('[V]'); grid on; hold on;
ylim([-.1, 1.1])
xlim([0, t(1,end)*1.1])


