function installURToolbox(replaceExisting)
% INSTALLURTOOLBOX installs UR Toolbox for MATLAB.
%   INSTALLURTOOLBOX installs UR Toolbox into the following 
%   locations:
%                        Source: Destination
%     URToolboxFunctions: matlabroot\toolbox\ur
%       URToolboxSupport: matlabroot\toolbox\ur\OptiTrackToolboxSupport 
%
%   INSTALLURTOOLBOX(true) installs UR Toolbox regardless of
%   whether a copy of the UR toolbox exists in the MATLAB root.
%
%   INSTALLURTOOLBOX(false) installs UR Toolbox only if no copy 
%   of the UR toolbox exists in the MATLAB root.
%
%   M. Kutzer 17Feb2016, USNA

% Updates
%   19Dec2016 - Added genpath to include all simulation components in the
%               path.
%   15Mar2018 - Updated to include try/catch for required toolbox
%               installations and include msgbox warning when download 
%               fails.

% TODO - Allow users to create a local version if admin rights are not
% possible.

%% Install/Update required toolboxes
ToolboxUpdate('Transformation');
ToolboxUpdate('Plotting');

%% Assign tool/toolbox specific parameters
dirName = 'ur';

%% Check inputs
if nargin == 0
    replaceExisting = [];
end

%% Installation error solution(s)
adminSolution = sprintf(...
    ['Possible solution:\n',...
     '\t(1) Close current instance of MATLAB\n',...
     '\t(2) Open a new instance of MATLAB "as administrator"\n',...
     '\t\t(a) Locate MATLAB shortcut\n',...
     '\t\t(b) Right click\n',...
     '\t\t(c) Select "Run as administrator"\n']);

%% Check for toolbox directory
toolboxRoot  = fullfile(matlabroot,'toolbox',dirName);
isToolbox = exist(toolboxRoot,'file');
if isToolbox == 7
    % Apply replaceExisting argument
    if isempty(replaceExisting)
        choice = questdlg(sprintf(...
            ['MATLAB Root already contains the UR Toolbox.\n',...
            'Would you like to replace the existing toolbox?']),...
            'Yes','No');
    elseif replaceExisting
        choice = 'Yes';
    else
        choice = 'No';
    end
    % Replace existing or cancel installation
    switch choice
        case 'Yes'
            rmpath(toolboxRoot);
            [isRemoved, msg, msgID] = rmdir(toolboxRoot,'s');
            if isRemoved
                fprintf('Previous version of UR Toolbox removed successfully.\n');
            else
                fprintf('Failed to remove old UR Toolbox folder:\n\t"%s"\n',toolboxRoot);
                fprintf(adminSolution);
                error(msgID,msg);
            end
        case 'No'
            fprintf('UR Toolbox currently exists, installation cancelled.\n');
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Create Toolbox Path
[isDir,msg,msgID] = mkdir(toolboxRoot);
if isDir
    fprintf('UR toolbox folder created successfully:\n\t"%s"\n',toolboxRoot);
else
    fprintf('Failed to create UR Toolbox folder:\n\t"%s"\n',toolboxRoot);
    fprintf(adminSolution);
    error(msgID,msg);
end

%% Migrate toolbox folder contents
toolboxContent = 'URToolboxFunctions';
if ~isdir(toolboxContent)
    error(sprintf(...
        ['Change your working directory to the location of "installURToolbox.m".\n',...
         '\n',...
         'If this problem persists:\n',...
         '\t(1) Unzip your original download of "URToolbox" into a new directory\n',...
         '\t(2) Open a new instance of MATLAB "as administrator"\n',...
         '\t\t(a) Locate MATLAB shortcut\n',...
         '\t\t(b) Right click\n',...
         '\t\t(c) Select "Run as administrator"\n',...
         '\t(3) Change your "working directory" to the location of "installURToolbox.m"\n',...
         '\t(4) Enter "installURToolbox" (without quotes) into the command window\n',...
         '\t(5) Press Enter.']));
end
files = dir(toolboxContent);
wb = waitbar(0,'Copying UR Toolbox toolbox contents...');
n = numel(files);
fprintf('Copying UR Toolbox contents:\n');
for i = 1:n
    % source file location
    source = fullfile(toolboxContent,files(i).name);
    % destination location
    destination = toolboxRoot;
    if files(i).isdir
        switch files(i).name
            case '.'
                %Ignore
            case '..'
                %Ignore
            otherwise
                fprintf('\t%s...',files(i).name);
                nDestination = fullfile(destination,files(i).name);
                [isDir,msg,msgID] = mkdir(nDestination);
                if isDir
                    [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                    if isCopy
                        fprintf('[Complete]\n');
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
        end
    else
        fprintf('\t%s...',files(i).name);
        [isCopy,msg,msgID] = copyfile(source,destination,'f');
        
        if isCopy == 1
            fprintf('[Complete]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    waitbar(i/n,wb);
end
set(wb,'Visible','off');

%% Migrate toolbox support folder
% TODO - search for python directory and prompt user to find the correct
% one...
if exist('C:\Python34\Lib','dir') ~= 7
    % Python 3.4 is not installed in the standard directory
    fprintf(2,'Python 3.4.4 was not found in the standard directory.');
    pythonRoot = uigetdir('', 'Select Python 3.4.4 "Lib" directory.');
else
    pythonRoot = fullfile('C:\Python34\Lib');
end

toolboxContent = 'URToolboxSupport';
if ~isdir(toolboxContent)
    error(sprintf(...
        ['Change your working directory to the location of "installURToolbox.m".\n',...
         '\n',...
         'If this problem persists:\n',...
         '\t(1) Unzip your original download of "URToolbox" into a new directory\n',...
         '\t(2) Open a new instance of MATLAB "as administrator"\n',...
         '\t\t(a) Locate MATLAB shortcut\n',...
         '\t\t(b) Right click\n',...
         '\t\t(c) Select "Run as administrator"\n',...
         '\t(3) Change your "working directory" to the location of "installURToolbox.m"\n',...
         '\t(4) Enter "installURToolbox" (without quotes) into the command window\n',...
         '\t(5) Press Enter.']));
end
files = dir(toolboxContent);
wb = waitbar(0,'Copying UR Toolbox toolbox contents...');
n = numel(files);
fprintf('Copying UR Toolbox contents:\n');
for i = 1:n
    % source file location
    source = fullfile(toolboxContent,files(i).name);
    % destination location
    destination = pythonRoot;
    if files(i).isdir
        switch files(i).name
            case '.'
                %Ignore
            case '..'
                %Ignore
            otherwise
                fprintf('\t%s...',files(i).name);
                nDestination = fullfile(destination,files(i).name);
                [isDir,msg,msgID] = mkdir(nDestination);
                if isDir
                    [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                    if isCopy
                        fprintf('[Complete]\n');
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
        end
    else
        fprintf('\t%s...',files(i).name);
        if all( destination == 0 )
            % Ignore cancelled operation...
            isCopy = false;
        else
            [isCopy,msg,msgID] = copyfile(source,destination,'f');
        end
        
        if isCopy == 1
            fprintf('[Complete]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    waitbar(i/n,wb);
end
set(wb,'Visible','off');

%% Save toolbox path
addpath(genpath(toolboxRoot),'-end');
%addpath(toolboxRoot,'-end');
savepath;

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');

%% Install Python Modules
% TODO - error check!
fprintf('Installing necessary Python modules...');
try
    installModule = py.importlib.import_module('URModulesInstall');
    installModule.installURModules();
    fprintf('[Complete]\n');
catch
    fprintf('[Failed]\n')
    fprintf(2,'Failed to install necessary Python modules. To install manually:\n')
    fprintf(2,'\t - Open the Command Prompt,\n');
    fprintf(2,'\t - Switch to the Python 3.4 Scripts directory\n');
    fprintf(2,'\t\t run "cd C:\\Python34\\Scripts"\n');
    fprintf(2,'\t - Install the math3D module\n');
    fprintf(2,'\t\t run "pip install math3d"\n');
    fprintf(2,'\t - Install the numpy module\n');
    fprintf(2,'\t\t run "pip install numpy"\n');
    fprintf(2,'\t - Install the urx module\n');
    fprintf(2,'\t\t run "pip install urx"\n');
end
    
end

function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    % Original download/unzip method using "unzip"
    fnames = unzip(url,pname);
    
    fprintf('SUCCESS\n');
    confirm = true;
catch
    try
        % Alternative download method using "urlwrite"
        % - This method is flagged as not recommended in the MATLAB
        % documentation.
        % TODO - Consider an alternative to urlwrite.
        tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
        urlwrite(url,fullfile(pname,tmpFname));
        fnames = unzip(fullfile(pname,tmpFname),pname);
        delete(fullfile(pname,tmpFname));
        
        fprintf('SUCCESS\n');
        confirm = true;
    catch
        fprintf('FAILED\n');
        confirm = false;
    end
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    sprintf('\n'),...
    sprintf('%s\n',url),...
    sprintf('\n'),...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%sToolbox"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%sToolbox.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%sToolbox" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
    
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s Toolbox',toolboxName),'warn');
    return
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