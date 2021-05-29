function  genplain(script_file, save_figure)

if nargin < 2
    save_figure = false;
end
  
[pathstr,filename,ext] = fileparts(script_file);

fileout_txt = strcat(filename, '.out');

diary fileout_txt
run(script_file);
diary off

if save_figure == true
    fileout_fig = strcat(filename, '.svg');
    saveas(gcf,fileout_fig);
end

end