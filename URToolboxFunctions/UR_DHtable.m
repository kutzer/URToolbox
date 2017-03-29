function DHtable = UR_DHtable(urMod,q)
% UR_DHTABLE creates a DH table for a specified type of Univeral Robot
% manipulator.
%   DHtable = UR_DHTABLE(urMod) creates a DH table for a specified type of
%   Universal Robot Manipulator (specified using urMod) assuming all joints
%   are set to zero.
%
%   DHtable = UR_DHTABLE(urMod,q) creates a DH table for a specified type 
%   of Universal Robot Manipulator (specified using urMod) for a given 
%   joint configuration, q.
%
%   Specifying the type of Universal Robot manipulator
%        UR3 | urMod = 'UR3'
%        UR5 | urMod = 'UR5' 
%       UR10 | urMod = 'UR10'
%
%   NOTE: The "d" and "a" parameters match those published in [1], the
%         remainder of the DH Table provided in this function is modified 
%         with signs and offsets to produce forward kinematics matching
%         those of the robot.
%
%   References:
%       [1] "Actual center of mass for robot - 17264," 
%           https://www.universal-robots.com/how-tos-and-faqs/faq/ur-faq/...
%           actual-center-of-mass-for-robot-17264, Accessed Mar. 2017.
%
%   M. Kutzer 30Nov2016, USNA

% Updates:
%   29Mar2017 - Updated DH parameters to match published values.

%% Check Inputs
if nargin < 2
    q = zeros(6,1);
end

%% Create DH table
DHtable = [];
switch upper(urMod)
    case 'UR3'
        
        theta0 =  pi;
        theta1 =  q(1);
        theta2 = -q(2);
        theta3 = -q(3);
        theta4 = -q(4);
        theta5 =  q(5);
        theta6 = -q(6) + pi;
        
        d0 =  0;
        d1 =  151.90;
        d2 =  0;
        d3 =  0;
        d4 = -112.35;
        d5 =  85.35;
        d6 = -81.90;
        
        a0 =  0;
        a1 =  0;
        a2 =  243.65;
        a3 =  213.25;
        a4 =  0;
        a5 =  0;
        a6 =  0;
        
        alpha0 =  0;
        alpha1 =  pi/2;
        alpha2 =  0;
        alpha3 =  0;
        alpha4 =  pi/2;
        alpha5 = -pi/2;
        alpha6 =  pi;
        
    case 'UR5'
        
        theta0 =  pi;
        theta1 =  q(1);
        theta2 = -q(2);
        theta3 = -q(3);
        theta4 = -q(4);
        theta5 =  q(5);
        theta6 = -q(6) + pi;
        
        d0 =  0;
        % d1 =  89.20; % Derived from STEP files provided by UR
        d1 =  89.459;
        d2 =  0;
        d3 =  0;
        % d4 = -109.00; % Derived from STEP files provided by UR
        d4 = -109.15;
        % d5 =   93.00; % Derived from STEP files provided by UR
        d5 =  94.65;
        % d6 =  -82.00; % Derived from STEP files provided by UR
        d6 = -82.30;
        
        a0 =  0;
        a1 =  0;
        % a2 =  425.00; % Derived from STEP files provided by UR
        a2 =  425.00;
        % a3 =  392.43; % Derived from STEP files provided by UR
        a3 =  392.25;
        a4 =  0;
        a5 =  0;
        a6 =  0;
        
        alpha0 =  0;
        alpha1 =  pi/2;
        alpha2 =  0;
        alpha3 =  0;
        alpha4 =  pi/2;
        alpha5 = -pi/2;
        alpha6 =  pi;
        
    case 'UR10'
        
        theta0 =  pi;
        theta1 =  q(1);
        theta2 = -q(2);
        theta3 = -q(3);
        theta4 = -q(4);
        theta5 =  q(5);
        theta6 = -q(6) + pi;
        
        d0 =  0;
        % d1 =  128.00;
        d1 = 127.30;
        d2 =  0;
        d3 =  0;
        % d4 = -163.89; % Derived from STEP files provided by UR
        d4 = -163.941;
        % d5 =  115.70; % Derived from STEP files provided by UR
        d5 = 115.70;
        %d6 = -92.20; % Derived from STEP files provided by UR
        d6 = -92.20;
        
        a0 =  0;
        a1 =  0;
        % a2 =  612.9; % Derived from STEP files provided by UR
        a2 = 612.00;
        % a3 =  571.6; % Derived from STEP files provided by UR
        a3 = 572.30;
        a4 =  0;
        a5 =  0;
        a6 =  0;
        
        alpha0 =  0;
        alpha1 =  pi/2;
        alpha2 =  0;
        alpha3 =  0;
        alpha4 =  pi/2;
        alpha5 = -pi/2;
        alpha6 =  pi;
        
    otherwise
        error('UR:BadModel','"%s" is not a recognized type of Universal Robot.',urMod);
end
DHtable = [theta0,d0,a0,alpha0;...
           theta1,d1,a1,alpha1;...
           theta2,d2,a2,alpha2;...
           theta3,d3,a3,alpha3;...
           theta4,d4,a4,alpha4;...
           theta5,d5,a5,alpha5;...
           theta6,d6,a6,alpha6];
        