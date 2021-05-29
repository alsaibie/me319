s = tf('s');
wclp = 75; %Hz
fig = figure();
fig.Position = [573 438 1500 600];
Hlp = 1 / (s/wclp + 1);
Hzlp = c2d(Hlp,T);
[numN1, denN1] = iirnotch(4*f1/(3.15*Fs), 4*f1/(3.15*Fs)/35);
HzN1 = tf(numN1,denN1, T);

[numN2, denN2] = iirnotch(16*f1/(3.15*Fs), 16*f1/(3.15*Fs)/35);
HzN2 = tf(numN2,denN2, T);

HzF = Hzlp * HzN1 * HzN2;
display(HzF)