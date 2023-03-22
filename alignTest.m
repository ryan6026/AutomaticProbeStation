clear all
% connect to MCU
 MCU = serialport("COM6", 9600);
% connect to stage
stage = serialport("COM5", 9600);
% Photomask data
dx=fliplr(diff([-41480, -39380, -37280, -35180, -33080, -30980, -28830, -27270, -25710, -23842, -22282, -20722, -18835, -17275, -15715
]).*1/4000);
dy = 0.425;

moveStage(stage, sum(dx), dy*8)
input("Continue to next site?")
moveStage(stage, 0, dyc.*2)
% ETC ... making sure that the stage is aligning visually with the pads
function moveStage(stage, x, y) % in mm
    write(stage, "M X="+int2str(x*1e4)+"Y="+int2str(y*1e4)+char(0x0d), "char")
end
