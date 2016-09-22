function URToolboxUpdate
% URTOOLBOXUPDATE download and update the UR Toolbox. 
%
%   M. Kutzer 27Feb2016, USNA

% TODO - Find a location for "URToolbox Example SCRIPTS"
% TODO - update function for general operation

% Install UR Toolbox
ToolboxUpdate('UR');

updateModule = py.importlib.import_module('URModulesUpdate');

fprintf('Updating Python modules...');
updateModule.updateURModules();
fprintf('[Complete]\n');

end

function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
A = ToolboxVer;

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
end

%% Check for successful download
if ~confirm
    error('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install ScorBot Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
