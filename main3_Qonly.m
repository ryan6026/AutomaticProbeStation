% Same thing as integrated, but without noise and IR / linStage
clear all
% !! IMPORTANT Before running this script !!
%Input your sweep range in VNAmeasurement if doing noise analysis
% make sure device is upside down with pads facing the probe station
% ZERO  the  STAGE  with probe on 11-R1C1
%    AND
% MAKE SURE PROBE POWER is PLUGGED IN!
% The VNA socket must be turned on by going to "system" -> "misc setup"
% -> "network remote control settings" -> "socket server (on)"
% make sure to lead -== good-state4 ==- before starting!
% With chip positioned upside down, land probe on R1C1 and ZERO stage!
chip = "S3-D4";

stage = serialport("COM4", 9600);

dxc=-27989/4000;
% dyc=15800/4000 + 0.0117;
dyc=15800/4000;
dx=fliplr(diff([-41480, -39380, -37280, -35180, -33080, -30980, -28830, -27270, -25710, -23842, -22282, -20722, -18835, -17275, -15715]).*1/4000);
dx=[dx, 0];
dy = 0.425;
% connect to MCU
MCU = serialport("COM6", 9600);
% Connect to VNA
try
    vna = tcpclient("127.0.0.1", 5025, "Timeout", 20, "ConnectTimeout", 5);
catch ME
    disp('Error establishing TCP connection.');
    disp('Check that the VNA TCP socket is active. see note in main2.m');
    return
end


pause(1)
% Flush serial buffer
if(MCU.NumBytesAvailable>0)
    read(MCU, MCU.NumBytesAvailable, "char");
end

probeUp(MCU) %is there power??/
write(stage, "S X=3 Y=3"+char(0x0d), "char")
write(stage, "AC X=1 Y=1"+char(0x0d), "char")
write(stage, "PC X=0.000030 Y=0.000030"+char(0x0d), "char")
input("did probe go up? (if no, ctrl+c to quit!)")
R=0;
x=0; y=0;
xc=0; yc=0;
xoff=0;yoff=0; % 0.015 is good place to start
for Sy=1:6
    for Sx=1:3

        % measure B devs
        for xi=4:6
            xc=(Sx-1)*dxc+xoff;
            x=xc+sum(dx(1:(xi-1)));
            for yi=1:9
                yc=(Sy-1)*dyc+yoff;
                y=yc+dy*(yi-1);
                moveStageLong(stage, x, y)
                probeDown(MCU)
                pause(1)
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                VNAmeasurement(vna, xi, yi, Sprefix)
                probeUp(MCU)
            end
        end
            %         measure E devices
        for xi=10:15
            xc=(Sx-1)*dxc+xoff;
            x=xc+sum(dx(1:(xi-1)));
            for yi=4:9
                yc=(Sy-1)*dyc+yoff;
                y=yc+dy*(yi-1);
                moveStageLong(stage, x, y)
                probeDown(MCU)
                pause(1)
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                VNAmeasurement(vna, xi, yi, Sprefix)
                probeUp(MCU)
            end
        end


    end
end
    probeUp(MCU)
    probeUp(MCU)
    run('../analysis-code/PlotdataFolder.m')


