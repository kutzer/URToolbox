%% SCRIPT_DrawCircle
% This script demonstrates use of the URsim class capabilities with the UR
% class. The URsim object is used to visualize the robot and calculate
% inverse kinematics for the system. Waypoints are executed by getting
% joint angle from the simulation object and sending them to the
% URToolboxScript controller running on the UR control box.
%
%   M. Kutzer, 14Mar2018, USNA

clearvars -EXCEPT ur5 hw5
close all
clc

%% Create hardware flag (for debugging)
% -> Set value to true if you are connected to hardware

useHardware = false;

%% Initialize simulation
% -> This code is written assuming use of the UR5 system. Minor adjustments
% can be made to use it with the UR3 or UR10

if ~exist('ur5')
    % Create object
    ur5 = URsim;
    % Initialize simulation
    ur5.Initialize('UR5');
    % Set a tool frame offset (e.g. for Robotiq end-effector not shown in
    % visualization)
    ur5.FrameT = Tz(160);
    
    % Hide frames
    frames = '0123456E';
    for i = 1:numel(frames)
        hideTriad(ur5.(sprintf('hFrame%s',frames(i))));
    end
end

%% Connect to hardware
% -> The message to the user *assumes* that you have:
%       (1) Properly installed URToolboxScript on the UR controller. See
%       the link below for instructions:
%           https://www.usna.edu/Users/weapsys/kutzer/_Code-Development/UR_Toolbox.php
%
%       (2) Set the network card connecting the PC and UR controller to a
%       static IP of 10.1.1.5
%
%       (3) Set the UR controller IP to 10.1.1.2

if ~exist('hw5') && useHardware
    instruct = sprintf([...
        '\tPython module imported.\n',...
        '\tEnter server IP address: 10.1.1.5\n',...
        '\tEnter port: 30002\n',...
        '\tEnter number of connections to be made: 1\n',...
        '\tServer created.\n',...
        '\tBegin onboard controller, then press ENTER.\n',...
        '\tConnections established.\n',...
        '\tWould you like to create a URX connection as well? y\n',...
        '\tEnter URX address: 10.1.1.2\n',...
        '\tURX connection established.\n']);
    fprintf('PLEASE USE THE FOLLOWING RESPONSES:\n\n');
    fprintf(2,'%s\n\n',instruct)
    
    hw5 = UR;
end

%% Create path
% -> NOTE: This is provided for demonstration only. Perfect execution of
% this path will require infinite accelerations at the initial and final
% waypoints meaning the robot will not track perfectly.

% Define dependent variable
s = linspace(0,1,1000);
% Define circle radius (mm)
r = 100;
% Define position data
X = [];
X(1,:) = r*cos(2*pi*s); % x-position
X(2,:) = r*sin(2*pi*s); % y-position
X(3,:) = 0;             % z-position
X(4,:) = 1;             % Append 1 (homogeneous coordinate)

% Transform coordinates into the workspace of the robot
X = Tz(500)*Rx(pi/2)*Tz(500)*X;

% Plot waypoints
plt_Waypoints = plot3(ur5.Axes,X(1,:),X(2,:),X(3,:),'.m');

%% Animate simulation and move the robot to test
% Home simulation
ur5.Home;
% Move robot to match simulation
if useHardware
    % Get joint position from the simulation
    q = ur5.Joints;
    % Send waypoint to the robot
    % -> Message syntax sends 6 joint positions and 6 joint velocities to
    % define a desired waypoint for the URToolboxScript controller. We are
    % assuming a desired velocity of zero for all joints at each waypoint.
    msg(hw5,sprintf('(%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f)',q,zeros(6,1)));
    % Wait for the robot to finish executing the move
    urWaitForMove(hw5);
end
% Allow plot to update
drawnow

% Move through waypoints
for i = 1:numel(s)
    % Define pose from waypoint
    H_cur = Tx(X(1,i))*Ty(X(2,i))*Tz(X(3,i))*Rx(pi/2);
    
    % Set simulation toolpose to waypoint pose
    ur5.ToolPose = H_cur;
    
    % Move robot to match simulation
    q = ur5.Joints;
    if useHardware
        % Get joint position from the simulation
        q = ur5.Joints;
        % Send waypoint to the robot
        msg(hw5,sprintf('(%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f)',q,zeros(6,1)));
        % Wait for move only on the first waypoint
        if i == 1
            % Wait for the robot to finish executing the move
            urWaitForMove(hw5);
        end
    end
    
    % Allow plot to update
    drawnow;
end
