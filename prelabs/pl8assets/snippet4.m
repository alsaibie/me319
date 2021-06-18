Kp = 20; Ki = 15; Kd = 1;

Gc = (Kd*s^2+Kp*s+Ki)/s
Gcl = feedback(Gc*Gp,1)
[x,t] = step(Gcl)
plot(t,x, 'LineWidth',3, 'color', 'k'); xlabel('Time [s]'); ylabel('[rad/s]'); grid on; hold on;


