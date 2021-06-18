function [t, pwm_s] = pwm(duty, frequency_hz, t_length_s)
    pulse_n = 100;
    samples_n = max(2000,pulse_n * t_length_s * frequency_hz);
    pwm_s = zeros(1,samples_n);
    t = linspace(0, t_length_s, samples_n);
    for k = 1:length(pwm_s)
        order_duty = mod(k, pulse_n) / pulse_n * 100;
        if (order_duty < duty)
            pwm_s(1,k) = 1;
        end
    end
end