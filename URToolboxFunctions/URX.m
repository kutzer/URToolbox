classdef URX < matlab.mixin.SetGet % Handle
    % URX handle class for accessing functions from the URX Python Library
    %
    %   obj = URX(RobotIP) creates a URX object for interfacing the robot.
    %
    % URX Methods
    %   Initialize
    %   Home
    %   Stow
    %   Zero
    %   Undo
    %   set
    %   get
    %   delete
    %
    % URX Properties
    % -Connection details
    %   RobotIP
    %
    % -Python module and connection properties (hidden)
    %   URServerModule
    %   URXModule
    %   
    % -Universal Robot Model
    %   URmodel     - string argument defining model of Universal Robot
    %
    % -DH Table
    %   DHtable     - nx4 array defining the DH table of the Universal
    %                 Robot
    %
    % -Joint Values
    %   Joints      - 1x6 array containing joint values (radians)
    %   Joint1      - scalar value containing joint 1 (radians)
    %   Joint2      - scalar value containing joint 2 (radians)
    %   Joint3      - scalar value containing joint 3 (radians)
    %   Joint4      - scalar value containing joint 4 (radians)
    %   Joint5      - scalar value containing joint 5 (radians)
    %   Joint6      - scalar value containing joint 6 (radians)
    %
    % -Joint Velocities
    %   JointVelocities - 1x6 array containing joint velocitie (radians/s)
    %
    % -Joint Torques
    %   JointTorques    - 1x6 array containing joint torques (TBD)
    %
    % -End-effector pose
    %   Pose        - 4x4 homogeneous transform representing the
    %                 end-effector pose relative to the world frame
    %
    % -Tool pose
    %   ToolPose    - 4x4 homogeneous transform representing the
    %                 tool pose relative to the world frame
    %
    % -Frame Definitions
    %   Frame0      - Frame 0 (transformation relative to World Frame)
    %   FrameT      - Tool Frame (transformation relative to the
    %                 End-effector Frame)
    
    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private')
        RobotIP
    end
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        URXModule
        URServer
    end
    
    properties(GetAccess='public', SetAccess='private')
        URmodel
        DHtable
    end
    
    properties(GetAccess='public', SetAccess='public')
        Joints              % 1x6 array containing joint values (radians)
        JointVelocities     % 1x6 array containing joint velocitie (radians/s)
        Pose                % End-effector pose relative to the world frame
        ToolPose            % Tool pose relative to the world frame
        Frame0              % Frame 0 (transformation relative to World Frame)
        FrameT              % Tool Frame (transformation relative to the End-effector Frame)
    end
    
    properties(GetAccess='public', SetAccess='private')
        JointTorques
        JointCurrents
        JointVoltages
        AnalogInputs
        AnalogOutputs
        DigitalInputs
        DigitalOutputs
        ToolData
    end
    
    properties(GetAccess='public', SetAccess='public', Hidden=true)
        Joint1              % scalar value containing joint 1 (radians)
        Joint2              % scalar value containing joint 2 (radians)
        Joint3              % scalar value containing joint 3 (radians)
        Joint4              % scalar value containing joint 4 (radians)
        Joint5              % scalar value containing joint 5 (radians)
        Joint6              % scalar value containing joint 6 (radians)
    end
    
    % --------------------------------------------------------------------
    % Internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        Joints_Old	% Previous joint configuration (used with Undo)
        isConnected % Connection status with Universal Robot (URX)
    end
    
    % --------------------------------------------------------------------
    % Constructor/Destructor
    % --------------------------------------------------------------------
    methods(Access='public')
        function obj = URX(robotIP)
            % Create URX Object
            if nargin < 1
                % TODO - Prompt user for IP address
                error('Please specify the Univeral Robot''s IP address.');
            end
            % Initialize connection status
            obj.isConnected = false;
            % Initialize frame offsets
            obj.Frame0 = eye(4);
            obj.FrameT = eye(4);
            % Set the IP
            obj.RobotIP = robotIP;
            % Import URServer module
            fprintf('Importing URServer module...');
            try
                obj.URServer = py.importlib.import_module('URServer');
                fprintf('[IMPORTED]\n');
            catch
                fprintf('[IMPORT FAILED]\n');
                delete(obj);
                error('Failed to import URServer module.');
            end
        end
        
        function delete(obj)
            % Delete function destructor
            if ~isempty(obj.URXModule)
                % Disconnect from URXModule
                if obj.isConnected
                    obj.URServer.closeURX(obj.URXModule);
                end
            end
            % TODO - unload the module 
            %clear classes % Suggested by MATLAB Documentation
            delete(obj);
        end
        
    end % end methods
    
    % --------------------------------------------------------------------
    % Initialization
    % --------------------------------------------------------------------
    methods(Access='public')
        function Initialize(obj)
            % Initialize and establish a connection with the Universal
            % Robot.
            fprintf('Connecting to Universal Robot...');
            try
                obj.URXModule = obj.URServer.cnctURX(obj.RobotIP);
                obj.isConnected = true;
                fprintf('[CONNECTED]\n');
            catch
                fprintf('[CONNECTION FAILED]\n');
                delete(obj);
                error('Failed to connect to Universal Robot.');
            end
        end
        
    end % end methods
    
    % --------------------------------------------------------------------
    % General Use
    % --------------------------------------------------------------------
    methods(Access='public')
        function Home(obj)
            % Move the UR to the home configuration
            % TODO - confirm home position of UR3 and UR5 
            joints = [ 0.00;...
                      -pi/2;...
                       0.00;...
                      -pi/2;...
                       0.00;...
                       0.00];
            obj.Joints = joints;
        end
        
        function Stow(obj)
            % Move the UR to the stow configuration
            % TODO - confirm stow position of UR3 and UR5
            joints = [ 0.00000;...
                      -0.01626;...
                      -2.77643;...
                       1.22148;...
                       1.57080;...
                       0.00000];
            obj.Joints = joints;
        end
        
        function Zero(obj)
            % Move the UR to the zero configuration
            obj.Joints = zeros(6,1);
        end
        
        function Undo(obj)
            % Undo the previous move of the UR
            alljoints = obj.Joints_Old;
            if ~isempty(alljoints)
                obj.Joints = alljoints(:,end);
                alljoints(:,end) = [];
                obj.Joints_Old = alljoints;
            end
        end
         
    end % end methods
    
    % --------------------------------------------------------------------
    % Getters/Setters
    % --------------------------------------------------------------------
    methods
        % GetAccess & SetAccess ------------------------------------------
        % TODO - implement setters
        
        % Joints - 1x6 array containing joint values (radians)
        function joints = get.Joints(obj)
            joints = obj.URServer.getJPos(obj.URXModule);
            joints = pList2mArray(joints);
        end
        %{
        function obj = set.Joints(obj,joints)
            joints = mArray2pList(joints);
            obj.URServer.setJPos(obj.URXModule,joints);
        end
        %}
        % Joint1 - scalar value containing joint 1 (radians)
        function joint1 = get.Joint1(obj)
            joints = obj.Joints;
            joint1 = joints(1);
        end
        %{
        function obj = set.Joint1(obj,joint1)
            joints = obj.Joints;
            joints(1) = joint1;
            obj.Joints = joints;
        end
        %}
        % Joint2 - scalar value containing joint 2 (radians)
        function joint2 = get.Joint2(obj)
            joints = obj.Joints;
            joint2 = joints(2);
        end
        %{
        function obj = set.Joint2(obj,joint2)
            joints = obj.Joints;
            joints(2) = joint2;
            obj.Joints = joints;
        end
        %}
        % Joint3 - scalar value containing joint 3 (radians)
        function joint3 = get.Joint3(obj)
            joints = obj.Joints;
            joint3 = joints(3);
        end
        %{
        function obj = set.Joint3(obj,joint3)
            joints = obj.Joints;
            joints(3) = joint3;
            obj.Joints = joints;
        end
        %}
        % Joint4 - scalar value containing joint 4 (radians)
        function joint4 = get.Joint4(obj)
            joints = obj.Joints;
            joint4 = joints(4);
        end
        %{
        function obj = set.Joint4(obj,joint4)
            joints = obj.Joints;
            joints(4) = joint4;
            obj.Joints = joints;
        end
        %}
        % Joint5 - scalar value containing joint 5 (radians)
        function joint5 = get.Joint5(obj)
            joints = obj.Joints;
            joint5 = joints(5);
        end
        %{
        function obj = set.Joint5(obj,joint5)
            joints = obj.Joints;
            joints(5) = joint5;
            obj.Joints = joints;
        end
        %}
        % Joint6 - scalar value containing joint 6 (radians)
        function joint6 = get.Joint6(obj)
            joints = obj.Joints;
            joint6 = joints(6);
        end
        %{
        function obj = set.Joint6(obj,joint6)
            joints = obj.Joints;
            joints(6) = joint6;
            obj.Joints = joints;
        end
        %}
        % JointVelocities - 1x6 array containing joint velocitie (radians/s)
        function jointVelocities = get.JointVelocities(obj)
            jointVelocities = obj.URServer.getJVels(obj.URXModule);
            jointVelocities = pList2mArray(jointVelocities);
        end
        %{
        function obj = set.JointVelocities(obj,jointVelocities)
            jointVelocities = mArray2pList(jointVelocities);
            obj.URServer.setJVel(obj.URXModule,jointVelocities);
        end
        %}       
        % Pose - 4x4 homogeneous transform representing the
        %        end-effector pose relative to the world frame
        function pose = get.Pose(obj)
            H_o2w = obj.Frame0;
            H_e2o = obj.URServer.getTTrans(obj.URXModule);
            H_e2o = pTransform2mMatrix( H_e2o ); % transformation in meters
            H_e2o(1:3,4) = H_e2o(1:3,4) * 1000;  % transformation in millimeters
            H_e2w = H_o2w * H_e2o;
            pose = H_e2w;
        end
        %{
        function obj = set.Pose(obj,pose)
            H_o2w = obj.Frame0;
            H_e2w = pose;
            H_e2o = invSE(H_o2w) * H_e2w;
            % TODO - CONVERT TO PYTHON TRANSFORMATION
            obj.URServer.setTTrans(obj.URXModule,H_e2o);
        end
        %}
        % ToolPose - 4x4 homogeneous transform representing the  tool pose 
        %            relative to the world frame
        function toolPose = get.ToolPose(obj)
            H_e2w = obj.Pose;
            H_t2e = obj.FrameT;
            H_t2w = H_e2w * H_t2e;
            toolPose = H_t2w;
        end
        %{
        function obj = set.ToolPose(obj,toolPose)
            H_t2w = toolPose;
            H_t2e = obj.FrameT;
            H_e2w = H_t2w * invSE(H_t2e);
            obj.Pose = H_e2w; 
        end
        %}
        % Frame0 - Frame 0 (transformation relative to World Frame)
        function frame0 = get.Frame0(obj)
            frame0 = obj.Frame0;
        end
        
        function obj = set.Frame0(obj,frame0)
            % TODO - check for SE(3)
            obj.Frame0 = frame0;
        end
        
        % FrameT - Tool Frame (transformation relative to the end-effector 
        %          Frame)
        function frameT = get.FrameT(obj)
            frameT = obj.FrameT;
        end
        
        function obj = set.FrameT(obj,frameT)
            % TODO - check for SE(3)
            obj.FrameT = frameT;
        end
        
        % GetAccess ------------------------------------------------------
        
        % JointTorques - 1x6 array containing joint torques (TBD)
        function jointTorques = get.JointTorques(obj)
            jointTorques = obj.URServer.getJTorq(obj.URXModule);
            jointTorques = pList2mArray(jointTorques);
        end
        
        % JointCurrents
        function jointCurrents = get.JointCurrents(obj)
            jointCurrents = obj.URServer.getJCurr(obj.URXModule);
            jointCurrents = pList2mArray(jointCurrents);
        end
        
        % JointVoltages
        function jointVoltages = get.JointVoltages(obj)
            jointVoltages = obj.URServer.getJVolt(obj.URXModule);
            jointVoltages = pList2mArray(jointVoltages);
        end
        
        % AnalogInputs
        function analogInputs = get.AnalogInputs(obj)
            analogInputs = obj.URServer.getAIn(obj.URXModule);
            analogInputs = pList2mArray(analogInputs);
        end
        
        % AnalogOutputs
        function analogOutputs = get.AnalogOutputs(obj)
            analogOutputs = obj.URServer.getAOut(obj.URXModule);
            analogOutputs = pList2mArray(analogOutputs);
        end
        
        % DigitalInputs
        function digitalInputs = get.DigitalInputs(obj)
            digitalInputs = obj.URServer.getDIn(obj.URXModule);
            digitalInputs = pList2mArray(digitalInputs);
        end
        
        % DigitalOutputs
        function digitalOutputs = get.DigitalOutputs(obj)
            digitalOutputs = obj.URServer.getDOut(obj.URXModule);
            digitalOutputs = pList2mArray(digitalOutputs);
        end
        
        % ToolData
        function toolData = get.ToolData(obj)
            toolData = obj.URServer.getTInfo(obj.URXModule);
            toolData = pDict2mStruct(toolData);
            % TODO - convert structured fields to MATLAB format
        end
        
    end % end methods   
end % end classdef
        