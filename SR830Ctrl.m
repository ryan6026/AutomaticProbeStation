% A class for communicating with an SR830 Lock-in amplifier using VISA device in Matlab

classdef SR830Ctrl < handle
    properties (Access = public)
        %Initializing the Visa obj within the constructor
        visa;
    end
    methods

        function obj = SR830Ctrl()
          %Establishes connection and opens up commands to the
          % lock-on amplifier, bare in mind that you can switch the port
          % number of the lock-in to fit your settings, in this case I
          % selected 13 as it did not conflict with any of our instruments.
          obj.visa = visa('keysight', 'GPIB1::13::INSTR');
          %Catch mechanism in order to prevent potentially
          % bricking the constructor.
          try
              fopen(obj.visa);
              %Command to forward commands/repsonses to GPIB
              fprintf(obj.visa, "OUTX 1");
          catch ME
              fprintf('SR830.snapshot: Error write or read\n');
              rethrow(ME);

          end
       end
       function output = getDisp(obj, durSec, sampRate)
           % sample rates we've tested that are stable are around 0.001 sec
           %or a sample rate of 1kHz, further tests are needed to determine
           %stability for higher sample rates.
           %output(durSec*sampRate);
           output = zeros(2,sampRate*durSec);
            for i=1:(durSec*sampRate) %The number of iterations for data collection
                fprintf(obj.visa, 'SNAP?10,11');
                %10 and 11 denote the current value on display 1 and 2.
                %See SR830 notes to switch this around, you can retreve up
                %to 6 values at a time, with a minimium of 2 values.
                pause((1/sampRate)) %This parameter can be used to control the sample rate.
                output(:,i) = fscanf(obj.visa,'%f,%f');
            end
       end
       % This section of the functions mainly focuses around the get/set
       %functionality of the internal oscilator and signal generator.
%---------------------------------------------------------------------------------------------
       function setPhase(obj, phaseAngle)
          %Appends the command with the paesed value.
          tempIn = append('PHAS ', phaseAngle);
          % Sends the command to the amp.
          fprintf(obj.visa,tempIn);
       end
       function phaseOut = getPhase(obj)
            %Appends a question mark to query the Amp's current val for
            %Phase
            %Sends the request to the amp.
            fprintf(obj.visa, 'PHAS ?');
            %Retrieves the data
            phaseOut = fscanf(obj.visa, '%f');
            if (ischar(phaseOut))
                phaseOut = str2double();
            end
       end
       function setFreq(obj,freqVal)
           %Appends the command with the paesed value.
           tempIn = append('FREQ ', freqVal);
           %Sends the command to the amp.
           fprintf(obj.visa, tempIn);
       end
       function freqOut = getFreq(obj)
           %Appends the frequency command with the query tag.
           tempIn = append('FREQ ','?');
           %Communicates with the amp to return the value.
           (fprintf(obj.visa, tempIn));
           freqOut = fscanf(obj.visa, '%f');
       end
       function setHarm(obj, harmVal)
           %Appends the command with the paesed value.
           %Bare in mind the harmonic integer(1=<i=<19999, i*f =< 102kHz
           %Converts this to a string
           strHarmVal = num2str(harmVal);
           %Appends with the command.
           tempIn = append('HARM ', strHarmVal);
           %Communicates the command to the amp.
           fprintf(obj.visa, tempIn);
       end
       function harmOut = getHarm(obj)
           %Appends the harmonic control with the query tag.
           tempIn = append('HARM ', '?');
           fprintf(obj.visa, tempIn);
           %Gets the output of the current harmonics
           harmOut = fscanf(obj.visa, '%f');
           if (ischar(harmOut))
                harmOut = str2double();
            end
       end
       function ampOut = getAmp(obj)
           %Appends the control command for amplitude with the query tag.
           tempIn = append('SLVL ', '?');
           %Sends the command to the amplifier
           fprintf(obj.visa, tempIn);
           ampOut = fscanf(obj.visa, '%f');
           if (ischar(ampOut))
                ampOut = str2double();
            end
       end
       function setAmp(obj,ampVal)
           %Appends the command with the paesed value.
           tempIn = append('SLVL ', ampVal);
           %Communicates the data to the amplifier
           fprintf(obj.visa, tempIn);
       end
       function setImp(obj,selVal)
          %0 for zero resistance, 2 for 1MOhm, and 3 for 100MOhm
          %Takes the value and appends the command with it.
          tempIn = append('ISRC ', selVal);
          %Sends data to the amp.
          fprintf(obj.visa, tempIn);
       end
       function impedanceOut = getImp(obj)
           %Gets the current input impedance
           tempIn = append('ISRC ', '?');
           %Query's the amplifier for the current input impedance
           fprintf(obj.visa, tempIn);
           impedanceOut = fscanf(obj.visa, '%f');
           if (ischar(impedanceOut))
                impedanceOut = str2double();
            end
       end
       % Functions to operate the buffer.
       %This is incomplete and overall working with the buffer is very
       %unreliable overall and should be avoided, use the getDisp()
       %function instead for getting values from the display.
       function buffClear(obj)
           %sends command to clear the buffer.
           fprintf(obj.visa, 'REST');
       end

       function buffPause(obj)
           %sends command to pause the buffer.
           fprintf(obj.visa, 'PAUS');
       end

       function buffStart(obj)
           %sends command to start the buffer.
           fprintf(obj.visa, 'STRT');
       end

    end
end
