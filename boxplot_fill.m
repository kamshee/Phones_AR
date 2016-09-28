function [ ] = boxplot_fill(whichcolor,whichbox)

h = findobj(gca,'Tag','Box');

if nargin<2
    whichbox=1:length(h);
end

 for j=whichbox
    patch(get(h(j),'XData'),get(h(j),'YData'),whichcolor,'FaceAlpha',.5);
 end