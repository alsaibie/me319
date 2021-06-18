t = 0:Ts:4;
x_sim_sat = zeros(3,length(t)); % Empty 2xn array
u_sat = zeros(1,length(t)); % Empty 1xn vector
e_sat = u_sat; % Empty 1xn vector
r = 5;
for ix = 1:length(t)

    % Compute the error
    e_sat(1, ix) = r -  x_sim_sat(1, ix);
    % Calculate the next input value 
    
    if (ix > 2)
        u_sat(1,ix) = u_sat(1,ix-1) + a * e_sat(1,ix) + b * e_sat(1,ix-1) + c * e_sat(1,ix-2);    
    elseif (ix == 2)
        u_sat(1,ix) = u_sat(1,ix-1) + a * e_sat(1,ix) + b * e_sat(1,ix-1) + 0;
    elseif (ix == 1)
        u_sat(1,ix) =  0 + a * e_sat(1,ix) + 0 + 0;
    end
    
    % Apply saturation limits 
    if u_sat(1,ix) > 10
        u_sat(1,ix) = 10;
    elseif u_sat(1,ix) < -10
        u_sat(1,ix) = -10;
    end
    
    xdot = dxdt(t(ix), x_sim_sat(:,ix), u_sat(1,ix)); % Grab the derivative vector
    
    if(ix < length(t) )
        x_sim_sat(:, ix+1) = x_sim_sat(:, ix) + xdot * Ts;      
    end
end

subplot(2,2,1); 
plot(t, u_sat(1,:)); title('Input [V]'); xlabel('Time [s]');  grid on; hold on;
plot(t, u(1,:))
legend('Saturation', 'No Saturation')
subplot(2,2,2); 
plot(t, x_sim_sat(1,:)); title('Velocity [rad/s]'); xlabel('Time [s]'); grid on; hold on;
plot(t, x_sim(1,:)); legend('Saturation', 'No Saturation')
subplot(2,2,3); 
plot(t, x_sim_sat(3,:)); title('Current [A]'); xlabel('Time [s]'); grid on; hold on;
plot(t, x_sim(1,:));legend('Saturation', 'No Saturation');
subplot(2,2,4); 
plot(t, e_sat(1,:)); title('Error [rad/s]'); xlabel('Time [s]'); grid on; hold on;
plot(t, e(1,:)); legend('Saturation', 'No Saturation');