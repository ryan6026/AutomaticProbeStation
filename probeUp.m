% THis is a function that raieses the probe arm a small amount
% it sends a serial command to the MCU
% very simple
function probeUp(MCU)
  if(MCU.NumBytesAvailable>0)
    dat=read(MCU, MCU.NumBytesAvailable, "char");
  end
  write(MCU, "u", "char")
  while(MCU.NumBytesAvailable<3)
    pause(0.6)
  end
  read(MCU, MCU.NumBytesAvailable, "char");
end
