frequency = [2 20 200]
duty = 50;
for ix = 1:length(frequency)
    subplot(3,1,ix)
    f = frequency(ix);
    t_length = 5;
    [t, u] = pwm(duty, f, t_length);
    [x, t] = lsim(Gp, u, t)
    plot(t,x, 'LineWidth',3, 'color', 'k'); xlabel('Time [s]'); ylabel('[V], [rad/s]'); grid on; hold on;
    hold on
    plot(t,u, 'LineWidth', 1, 'color', 'r')
    title(append('PWM freq = ', num2str(frequency(ix)), 'Hz, 50% duty'))
end
