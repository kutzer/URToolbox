function q = UR_ikinLoose(urMod,H_t2o,H_t2e,q_ref,direction)
% UR_IKINLOOSE searches for the closest inverse kinetmatcs solutuion to a
% reference joint configuration allowing a specified body-fixed direction 
% (x, y, or z) to change.
%   q = UR_ikinLoose(urMod,H_t2o,H_t2e,q_ref,direction) searches inverse 
%   kinetmatcs solutuions for a desired allowing a specified body-fixed 
%   direction (x, y, or z) to change. The reference joint configuration is 
%   specified as a 6x1 array of joint angles in radians. The variable 
%   direction is specified as a string indicating the axis {'x','y','z'}. 
%
%   See also UR_ikin
%
%   M. Kutzer 30Nov2016, USNA

%% Check inputs
narginchk(5,5);
% TODO - actually check input values

%% Parse direction
switch lower(direction(1))
    case 'x'
        d = [1,0,0];
    case 'y'
        d = [0,1,0];
    case 'z'
        d = [0,0,1];
    otherwise
        error('The variable direction must be specified as a string indicating the axis {''x'',''y'',''z''}');
end

%% Discritize rotations and calculate inverse kinematics
%n = 720; % 0.5 degree resolution
n = 100;
theta = linspace(0,2*pi,n+1);
theta(end) = []; % Remove redundant value

q = [];
nv = [];
for i = 1:numel(theta)
    H_t2o_i = H_t2o * Rx(d(1)*theta(i)) * Ry(d(2)*theta(i)) * Rz(d(3)*theta(i));
    q_all = UR_ikin(urMod,H_t2o_i,H_t2e);
    if ~isempty(q_all)
        [q_i,~,nv_sort] = findClosestVector(q_all,q_ref);
        q(:,end+1) = q_i;
        nv(end+1)  = nv_sort(1);
    end
end

%% Find closest
if ~isempty(q)
    idx = find(nv == min(nv),1,'first');
    q = q(:,idx);
end