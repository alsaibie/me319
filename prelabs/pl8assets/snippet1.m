% Define Motor Parameters
J = 0.06; D =0.03; 
Kt = 0.07; Ke = 0.03; 
R = 0.07; L = 0.04;
s = tf("s");
Gp = Kt / (J * L * s^2 + (J*R + D*L)*s + (D*R + Kt*Ke))
[x,t] = step(Gp);
plot(t,x, 'LineWidth',3, 'color', 'k'); xlabel('Time [s]'); ylabel('[rad/s]'); grid on; hold on;
legend('Speed');
hold off;