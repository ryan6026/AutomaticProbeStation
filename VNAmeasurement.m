function VNAmeasurement(vna, xi, yi, Sprefix)
norm_sweep=['SENS:FREQ:STAR 135 MHZ;STOP 165 MHZ'];
%take vna tcpclient handle and device ID and trigger vna measurement and
%save to file
nl = 10; % this is the decimal value of a new line character ('\n')

% Set sweep frequency
write(vna, [uint8(norm_sweep), 0x0A]);

% Set VNA trigger to BUS trigger
write(vna, [uint8('TRIG:SOUR BUS'), nl]);
write(vna, [uint8('*OPC?'), nl]); % use *OPC? command to wait for the VNA settings to finish
opc_response = VNAread(vna); % *OPC? response must be read

% Trigger the VNA once
write(vna, [uint8('TRIG:SING'), nl]);
write(vna, [uint8('*OPC?'), nl]); % use *OPC? command to wait for the sweep to finish
opc_response = VNAread(vna);

% Read frequency data into array
write(vna, [uint8('SENSe1:FREQuency:DATA?'), nl]);
f = VNAread(vna);
write(vna, [uint8('*OPC?'), nl]); % use *OPC? command to wait for the sweep to finish
opc_response = VNAread(vna);
f = char(f);
f = str2num(f);

% Read Y data into array
write(vna, [uint8('CALC1:TRAC1:DATA:FDAT?'), nl]);
Y = VNAread(vna);
Y = char(Y);
Y = str2num(Y);
Y = Y(1:2:end); % skip every other element in the array
% for example, if measurement data is in logmag
% format, every other element in the array will be 0

% % Read phase data into array
% write(vna, [uint8('CALC1:TRAC2:DATA:FDAT?'), nl]);
% P = VNAread(vna);
% P = char(P);
% P = str2num(P);
% P = P(1:2:end); % skip every other element in the array
% for example, if measurement data is in logmag
% format, every other element in the array will be 0

figure(2)
clf
plot(f.*1e-6,Y)
fname="data/"+Sprefix+"-c"+sprintf('%dR%d.csv', xi, yi);
% % Save trace data into a csv file
save(fname, 'f', 'Y', '-ascii')
% return to internal trigger
write(vna, [uint8('TRIG:SOUR INT'), nl]);

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