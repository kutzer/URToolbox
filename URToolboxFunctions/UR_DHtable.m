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
%        UR3 | urMod = 'UR3' *Not yet implemented
%        UR5 | urMod = 'UR5' 
%       UR10 | urMod = 'UR10'
%
%   M. Kutzer 30Nov2016, USNA

%% Check Inputs
if nargin < 2
    q = zeros(6,1);
end

%% Create DH table
DHtable = [];
switch upper(urMod)
    case 'UR3'
        error('UR:noUR3','DH Parameters for the UR3 have yet to be specified.');
    case 'UR5'
        
        theta0 =  pi;
        theta1 =  q(1);
        theta2 = -q(2);
        theta3 = -q(3);
        theta4 = -q(4);
        theta5 =  q(5);
        theta6 = -q(6) + pi;
        
        d0 =  0;
        d1 =  89.20;
        d2 =  0;
        d3 =  0;
        d4 = -109.00;
        d5 =   93.00;
        d6 =  -82.00;
        
        a0 =  0;
        a1 =  0;
        a2 =  425.00;
        a3 =  392.43;
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
        d1 =  128;
        d2 =  0;
        d3 =  0;
        d4 = -163.89;
        d5 =  115.7;
        d6 = -92.2;
        
        a0 =  0;
        a1 =  0;
        a2 =  612.9;
        a3 =  571.6;
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
        