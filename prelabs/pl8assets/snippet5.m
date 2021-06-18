Kp = 10; Ki = 5; Kd = 8; Ts = 0.01;
a = (Kp + Ki * Ts / 2 + Kd / Ts); b = (-Kp + Ki * Ts / 2 - 2 * Kd / Ts); c = Kd / Ts

dxdt = @(t,x,E)[ 
    x(2);
    1/(J*L) * (Kt*E - (D*R + Kt*Ke)*x(1) - (J*R + D*L)*x(2));
    (E - Ke*x(1)-R*x(3))/L
    ]
    
t = 0:Ts:5;
x_sim = zeros(3,length(t)); % Empty 2xn array
u = zeros(1,length(t)); % Empty 1xn vector
e = u; % Empty 1xn vector
r = 5;
for ix = 1:length(t)

    % Compute the error
    e(1, ix) = r -  x_sim(1, ix);
    % Calculate the next input value 
    
    if (ix > 2)
        u(1,ix) = u(1,ix-1) + a * e(1,ix) + b * e(1,ix-1) + c * e(1,ix-2);    
    elseif (ix == 2)
        u(1,ix) = u(1,ix-1) + a * e(1,ix) + b * e(1,ix-1) + 0;
    elseif (ix == 1)
        u(1,ix) =  0 + a * e(1,ix) + 0 + 0;
    end
    
    xdot = dxdt(t(ix), x_sim(:,ix), 1); % Grab the derivative vector
    
    if(ix < length(t) )
        x_sim(:, ix+1) = x_sim(:, ix) + xdot * Ts;      
    end
end

subplot(2,2,1); 
plot(t, u(1,:)); title('Input [V]'); xlabel('Time [s]');  grid on;
subplot(2,2,2); 
plot(t, x_sim(1,:)); title('Velocity [rad/s]'); xlabel('Time [s]'); grid on;
subplot(2,2,3); 
plot(t, x_sim(3,:)); title('Current [A]'); xlabel('Time [s]'); grid on;
subplot(2,2,4); 
plot(t, e(1,:)); title('Error [rad/s]'); xlabel('Time [s]'); grid on;