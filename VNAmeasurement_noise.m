function VNAmeasurement_noise(vna, xi, yi, Sprefix)
% will only save CW measurement
noise_bool=1;
norm_sweep=['SENS:FREQ:STAR 135 MHZ;STOP 165 MHZ'];
%     return to normal sweep
write(vna, [uint8(norm_sweep), 0x0A], "char");
%take vna tcpclient handle and device ID and trigger vna measurement and
%save to file
% 0x0A % this is the decimal value of a new line character ('\n')

% Set VNA trigger to BUS trigger
write(vna, [uint8('TRIG:SOUR BUS'), 0x0A]);
write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the VNA settings to finish
opc_response = VNAread(vna); % *OPC? response must be read

% Trigger the VNA once
write(vna, [uint8('TRIG:SING'), 0x0A]);
write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the sweep to finish
opc_response = VNAread(vna);

% Read frequency data into array
write(vna, [uint8('SENSe1:FREQuency:DATA?'), 0x0A]);
f = VNAread(vna);
write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the sweep to finish
opc_response = VNAread(vna);
f = char(f);
f = str2num(f);

% Read measurement data into array
write(vna, [uint8('CALC1:DATA:FDAT?'), 0x0A]);
data = VNAread(vna);
data = char(data);
data = str2num(data);
data = data(1:2:end); % skip every other element in the array
% for example, if measurement data is in logmag
% format, every other element in the array will be 0

fname="data/"+Sprefix+"-c"+sprintf('%dR%d.csv', xi, yi)
try
save(fname, 'f', 'data', '-ascii')
catch
mkdir data
save(fname, 'f', 'data', '-ascii')
end
if(and((noise_bool==1),( max(data)-min(data)>12)))  % got noise?

%     "NOISE TIME"
    Y=data;
    fmaxI = find(max(Y)==Y);
    fminI = find(min(Y)==Y);
    fmax = f(fmaxI);
    fmin = f(fminI);
    %     get gradient between max and min
    try
        sdata=smoothdata(gradient(Y(fmaxI:fminI)),'gaussian',48)./(f(2)-f(1));
        if(length(sdata)<50)
            return;
        else
            figure(1)
            clf
            plotyy(1e-6.*f(fmaxI:fminI), sdata, 1e-6.*f(fmaxI-500:fminI+500), Y(fmaxI-500:fminI+500))
            title("Admittance and Gradient")
            xlabel("Frequency [MHz]")
            ylabel("Admittance dBS/ derivative dBS/Hz")
            %     plot gradient, find first local min and show on graph
            tmp=find(islocalmin(sdata));
            tmp=tmp(1);
            fslope=f(fmaxI+tmp);
            hold on
            line(1e-6.*fslope.*[1,1], [1.5.*max(sdata), 1.5.*min(sdata)])

            %     Set VNA to CW at fslope and wait for ACK
            write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the sweep to finish
            opc_response = VNAread(vna);
            write(vna, uint8(['SENS:FREQ:STAR ', num2str(fslope), ';STOP ', num2str(fslope), 0x0A]));
            % Trigger the VNA once
            write(vna, [uint8('TRIG:SING'), 0x0A]);
            write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the sweep to finish
            opc_response = VNAread(vna);

            % Read frequency data into array
            write(vna, [uint8('SENSe1:FREQuency:DATA?'), 0x0A]);
            f = VNAread(vna);
            write(vna, [uint8('*OPC?'), 0x0A]); % use *OPC? command to wait for the sweep to finish
            opc_response = VNAread(vna);
            f = char(f);
            f = str2num(f);

            % Read measurement data into array
            write(vna, [uint8('CALC1:DATA:FDAT?'), 0x0A]);
            data = VNAread(vna);
            data = char(data);
            data = str2num(data);
            data = data(1:2:end); % skip every other element in the array
            % for example, if measurement data is in logmag
            % format, every other element in the array will be 0
            
            % % Save trace data into a csv file
            fname="data/"+Sprefix+"-c"+sprintf('%dR%d-noise.csv', xi, yi)
            save(fname, 'f', 'data', '-ascii')
%             hist(data)
        end
    end
    
else
%     "NO NOISE"
end
%     return to normal sweep
write(vna, [uint8(norm_sweep), 0x0A]);
% return to internal trigger
write(vna, [uint8('TRIG:SOUR INT'), 0x0A]);

end

function query_response = VNAread(app_vna)
query_response = '';
while true
    partial_query_response = read(app_vna);
    if(isempty(partial_query_response)~=1)
        last_index = length(partial_query_response);
        query_response = strcat(query_response, partial_query_response);
        if (partial_query_response(last_index) == 10) % 10 is newline
            break;
        end
    end
end
end