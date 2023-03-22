
clear all
% !! IMPORTANT Before running this script !!
%Input your sweep range in VNAmeasurement if doing noise analysis
% make sure device is upside down with pads facing the probe station
% ZERO  the  STAGE  with probe on 11-R1C1
%    AND
% MAKE SURE PROBE POWER is PLUGGED IN!
% The VNA socket must be turned on by going to "system" -> "misc setup"
% -> "network remote control settings" -> "socket server (on)"
% Don't forge to load your calibration if you have one
% With chip positioned upside down, land probe on R1C1 and ZERO stage!
chip = "S4-D4";
% connect to MCU
MCU = serialport("COM6", 9600);
% Connect to stage
stage = serialport("COM4", 9600);

dxc=-27989/4000;
dyc=15800/4000;
dx=fliplr(diff([-41480, -39380, -37280, -35180, -33080, -30980, -28830, -27270, -25710, -23842, -22282, -20722, -18835, -17275, -15715]).*1/4000);
dx=[dx, 0];
dy = 0.425;

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
% write acceleration and speed limits to prevent excess wear
% (Always lube your old hardware!)
write(stage, "S X=3 Y=3"+char(0x0d), "char")
write(stage, "AC X=1 Y=1"+char(0x0d), "char")
write(stage, "PC X=0.000030 Y=0.000030"+char(0x0d), "char")
% plug it in
input("did probe go up? (if no, ctrl+c to quit!)")
R=0;
x=0; y=0;
xc=0; yc=0;
xoff=0;yoff=0; %probably not needed, leave 0
for Sy=fliplr(1:7)
    for Sx=1:3

        % measure B devs
        for xi=4:6
          %calculate tile offset
            xc=(Sx-1)*dxc+xoff;
            % sum with device offset so find landing location
            x=xc+sum(dx(1:(xi-1)));
            for yi=1:9
                % part of name for device data file
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                %calculate tile offset
                yc=(Sy-1)*dyc+yoff;
                sprintf("%d, %d", xi, yi)
                % sum with device offset so find landing location
                y=yc+dy*(yi-1);
                % Long move increases accuracy on old devices
                moveStageLong(stage, x, y)
                probeDown(MCU)
                % pause(1) % not needed unless you are not sure about your redundancy checks
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                VNAmeasurement_noise(vna, xi, yi, Sprefix)
                % R=0 no IR (start)
                % R=1 stage forward
                if(R==0)
                    %Optical stage move
                    linStageBak(MCU)
                    pause(2)
                    Sprefix = "IR"+chip+sprintf('-%d%d', Sx, Sy);
                    %measures and save IR admittance data
                    VNAmeasurement(vna, xi, yi, Sprefix)
                    probeUp(MCU)
                    R=1;
                elseif(R==1)
                    %Optical stage move
                    linStageFor(MCU)
                    Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                    %measures and save NO IR admittance data and measures noise
                    VNAmeasurement_noise(vna, xi, yi, Sprefix)
                    probeUp(MCU)
                    R=0;
                end
            end
        end
          % Same thing, but different devices
         % measure E devs
        for xi=10:15
            xc=(Sx-1)*dxc+xoff;
            x=xc+sum(dx(1:(xi-1)));
            for yi=4:9
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                yc=(Sy-1)*dyc+yoff;
                sprintf("%d, %d", xi, yi)
                y=yc+dy*(yi-1);
                moveStageLong(stage, x, y)
                probeDown(MCU)
                pause(1)
                Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                VNAmeasurement_noise(vna, xi, yi, Sprefix)
                % R=0 no IR (start)
                % R=1 stage forward
                if(R==0)
                    linStageBak(MCU)
                    pause(2)
                    Sprefix = "IR"+chip+sprintf('-%d%d', Sx, Sy);
                    VNAmeasurement(vna, xi, yi, Sprefix)
                    probeUp(MCU)
                    R=1;
                elseif(R==1)
                    linStageFor(MCU)
                    Sprefix = chip+sprintf('-%d%d', Sx, Sy);
                    VNAmeasurement_noise(vna, xi, yi, Sprefix)
                    probeUp(MCU)
                    R=0;
                end
            end
        end
        % measurments done
    end% Sx
end% Sy
if(R==1)
    linStageFor(MCU)
end
probeUp(MCU)
probeUp(MCU)
run('../analysis-code/PlotdataFolder.m')


