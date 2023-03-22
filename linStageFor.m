% Sends MCU command to move linear stage forward
function linStageFor(MCU)
    if(MCU.NumBytesAvailable>0)
        read(MCU, MCU.NumBytesAvailable, "char");
    end
    write(MCU, char('f'), "char")
    while(MCU.NumBytesAvailable<1)
        pause(.2)
    end
    read(MCU, MCU.NumBytesAvailable, "char");
end
