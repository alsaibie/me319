function prettyfigure(f)
%PRETTYFIGURE Summary of this function goes here
h=findall(f);
hline=findobj(h,'Type','line','Tag','Curves'); hline(1).LineWidth=4;
set(findall(gcf,'-property','FontSize'),'FontSize',16) 
end

