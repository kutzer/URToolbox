function mArray = pList2mArray(pList)
% PLIST2MARRAY convert Python lists into MATLAB arrays
%
% ENS Kevin Strotz, 22Sept2016, USNA

% Updates
%   25Jan2017 - documentation update (M. Kutzer)

%% Check inputs
narginchk(1,1);
% TODO - check for Python list class

%% Convert to MATLAB array
mCell = cell(pList);
mArray = cell2mat(mCell);
