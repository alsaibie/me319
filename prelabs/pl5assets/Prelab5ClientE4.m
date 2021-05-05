%% Clear Open Ports - Might Crash Other Serial Devices
if ~isempty(instrfind)
     fclose(instrfind);
     delete(instrfind);
end

%%
% Create Serial Object
mcuCom = serial('COM6','BaudRate',250000);
fopen(mcuCom);
counter = 0;

% Animated Line Plot
h1 = animatedline('LineWidth', 2, 'color', 'red', 'LineStyle', ':',...
    'MaximumNumPoints',600);
hold on
h2 = animatedline('LineWidth', 2, 'color', 'blue', 'LineStyle', ':',...
    'MaximumNumPoints',600);
axis([0,400,-1,1]); grid on;
xlabel('Time(s)')
setylabel = false;

% Flush First Line
flushinput(mcuCom)

while(1)
 if(~ishghandle(h1))
     delete(h2);
    break;
 end
 % Read Incoming Data and Print 
 if (get(mcuCom, 'BytesAvailable') > 0)
     readline = fgetl(mcuCom); 
     % readline = {"sensor":"MagicSensor","time":475100,"data":[0.518027,-0.855364]}
     % MATLAB has built-in json support 
     dataJSON = jsondecode(readline);     
     addpoints(h1,dataJSON.time/1000,dataJSON.data(1));
     addpoints(h2,dataJSON.time/1000,dataJSON.data(2));
     
     drawnow limitrate; % Faster animation 
     % Moving Axes [xmin xmax ymin ymax]
     axis([dataJSON.time/1000-10 dataJSON.time/1000+10 -1.1 1.1]) 
     
     if(~setylabel)
     ylabel(dataJSON.sensor);
     setylabel = true;
     end
     
 end
end

% We don't reach here...
fclose(mcuCom);
delete(mcuCom);
