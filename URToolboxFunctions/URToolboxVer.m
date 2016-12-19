function varargout = URToolboxVer
% URTOOLBOXVER display the OptiTrack Toolbox information.
%   URTOOLBOXVER displays the information to the command prompt.
%
%   A = URTOOLBOXVER returns in A the sorted struct array of version 
%   information for the OptiTrack Toolbox.
%     The definition of struct A is:
%             A.Name      : toolbox name
%             A.Version   : toolbox version number
%             A.Release   : toolbox release string
%             A.Date      : toolbox release date
%
%   M. Kutzer 17Feb2016, USNA

% Updates
%   10Mar2016 - Updates to plotRigidBody documentation and visualization
%               script.
%   10Mar2016 - Corrected plot error in example script and added error
%               check for not-tracked issue in plotRigidBody
%   10Mar2016 - Updated error checking in plotRigidBody and example updates
%   19Dec2016 - Added simulation and support components

A.Name = 'UR Toolbox';
A.Version = '1.1.0';
A.Release = '(R2016a)';
A.Date = '19-Dec-2016';
A.URLVer = 1;

msg{1} = sprintf('MATLAB %s Version: %s %s',A.Name, A.Version, A.Release);
msg{2} = sprintf('Release Date: %s',A.Date);

n = 0;
for i = 1:numel(msg)
    n = max( [n,numel(msg{i})] );
end

fprintf('%s\n',repmat('-',1,n));
for i = 1:numel(msg)
    fprintf('%s\n',msg{i});
end
fprintf('%s\n',repmat('-',1,n));

if nargout == 1
    varargout{1} = A;
end