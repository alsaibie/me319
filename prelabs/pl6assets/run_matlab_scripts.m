%%
clear all;
%% Snippet 1
diary 'snippet1.out'
run('snippet1.m')
saveas(gcf,'snippet1.svg');
diary off

%% Snippet 2
diary 'snippet2.out'
run('snippet2.m')
saveas(gcf,'snippet2.svg');
diary off

%% Snippet 3
diary 'snippet3.out'
run('snippet3.m')
saveas(gcf,'snippet3.svg');
diary off

%% Snippet 4
diary 'snippet4.out'
run('snippet4.m')
saveas(gcf,'snippet4.svg');
diary off

%% Snippet 5
diary 'snippet5.out'
run('snippet5.m')
saveas(gcf,'snippet5.svg');
diary off

%% Snippet 6
diary 'snippet6.out'
run('snippet6.m')
saveas(gcf,'snippet6.svg');
diary off

%% Snippet 7
diary 'snippet7.out'
run('snippet7.m')
saveas(gcf,'snippet7.svg');
diary off

%% Snippet 8
diary 'snippet8.out'
run('snippet8.m')
diary off



