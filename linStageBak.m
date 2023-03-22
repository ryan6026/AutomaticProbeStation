% Sends the command to the MCU to backup stage
function linStageBak(MCU)
    if(MCU.NumBytesAvailable>0)
        read(stage, stage.NumBytesAvailable, "char");
    end
    write(MCU, char('b'), "char")
    while(MCU.NumBytesAvailable<1)
        pause(.2)
    end
    read(MCU, MCU.NumBytesAvailable, "char");
end
