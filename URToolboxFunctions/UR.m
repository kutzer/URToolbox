%{
 
MATLAB Class for Python Socket to UR5
written by ENS Kevin Strotz, USN
26JUL16

Use independent Python class for MATLAB to enable native
communications in MATLAB without needing Python proficiency

Consider renaming

%}

% Define class as 'handle' type --> allows properties to update properly
classdef UR < handle
    % Define properties that will be set as part of the object
    properties
        HOST        % Server IP address (on computer) --> generally set to 10.1.1.5
        PORT        % Server port to listen on --> should be 30002
        BACKLOG     % Number of connections to listen to --> should be 2
        CLIENT      % Client (UR manipulators)
        CLIENTADDR  % Client address
        SERVER      % Server socket object --> created during initialization
        MSG         % Message to be sent to UR robot --> input by user
        STATE       % Socket state --> can be OPEN or CLOSE
        URX         % URX connection
        URXADDR     % URX address
        JPOS        % Joint positions
        JVELS       % Joint velocities
        JTORQ       % Joint torques
        JVOLT       % Joint voltages
        JCURR       % Joint currents
        TPOS        % Tool position
        TVEC        % Tool rotation vectors
        TTRANS      % Tool transform
        TINFO       % Tool info
        AIN         % Analog inputs
        AOUT        % Analog outputs
        DIN         % Digital inputs
        DOUT        % Digital outputs
        
    end
    % End properties section
    
    % Define methods to update properties and communicate across the LAN
    methods
        % Initialization function creating class object
        % host = server IP address on computer [10.1.1.5]
        % port = IP port on UR manipulators [30002]
        % backlog = number of connections [2]
        function obj = UR(prevServer)
            global URMod;                           % Global variable for custom Python module
            % IMPORT PYTHON MODULES: DO NOT INCLUDE .py
            addpath('C:\Program Files\MATLAB\R2016a\toolbox\ur');
            URMod = py.importlib.import_module('URServer');
            fprintf('Python module imported.\n');          % Indicate modules imported
            if nargin < 1
                host = input('Enter server IP address: ','s');
                port = input('Enter port: ');
                backlog = input('Enter number of connections to be made: ');
                inputVal{1,1} = host;       % Put host in cell for comparison
                port = int32(port);         % Convert double to integer for Python
                backlog = int32(backlog);   % Convert double to integer for Python
                if iscellstr(inputVal)      % If host is a string
                    obj.HOST = host;        % Set HOST property
                else
                    error('Host must be a string.');    % Raise error if host is not string
                end
                if isnumeric(port)      % If port is a number
                    obj.PORT = port;    % Set PORT property
                else
                    error('Port must be an integer.');  % Raise error if port is not number
                end
                if isnumeric(backlog)   % If backlog is a number
                    obj.BACKLOG = backlog;  % Set BACKLOG property
                else
                    error('Backlog must be an integer.');   % Raise error if backlog is not a number
                end

                addpath('C:\Users\Research\Google Drive\GitHub\UR')  % Add path with modules

                obj.SERVER = URMod.initServer(obj.HOST,obj.PORT,obj.BACKLOG); % Create server socket on computer
                fprintf('Server created.\n')            % Indicate server started
            else
                obj.HOST = prevServer.HOST;
            	obj.PORT = prevServer.PORT;
                obj.BACKLOG = prevServer.BACKLOG;
                obj.SERVER = prevServer.SERVER;
            end    
	    
            fprintf('Begin onboard controller, then press ENTER.') % Press start on manipulators.
            obj.CLIENT = URMod.cnctClient(obj.SERVER);   % Wait for first onboard controller to connect as client
            % obj.CLIENTADDR = char(obj.CLIENT{2}{1});
            obj.CLIENT = obj.CLIENT{1};
            obj.STATE = 'OPEN';             % Set STATE property to indicate connections
            input('');                      % Wait for key press to indicate controllers started
            fprintf('Connections established.\n');  % Indicate clients connected
            
            urxFlag = input('Would you like to create a URX connection as well? ','s');  % Ask if user wants URX connections too
            % Check if user indicates yes
            if (strcmp(urxFlag,'YES') || strcmp(urxFlag,'yes') || strcmp(urxFlag,'Y') || strcmp(urxFlag,'y'))
                obj.URXADDR = input('Enter URX address: ','s');  % Set first URX address property
                obj.URX = URMod.cnctURX(obj.URXADDR);                     % Create first URX connection
                fprintf('URX connection established.\n');         % Indicate URX connection
            else                            % If user does not want URX connections
                fprintf('No URX connections created.');     % Indicate no URX connections
            end
        end  
        
        % Set STATE property
        function obj = set.STATE(obj,state)
            obj.STATE = state;
        end
        % Get STATE property
        function state = get.STATE(obj)
            state = obj.STATE;
        end
        % Set MSG property
        function obj = set.MSG(obj,msg)
            obj.MSG = msg;
        end
        % Get MSG property
        function msg = get.MSG(obj)
            msg = obj.MSG;
        end
        % Set JPOS property
        function obj = set.JPOS(obj,joints)
            obj.JPOS = joints;
        end
        % Get JPOS property
        function joints = get.JPOS(obj)
            global URMod
            obj.JPOS = URMod.getJPos(obj.URX);
            joints = obj.JPOS;
        end
        % Set JVELS property
        function obj = set.JVELS(obj,velocities)
            obj.JVELS = velocities;
        end
        % Get JVELS property
        function vels = get.JVELS(obj)
            global URMod
            obj.JVELS = URMod.getJVels(obj.URX);
            vels = obj.JVELS;
        end
        
        function obj = set.JTORQ(obj,torq)
            obj.JTORQ = torq;
        end
        
        function torq = get.JTORQ(obj)
            global URMod
            obj.JTORQ = URMod.getJTorq(obj.URX);
            torq = obj.JTORQ;
        end
        
        function obj = set.JVOLT(obj,volt)
            obj.JVOLT = volt;
        end
        
        function volt = get.JVOLT(obj)
            global URMod
            obj.JVOLT = URMod.getJVolt(obj.URX);
            volt = obj.JVOLT;
        end
        
        function obj = set.JCURR(obj,curr)
            obj.JCURR = curr;
        end
        
        function curr = get.JCURR(obj)
            global URMod
            obj.JCURR = URMod.getJCurr(obj.URX);
            curr = obj.JCURR;
        end
        
        function obj = set.TPOS(obj,pose)
            obj.TPOS = pose;
        end
        
        function tpose = get.TPOS(obj)
            global URMod
            obj.TPOS = URMod.getTPos(obj.URX);
            tpose = obj.TPOS;
        end
        
        function obj = set.TVEC(obj,tvec)
            obj.TVEC = tvec;
        end
        
        function tvec = get.TVEC(obj)
            global URMod
            obj.TVEC = URMod.getTVec(obj.URX);
            tvec = obj.TVEC;
        end
        
        function obj = set.TTRANS(obj,ttrans)
            obj.TTRANS = ttrans;
        end
        
        function ttrans = get.TTRANS(obj)
            global URMod
            obj.TTRANS = URMod.getTTrans(obj.URX);
            ttrans = obj.TTRANS;
        end
        
        function obj = set.TINFO(obj,tinfo)
            obj.TINFO = tinfo;
        end
        
        function tinfo = get.TINFO(obj)
            global URMod
            obj.TINFO = URMod.getTInfo(obj.URX);
            tinfo = obj.TINFO;
        end
        
        function obj = set.AIN(obj,ain)
            obj.AIN = ain;
        end
        
        function ain = get.AIN(obj)
            global URMod
            obj.AIN = URMod.getAIn(obj.URX);
            ain = obj.AIN;
        end
        
        function obj = set.AOUT(obj,aout)
            obj.AOUT = aout;
        end
        
        function aout = get.AOUT(obj)
            global URMod
            obj.AOUT = URMod.getAOut(obj.URX);
            aout = obj.AOUT;
        end
        
        function obj = set.DIN(obj,din)
            obj.DIN = din;
        end
        
        function din = get.DIN(obj)
            global URMod
            obj.DIN = URMod.getDIn(obj.URX);
            din = obj.DIN;
        end
        
        function obj = set.DOUT(obj,dout)
            obj.DOUT = dout;
        end
        
        function dout = get.DOUT(obj)
            global URMod
            obj.DOUT = URMod.getDOut(obj.URX);
            dout = obj.DOUT;
        end
        
        % Function to send message to the manipulator
        % Two user specified arguments:
        %  message = data string to transmit
        function obj = msg(obj,message)
            global URMod        % Bring URMod to function workspace
            obj.MSG = message;  % Set MSG property to latest message
            URMod.sendmsg(obj.CLIENT,obj.MSG); % Send message to CLIENT
        end
        
        function obj = UpdateAll(obj)
            global URMod
            obj.JPOS = URMod.getJPos(obj.URX);
            obj.JVELS = URMod.getJVels(obj.URX);
            obj.JTORQ = URMod.getJTorq(obj.URX);
            obj.JVOLT = URMod.getJVolt(obj.URX);
            obj.JCURR = URMod.getJCurr(obj.URX);
            obj.TPOS = URMod.getTPos(obj.URX);
            obj.TVEC = URMod.getTVec(obj.URX);
            obj.TTRANS = URMod.getTTrans(obj.URX);
            obj.TINFO = URMod.getTInfo(obj.URX);
            obj.AIN = URMod.getAIn(obj.URX);
            obj.DIN = URMod.getDIn(obj.URX);
            obj.AOUT = URMod.getAOut(obj.URX);
            obj.DOUT = URMod.getDOut(obj.URX);
        end
        
        % Function to close ports at conclusion of operation
        % No user specified arguments
        function obj = clse(obj)
            global URMod            % Bring URMod to function workspace
            % Make sure the user intends to close the connections
            check = input('Are you sure you want to close connections? ','s');
            % If they are sure they want to close
            if (strcmp(check,'YES') || strcmp(check,'yes') || strcmp(check,'Y') || strcmp(check,'y'))
                obj.STATE = 'CLOSED';   % Set STATE property to closed
                URMod.closeSocket(obj.CLIENT);   % Close first client connection
                URMod.closeSocket(obj.SERVER);    % Close server on computer
                URMod.closeURX(obj.URX);
            else                        % If the user wants to keep connections
                fprintf('Maintaining connections.'); % Keep connections open
            end
        end
        
    end
    % End methods section
    
% End class definition
end
