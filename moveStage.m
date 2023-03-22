 % A function to move the ASI imaging stage
 % It only returns once the stage has reached its destination
 % input units are mm,UC DAVIS ASI stage has 1e4 / cm most of the time...
function moveStage(stage, x, y) % in mm
    if(stage.NumBytesAvailable>0)
        read(stage, stage.NumBytesAvailable, "char");
    end
    write(stage, "M X="+int2str(x*1e4)+"Y="+int2str(y*1e4)+char(0x0d), "char")
    while(stage.NumBytesAvailable<2)
        pause(.1)
    end
    read(stage, stage.NumBytesAvailable, "char");
    write(stage, "W X"+char(0x0d), "char")
    while(stage.NumBytesAvailable<5)
        pause(.2)
    end
    data=read(stage, stage.NumBytesAvailable, "char");
    xp=str2double(data(4:length(data)))/1e4;
    write(stage, "W Y"+char(0x0d), "char")
    while(stage.NumBytesAvailable<5)
        pause(.2)
    end
    data=read(stage, stage.NumBytesAvailable, "char");
    yp=str2double(data(4:length(data)))/1e4;
    while( or(abs(xp-x)>0.5, abs(yp-y)>0.5) )
        write(stage, "W X"+char(0x0d), "char")
        while(stage.NumBytesAvailable<5)
            pause(.2)
        end
        data=read(stage, stage.NumBytesAvailable, "char");
        xp=str2double(data(4:length(data)))/1e4;
        write(stage, "W Y"+char(0x0d), "char")
        while(stage.NumBytesAvailable<5)
            pause(.2)
        end
        data=read(stage, stage.NumBytesAvailable, "char");
        yp=str2double(data(4:length(data)))/1e4;
    end
end
