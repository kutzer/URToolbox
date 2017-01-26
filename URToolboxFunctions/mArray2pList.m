function pList = mArray2pList(mArray)
% Convert MATLAB array into a Python list
%
% M. Kutzer, 25Aug2017, USNA

%% Check inputs
narginchk(1,1);
% TODO - check input dimensions
mArray = reshape(mArray,1,[]);

%% Convert to Python list
pList = py.list(mArray); 