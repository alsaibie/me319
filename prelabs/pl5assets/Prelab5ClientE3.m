%% Clear Open Ports - Might Crash Other Serial Devices
% When you open a com port, you need to close it properly.
% When we terminate a script we often don't close the port
% properly, so we need to scan open ports and close them here. 
% A proper script would use a try-catch 
if ~isempty(instrfind)
     fclose(instrfind);
     delete(instrfind);
end

%%
% Relace COM6 with the port number of the connected mcu, you can find the
% port number from PlatformIO's home page, under Devices

mcuCom = serial('COM6','BaudRate',1000000);
% Open the serial port as a file descriptor - then treat it as a
% file-access
fopen(mcuCom)
% If the device was sending prior to connection, we want to throw away old
% buffered data and grab the latest only. So we flush
flushinput(mcuCom)

% Send a stream of characters to the microcontroller 
a = 0:50;
for k = 1:length(a)
   % By default, fwrite sends ASCII characters, but we can specify specific
   % data types
   fwrite(mcuCom,a(k), "uint8");
   pause(0.01);
   % Grab back the echoed number 
   readline = fgetl(mcuCom);
   
   disp(readline);
end
 
% Close the port properly at the end 
fclose(mcuCom);
delete(mcuCom);
