% ClassDef syntax: ClassName
% ClassVar syntax: classVar
% ClassFunc syntax: memberFunction()

% Last Updated: 4-28-2022

% USAGE WARNING: Code will not attempt to communicate with the Thorlabs
% PM100D power meter if the 'PowerMeter.instrumentConnected' variable == 0

classdef PowerMeter < handle
    % This class is used to connect and interface with the Thorlabs PM100D
    % power meter. This class only reads the current power reading from the
    % device.
    
    properties
        port;        % Used to connect to instrument
        currPower;  
    end
    properties (Constant)
        isConnected = 948;          % This unique code is returned when class is initialized.
        instrumentConnected = 1;    %   WARNING: ENSURE THIS VARIABLE IS SET
        disconnectedPower = 0;
    end
    
    methods (Static)
        % val == 0 : a object destroys this class object.   --status
        % val > 0  : a object creates this class.           ++status
        function out = getSetNumConnected(val)
            %status;     % Flag indicates Connection Status
            % Status = {0|Disconnected, status|numObjectsConnected}
            persistent status
            if (isempty(status))
                status = 0;    % Value to indicate the variable has been initialized.
            end
            if (nargin)
                if (val == 0)
                    status = status - 1;
                else
                    status = status + 1;
                end
                if (status < 0)
                    status = 0;
                end
            end
            out = status;
        end 
        
        function out = getSetStatus(val)
            % status == 'isConnected': instrument connected
            % status == 0 || status == []: instrument disconnected
            persistent status
            if (isempty(status))
                status = 0;    % Value to indicate the variable has been initialized.
            end
            if (nargin)
                status = val;
            end
            out = status;
        end 
        
        function result = connect(obj)
            if (PowerMeter.getSetStatus() == 0) % power meter is disconnected.
                status = 0;
                if (PowerMeter.instrumentConnected) % connect the meter.
                    connectionSpecifications = 'USB0::0x1313::0x8078::P0021202::0::INSTR';
                    
                    obj.port = visa("ni", connectionSpecifications);
                    fopen(obj.port); % TODO: Use return code to determine if file actually opened.
                    status = 1;   % Assume file opens correctly. fopen(obj.port) has no outputs.
                end
                if (status ==  -1)  % File Not Open...
                    result = 0;
                else % considered successfully connected if the instrument is disconnected for debugging purposes or connected successfully.
                    result = PowerMeter.isConnected;    % Assume the meter is connected
                end
                PowerMeter.getSetStatus(result); 
            else
                result = PowerMeter.getSetStatus();
            end
        end
        
        function result = disconnect(obj)
            if (PowerMeter.getSetStatus() == PowerMeter.isConnected) % if the power meter is connected.
                if (PowerMeter.instrumentConnected && PowerMeter.getSetNumConnected() == 1)
                    % Close the USB connection to the power meter
                    fclose(obj.port);
                    PowerMeter.getSetStatus(-1); % Power Meter disconnected from all objects.
                end
                PowerMeter.getSetNumConnected(0);   % Decrement # connected
            end
            result = PowerMeter.getSetStatus();
        end
        
    end
    
    methods (Access = public)
        function result = initializeInstrumentVariables(this)
            % Ensure Power Meter is on.
            if (this.getSetStatus() == 0)
                this.start();   % Initialize the instrument.
            end   
            result = this.getSetStatus();   % Return the status of the instrument.
        end
        
        function obj = PowerMeter(wait)     % Constructor function. 
            PowerMeter.getSetNumConnected(1);
            if (nargin == 1 && wait > 0)
               % Do not connect via USB right now.
            else    % We setup the instrument connection here
                PowerMeter.connect(obj);
            end
        end
        
        function powerReading = read(obj)
           if (PowerMeter.getSetStatus() == 0)
               obj.start();
           end
            
            if (PowerMeter.instrumentConnected && PowerMeter.getSetStatus())
                % Reads current power reading on the power meter   
                powerReading = str2double(query(obj.port, 'MEASURE:POWER?'));
            else
                powerReading = PowerMeter.disconnectedPower;
            end
            %{
            List of Possible Read Commands:
            power = str2double(query(obj.port, 'MEASURE:POWER?'))
            current = str2double(query(obj.port, 'MEASURE:CURRENT?'))
            voltage = str2double(query(obj.port, 'MEASURE:VOLTAGE?'))
            energy = str2double(query(obj.port, 'MEASURE:ENERGY?'))
            frequency = str2double(query(obj.port, 'MEASURE:FREQUENCY?'))
            pdensity = str2double(query(obj.port, 'MEASURE:PDENSITY?'))
            edensity = str2double(query(obj.port, 'MEASURE:EDENSITY?'))
            resistance = str2double(query(obj.port, 'MEASURE:RESISTANCE?'))
            temperature = str2double(query(obj.port, 'MEASURE:TEMPERATURE?'))
            %}
        end
        
        % Initialize and connect to Power Meter.
        function result = start(obj)
            result = obj.connect();   % Unique identifier for the Power Meter Class.
        end
        
        function result = run(obj, mode, key)
            %{
            if (nargin == 3)
                Call this desired function immediately.
                obj.callFunction(mode, 10000 + key);
                obj.run();
            else
                Run all functions waiting in the queue.
            end
            %}
            
            % TODO: in the future implement a queue for commands to be
            % ran. 
            result = 1;
        end
        
        % Return valueStored: 'currPower'
        function result = peek(obj)
            result = obj.currPower;
        end
        
        % Obtain current status and update valueStored: 'currPower'
        function result = poke(obj, ~)
            obj.currPower = obj.read();
            result = obj.currPower;
        end
        
        function result = callFunction(obj, mode, key)
            if (nargin > 1)
                switch mode
                    case 0
                        result = obj.read();
                    case 1
                        result = obj.connect();
                    case 90
                        result = obj.close();
                    case 91
                        result = obj.PowerMeter();
                    otherwise
                        result = 0;
                end
            end
        end
        
        % 1: Successfully terminated PowerMeter.end()
        % 0: Un-successfully terminated PowerMeter.end()
        function result = end(obj)
            result = PowerMeter.disconnect();
            if (result) % Meter successfully disconnected.
                delete(obj);
                PowerMeter.getSetNumConnected(0);   % decrement the num connected.
                clear obj;
            end
            result = PowerMeter.getSetStatus();     % 0: PowerMeter Disconnected; non-zero: PowerMeter Connected
        end
    end
end