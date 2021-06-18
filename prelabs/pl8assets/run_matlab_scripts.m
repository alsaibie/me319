%%
clear all;
set(0, 'DefaultLineLineWidth', 2);
%% Snippet 1
dfile = 'snippet1.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,300]);
run('snippet1.m')
saveas(gcf,'snippet1.svg');
diary off

%% Snippet 2
dfile = 'snippet2.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,300]);
run('snippet2.m')
saveas(gcf,'snippet2.svg');
diary off

%% Snippet 3
dfile = 'snippet3.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,600]);
run('snippet3.m')
saveas(gcf,'snippet3.svg');
diary off

%% Snippet 4
dfile = 'snippet4.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,300]);
run('snippet4.m')
saveas(gcf,'snippet4.svg');
diary off

%% Snippet 5
dfile = 'snippet5.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,400]);
run('snippet5.m')
saveas(gcf,'snippet5.svg');
diary off

%% Snippet 6
dfile = 'snippet6.out'
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile) 
figure('position',[0,0,600,400]);
run('snippet6.m')
saveas(gcf,'snippet6.svg');
diary off



