function mStruct = pDict2mStruct(pDict)
% PDICT2MSTRUCT converts Python dictionary to MATLAB structure.
% Note: This will stay as Python types within the structure if they
% are also lists, tuples, dictionaries, etc
% 
% ENS Kevin Strotz, 22Sept2016, USNA

%% Check inputs
narginchk(1,1);
% TODO - check input class

%% Convert to MATLAB structure
mStruct = struct(pDict);
    
end