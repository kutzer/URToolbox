function q = UR_ikin(urMod,H_t2o,H_t2e)
% UR_IKIN calculates the inverse kinematics for a specified type of
% Univeral Robot manipulator given a desired end-effector or tool pose.
%   q = UR_IKIN(urMod,H_e2o) calculates the inverse kinematics for a
%   specified type of Universal Robot manipulator (specified using urMod)
%   given a desired end-effector pose (assuming no offset between the
%   Universal Robot assigned end-effector frame).
%
%   q = UR_IKIN(urMod,H_t2o,H_t2e) calculates the inverse kinematics for a
%   specified type of Universal Robot manipulator (specified using urMod)
%   given a desired tool pose and known offset between the Universal
%   Robot assigned end-effector frame and the tool frame (specified using
%   H_t2e).
%
%   Specifying the type of Universal Robot manipulator
%        UR3 | urMod = 'UR3' *Not yet implemented
%        UR5 | urMod = 'UR5'
%       UR10 | urMod = 'UR10'
%
%   Solutions are returned as a 6xN array where N defines the total number
%   of possible joint configurations available to produce the desired
%   end-effector or tool pose.
%
%   See also UR_fkin
%
%   References:
%       [1] K.P. Hawkins, "Analytic Inverse Kinematics for the Universal
%           Robots UR-5/UR-10 Arms," Dec. 2013.
%
%   M. Kutzer 30Nov2016, USNA

%% Initialize output
q = [];

%% Check Inputs
if nargin < 3
    H_t2e = eye(4);
end

[bin,msg] = isSE(H_t2o);
if ~bin
    error('UR:notSE','Specified end-effector frame is not valid.\n%s',msg);
end

[bin,msg] = isSE(H_t2e);
if ~bin
    error('UR:notSE','Specified tool offset transformation is not valid.\n%s',msg);
end

%% Debugging parameters
showThetas = false; % set this value to "true" to monitor progress for debugging

%% Specify model of UR
DHtable = UR_DHtable(urMod,100*ones(6,1));

% DHtable = [theta, d, a, alpha];
sgnTheta = sign( DHtable(:,1) );
d        = DHtable(:,2);
a        = DHtable(:,3);
alpha    = DHtable(:,4);

%% Parse DH parameters (for convenience in coding)
sgnTheta0 = sgnTheta(1);
sgnTheta1 = sgnTheta(2);
sgnTheta2 = sgnTheta(3);
sgnTheta3 = sgnTheta(4);
sgnTheta4 = sgnTheta(5);
sgnTheta5 = sgnTheta(6);
sgnTheta6 = sgnTheta(7);

d0 = d(1);
d1 = d(2);
d2 = d(3); % unused
d3 = d(4); % unused
d4 = d(5);
d5 = d(6);
d6 = d(7);

a0 = a(1);
a1 = a(2);
a2 = a(3);
a3 = a(4);
a4 = a(5); % unused
a5 = a(6);
a6 = a(7);

alpha0 = alpha(1);
alpha1 = alpha(2);
alpha2 = alpha(3); % unused
alpha3 = alpha(4); % unused
alpha4 = alpha(5); % unused
alpha5 = alpha(6);
alpha6 = alpha(7);

%% Align frame with report kinematics
% Define any fixed offset relating the UR "World Frame" to the physical
% Base Frame of the robot. Note that this can change based on the UR
% Controller software and parameters.
% - UR10 Controller Default:
%H_w20 = Tz(-399.5);
% - UR Toolbox Default:
H_w20 = eye(4);

H_in = H_t2o; % save original input for solution checking
%H_e2o = H_e2t*Ry(pi)*invSE(H_t2e); % remove end-effector transformation and account from report frame misalignment
H_e2o = H_t2o*invSE(H_t2e);
%H_e2o = invSE(H_w20)*Rz(pi)*H_e2o; % remove offset world frame and account from report frame misalignment
H_e2o = invSE(H_w20)*H_e2o;

%% Calculate \theta_0
theta0 = DHtable(1,1);

%% Calculate \theta_1
x6_hat = H_e2o(1:3,1); % end-effector x-direction
y6_hat = H_e2o(1:3,2); % end-effector y-direction
z6_hat = H_e2o(1:3,3); % end-effector z-direction
p6     = H_e2o(1:3,4); % end-effector position

p5 = p6 + z6_hat*d6; % position of Frame 5

% Note: This assumes p0 is at [0,0,0]
R = sqrt(p5(1)^2 + p5(2)^2); % xy-plane distance from the Base Frame to Frame 5

% Consider special cases
ZERO = 1e-8;
if abs(R) < ZERO
    % Infinite Solutions
    % -> Choose a subset of all possible
    % TODO - improve discrete set of possibilities
    warning('Infinite solutions may exist for theta1.');
    theta1 = 0:(pi/8):(2*pi);
elseif abs(d4) > abs(R)
    % No Soultion Exists
    theta1(1) = NaN;
    theta1(2) = NaN;
    return
else
    % Standard solution set
    if abs( (d4/R) - 1) < ZERO
        % asin(d4/R) =  pi/2
        beta =  pi/2;
    elseif abs( (d4/R) + 1) < ZERO
        % asin(d4/R) = -pi/2
        beta = -pi/2;
    else
        % asin(d4/R)
        beta = asin(d4/R);
    end
    alpha = atan2(p5(2),p5(1));
    theta1(1) = alpha + beta;
    theta1(2) = alpha - beta;
    theta1(3) = alpha + beta + theta0;
    theta1(4) = alpha - beta + theta0;
end

% Repeat solutions for the additional solutions of \theta_1
theta0 = repmat(theta0,1,numel(theta1));

% Show thetas
theta1 = wrapTo2Pi(theta1);
if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:numel(theta1)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(i),theta1(i),Inf,Inf,Inf,Inf,Inf);
    end
    % Plot "R"
    %gca;
    %hold on
    %plot([0,p5(1)],[0,p5(2)],'m');
end

% Remove non-finite solutions
if sum( ~isfinite(theta1) ) < numel(theta1)
    % At least one solution exists
    theta0 = theta0( isfinite(theta1) );
    theta1 = theta1( isfinite(theta1) );
else
    % No solution exists
    % TODO - consider "break"
end

%% Calculate \theta_5
ZERO = 1e-8;
n = numel(theta1);
for i = 1:n
    % Difference along the rotated y-direction
    num = (p6(1)*sin( -(theta0(i)+theta1(i)) ) + p6(2)*cos( -(theta0(i)+theta1(i)) )) - (-d4);
    den = -d6;
    % Solution near 0 and 2*pi
    if abs( (num/den) - 1 ) < ZERO
        theta5(i)   = 0;
        theta5(i+n) = 2*pi;
        % Solution near -pi and pi
    elseif abs( (num/den) + 1) < ZERO
        theta5(i)   = pi;
        theta5(i+n) = -pi;
    else
        if abs(p6(1)) < ZERO && abs(p6(2)) < ZERO
            % SPECIAL CASE: End-effector is directly above the base frame
            if abs(z6_hat(1)) < ZERO && abs(z6_hat(2)) < ZERO && abs(z6_hat(3)-1) < ZERO
                %TODO - there may be other solutions
                theta5(i)   =  pi/2;
                theta5(i+n) = -pi/2; % there may be another solution?
            elseif abs(z6_hat(1)) < ZERO && abs(z6_hat(2)) < ZERO && abs(z6_hat(3)+1) < ZERO
                %TODO - there may be other solutions
                theta5(i)   = -pi/2;
                theta5(i+n) =  pi/2; % there may be another solution?
            else
                % UNKNOWN SOLUTION
                warning('Unknown solution for theta5.')
                theta5(i)   = nan;
                theta5(i+n) = nan;
            end
        elseif abs(num) > abs(den)
            % No Valid Solution for \theta_5
            theta5(i)   = nan;
            theta5(i+n) = nan;
        else
            % Inverse Cosine Solution
            theta5(i)   =  acos( num/den );
            theta5(i+n) = -acos( num/den );
        end
    end
end

% Repeat solutions for the additional solutions of \theta_5
theta0 = repmat(theta0,1,2);
theta1 = repmat(theta1,1,2);

% Show thetas
theta5 = wrapTo2Pi(theta5);
if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:numel(theta1)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(i),theta1(i),Inf,Inf,Inf,theta5(i),Inf);
    end
end

% Remove non-finite solutions
if sum( ~isfinite(theta5) ) < numel(theta5)
    % At least one solution exists
    theta0 = theta0( isfinite(theta5) );
    theta1 = theta1( isfinite(theta5) );
    theta5 = theta5( isfinite(theta5) );
else
    % No solution exists
    % TODO - consider "break"
end

%% Calculate \theta_6
ZERO = 1e-8;
n = numel(theta1);
i = 1;
%for i = 1:n
theta0_all = [];
theta1_all = [];
theta5_all = [];
theta6_all = [];
while i <= n
    % SPECIAL CASE
    if abs(sin(theta5(i))) < ZERO
        % Axes for \theta_2, \theta_3, \theta_4, and \theta_5 are aligned
        % Infinite Solutions
        % -> Choose a subset of all possible
        % TODO - improve discrete set of possibilities
        warning('Infinite solutions exist for theta6.');
        
        theta6_sols = 0:(pi/8):(2*pi);
        n6 = numel(theta6_sols);
        
        theta0_all( (end+1):(end+n6) ) = repmat(theta0(i),1,n6);
        theta1_all( (end+1):(end+n6) ) = repmat(theta1(i),1,n6);
        theta5_all( (end+1):(end+n6) ) = repmat(theta5(i),1,n6);
        theta6_all( (end+1):(end+n6) ) = theta6_sols;
    else
        % Standard solution
        num = -(y6_hat(1)*sin( -(theta0(i)+theta1(i)) ) + y6_hat(2)*cos( -(theta0(i)+theta1(i)) ))/sin(theta5(i));
        den =  (x6_hat(1)*sin( -(theta0(i)+theta1(i)) ) + x6_hat(2)*cos( -(theta0(i)+theta1(i)) ))/sin(theta5(i));
        
        theta6_sols = atan2(num,den);
        n6 = numel(theta6_sols);
        
        theta0_all( (end+1):(end+n6) ) = repmat(theta0(i),1,n6);
        theta1_all( (end+1):(end+n6) ) = repmat(theta1(i),1,n6);
        theta5_all( (end+1):(end+n6) ) = repmat(theta5(i),1,n6);
        theta6_all( (end+1):(end+n6) ) = theta6_sols;
        
        if showThetas
            fprintf('<<----------------------------------------------------->>\n');
            fprintf('theta6(%d) = atan2( %f, %f );\n',i,num,den);
        end
    end
    
    % Increment i
    i = i+1;
end
theta0 = theta0_all;
theta1 = theta1_all;
theta5 = theta5_all;
theta6 = theta6_all;

% Show thetas
theta6 = wrapTo2Pi(theta6);
if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:numel(theta1)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(i),theta1(i),Inf,Inf,Inf,theta5(i),theta6(i));
    end
end

%% Calculate \theta_2, \theta_3, and \theta_4
n = numel(theta1);
for i = 1:n
    % Calculate H2e (H^2_e)
    % -> Shorthand used:
    %       HAB = H^A_B (Frame B relative to Frame A)
    % -> General form:
    %       H_b2a = H^a_b (Frame a relative to Frame b)
    DH_q = UR_DHtable(urMod,[theta1(i); 0; 0; 0; theta5(i); theta6(i)]);
    H01 = DH(DH_q(1,1),DH_q(1,2),DH_q(1,3),DH_q(1,4));
    H12 = DH(DH_q(2,1),DH_q(2,2),DH_q(2,3),DH_q(2,4));
    H02 = H01*H12;
    H2e = invSE(H02)*H_e2o; % End-effector Frame relative to Frame 2
    
    % Calculate H25 (H^2_5) & p25
    H56 = DH(DH_q(6,1),DH_q(6,2),DH_q(6,3),DH_q(6,4));
    H6e = DH(DH_q(7,1),DH_q(7,2),DH_q(7,3),DH_q(7,4));
    H5e = H56*H6e;
    H25 = H2e*invSE(H5e); % Frame 5 relative to Frame 2
    p25 = H25(1:3,4);     % Origin of Frame 5 relative to Frame 2
    
    R(i) = sqrt( p25(1)^2 + p25(2)^2 );
    %(a2^2 + R(i)^2 - a3^2)
    %(2*a2*R(i))
    if R(i) <= a2 + a3 && (a2^2 + R(i)^2 - a3^2) <= (2*a2*R(i))
        % These initial calculations assume that the +z-axis for joint 2, 
        % 3, and 4 are aligned. The step following this calculation 
        % accounts for the possibility of changing the z-direction.
        
        % Calculate \theta_2
        alpha(i) = sgnTheta2*atan2(p25(2),p25(1));
        beta(i) = acos( (a2^2 + R(i)^2 - a3^2)/(2*a2*R(i)) );
        theta2(i)   = alpha(i) + beta(i); % elbow-down solution
        theta2(i+n) = alpha(i) - beta(i); % elbow-up solution
        % Calculate \theta_3
        gamma(i) = acos( (a2^2 + a3^2 - R(i)^2)/(2*a2*a3) );
        theta3(i)   = -(pi-gamma(i)); % elbow-down solution
        theta3(i+n) =  (pi-gamma(i)); % elbow-up solution
        % Calculate \theta_4
        angSum = sgnTheta2*atan2(H25(2,1),H25(1,1));
        theta4(i)   = angSum - theta2(i)   - theta3(i);
        theta4(i+n) = angSum - theta2(i+n) - theta3(i+n);
        
        % Account for possible differences in the +z-axis between joint 2, 
        % 3, and 4.
        if sgnTheta2 ~= sgnTheta3
            theta3(i)   = -theta3(i);
            theta3(i+n) = -theta3(i+n);
        end
        if sgnTheta2 ~= sgnTheta4
            theta4(i)   = -theta4(i);
            theta4(i+n) = -theta4(i+n);
        end
    else
        % No Solution Exists
        theta2(i)   = nan;
        theta2(i+n) = nan;
        theta3(i)   = nan;
        theta3(i+n) = nan;
        theta4(i)   = nan;
        theta4(i+n) = nan;
    end
end

% Repeat solutions for the additional solutions of \theta_2, \theta_3, & \theta_4
theta0 = repmat(theta0,1,2);
theta1 = repmat(theta1,1,2);
theta5 = repmat(theta5,1,2);
theta6 = repmat(theta6,1,2);

%% Show thetas
theta2 = wrapTo2Pi(theta2);
theta3 = wrapTo2Pi(theta3);
theta4 = wrapTo2Pi(theta4);
if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:numel(theta1)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(i),theta1(i),theta2(i),theta3(i),theta4(i),theta5(i),theta6(i));
    end
end


%% Correct angle signs to match the robot
q(1,:) = theta1;
q(2,:) = theta2;
q(3,:) = theta3;
q(4,:) = theta4;
q(5,:) = theta5;
q(6,:) = theta6;
% q(1,:) = sgnTheta(2)*theta1;
% q(2,:) = sgnTheta(3)*theta2;
% q(3,:) = sgnTheta(4)*theta3;
% q(4,:) = sgnTheta(5)*theta4;
% q(5,:) = sgnTheta(6)*theta5;
% q(6,:) = sgnTheta(7)*theta6;

%% Wrap initial set of solutions to 2*pi
q = wrapTo2Pi(q);

if showThetas
    fprintf('\nInitial Number of Solutions: %d\n',size(q,2));
end

% Keep original number of solutions
%q_test = q;

%% Remove redundant solutions
q = unique(transpose(q),'rows');
q = transpose(q);

if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:size(q,2)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(i),q(1,i),q(2,i),q(3,i),q(4,i),q(5,i),q(6,i));
    end
    
    fprintf('\nUnique Number of Solutions [0,2*pi]: %d\n\n',size(q,2));
end

%% Remove incorrect solutions
ZERO = 1e-6;
idx_rmv = [];
n = size(q,2);
for i = 1:n
    % Calculate forward kinematics associated with specified joint
    % configuration
    H_est = UR_fkin(urMod,q(:,i),H_t2e);
    % Compare the forward kinematics pose to the desired input frame
    % TODO - Improve pose comparison
    errH = sum(reshape( abs(H_est-H_in),1,[] ));
    if errH > 12*ZERO || ~isfinite( sum(reshape( abs(H_est-H_in),1,[] )) )
        idx_rmv(end+1) = i;
        
        if showThetas
            fprintf('Removing solution %d, sum( |H_est-H_in| ) = %f\n',i,errH);
            fprintf('H_est-H_in = \n');
            disp( zeroFPError((H_est-H_in),ZERO) );
        end
    end
end
% Remove incorrect solutions
q(:,idx_rmv) = [];

if showThetas
    fprintf('\nUnique, "Correct" Number of Solutions [0,2*pi]: %d\n\n',size(q,2));
end

%% Include -2*pi solutions
for i = 1:size(q,1)
    q_neg = q;
    q_neg(i,:) = bsxfun(@minus,q_neg(i,:),2*pi);
    q = [q,q_neg];
    
    if showThetas
        fprintf('Appended [-2*pi,0] solutions to Theta%d, Number of Solutions = %d\n',i,size(q,2));
    end
end

if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:size(q,2)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(1),q(1,i),q(2,i),q(3,i),q(4,i),q(5,i),q(6,i));
    end
    
    fprintf('\n"Correct" Number of Solutions [-2*pi,2*pi]: %d\n\n',size(q,2));
end

%% Remove redundant solutions
q = unique(transpose(q),'rows');
q = transpose(q);

if showThetas
    fprintf('---------------------------------------------------------\n');
    fprintf('\tTheta0\tTheta1\tTheta2\tTheta3\tTheta4\tTheta5\tTheta6\n');
    for i = 1:size(q,2)
        fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
            theta0(1),q(1,i),q(2,i),q(3,i),q(4,i),q(5,i),q(6,i));
    end
    
    fprintf('\nUnique, "Correct" Number of Solutions [-2*pi,2*pi]: %d\n\n',size(q,2));
end