%% Clear Open Ports - Might Crash Other Serial Devices
clear all
if ~isempty(instrfind)
     fclose(instrfind);
     delete(instrfind);
end

%%

% Motion Dynamics
dxdt = @(x)[x(3); x(4);  1*randn(1); 1*randn(1)];   
dt = 0.1;
time = 0; x = zeros(4,1);

% Create Serial Object
mcuCom = serial('COM6','BaudRate',250000);
fopen(mcuCom);
counter = 0;

% Animated Line Plot
h1 = animatedline('LineWidth', 2, 'color', 'red', 'LineStyle', ':',...
    'MaximumNumPoints',600);
hold on
% h2 = animatedline('LineWidth', 2, 'color', 'blue', 'LineStyle', ':',...
%     'MaximumNumPoints',600);
axis([0,400,-1,1]); grid on;
% xlabel('Time(s)')
setylabel = false;

% Flush First Line
flushinput(mcuCom)

while(1)
 if(~ishghandle(h1))
     delete(h2);
    break;
 end
 
 % Simulate Motion and GPS Data
 xdot = dxdt(x);
 x = x + xdot * dt;
 time = time + dt; 
 msg = "$GPS," + time + "," + x(1) + "," + x(2) + "," + norm(x(3:4));
 % Forward GPS Message to MCU
 fwrite(mcuCom, msg);
 fprintf(mcuCom, ''); % For including a return line character 
 
 % Read Incoming Data and Print 
 if (get(mcuCom, 'BytesAvailable') > 0)
     readline = fgetl(mcuCom);
     dataJSON = jsondecode(readline);     
     addpoints(h1,dataJSON.latlon(1),dataJSON.latlon(2));
     
     drawnow limitrate; % Faster animation 
     % Moving Axes [xmin xmax ymin ymax]
     axis([dataJSON.latlon(1)-50 dataJSON.latlon(1)+50 ...
         dataJSON.latlon(2)-50 dataJSON.latlon(2)+50]) 
     
     if(~setylabel)
%      ylabel(dataJSON.sensor);
     setylabel = true;
     end
 end
 pause(dt);
end

% We don't reach here...
fclose(mcuCom);
delete(mcuCom);