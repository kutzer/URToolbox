function H_t2o = UR_fkin(urMod,q,H_t2e)
% UR_FKIN calculates the foward kinematics for a specified type of
% Universal Robot manipulator given a desired joint configuration, an 
% optional tool offset.  
%   H_e2o = UR_FKIN(urMod,q) calculates the end-effector pose (assuming no 
%   offset between the Universal Robot assigned end-effector frame) for a
%   specified type of Universal Robot manipulator (specified using urMod)
%   given a joint configuration.
%
%   H_t2o = UR_FKIN(urMod,q,H_t2e) calculates the tool pose given a known
%   offset between the Universal Robot assigned end-effector frame and the
%   tool frame (specified using H_t2e) for a specified type of Universal 
%   Robot manipulator (specified using urMod) given a joint configuration.
%
%   Specifying the type of Universal Robot manipulator
%        UR3 | urMod = 'UR3' *Not yet implemented
%        UR5 | urMod = 'UR5' 
%       UR10 | urMod = 'UR10'
%
%   M. Kutzer 30Nov2016, USNA

%% Check Inputs
if nargin < 3
    H_t2e = eye(4);
end

[bin,msg] = isSE(H_t2e);
if ~bin
    error('UR:notSE','Specified tool offset transformation is not valid.\n%s',msg);
end

%% Get DH Table
DHtable = UR_DHtable(urMod,q);

%% Calculate forward kinematics
H_e2o = DHtableToFkin(DHtable);
H_t2o = H_e2o*H_t2e;