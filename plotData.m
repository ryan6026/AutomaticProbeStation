set(0, "defaulttextfontsize", 32)  % title
set(0, "defaultaxesfontsize", 16)  % axes labels
set(0, "defaultlinelinewidth", 2)

files = dir(".");
names={};
for i=3:length(files)-1
  name=files(i).name
  data=csvread(name);
  f=data(:,1);Y=data(:,2);
  plot(f,Y)
  hold on
  plot(f,Y)
  names=[names, strcat(name(11:13),"um")]
  legend(names)
endfor
title("Admittance Curves")
