classdef URsim < matlab.mixin.SetGet % Handle
    % URsim handle class for creating a designated UR
    % simulation/visualization
    %
    %   obj = URsim creates a simulation object for a specific UR
    %
    % URsim Methods
    %   Initialize  - Initialize the URsim object.
    %   Home        - Move URsim to home joint configuration.
    %   Stow        - Move URsim to stow joint configuration.
    %   Zero        - Move URsim to zero joint configuration.
    %   Undo        - Return URsim to previous joint configuration.
    %   get         - Query properties of the URsim object.
    %   set         - Update properties of the URsim object.
    %   delete      - Delete the URsim object and all attributes.
    %
    % URsim Properties
    % -Figure and Axes
    %   Figure      - figure containing simulation axes
    %   Axes        - axes containing simulation
    %
    % -Universal Robot Model
    %   URmodel     - string argument defining model of Universal Robot
    %
    % -DH Table
    %   DHtable     - nx4 array defining the DH table of the Universal
    %                 Robot
    %
    % -Joint Values
    %   Joints      - 1x6 array containing joint values (radians)
    %   Joint1      - scalar value containing joint 1 (radians)
    %   Joint2      - scalar value containing joint 2 (radians)
    %   Joint3      - scalar value containing joint 3 (radians)
    %   Joint4      - scalar value containing joint 4 (radians)
    %   Joint5      - scalar value containing joint 5 (radians)
    %   Joint6      - scalar value containing joint 6 (radians)
    %
    % -End-effector pose
    %   Pose        - 4x4 rigid body transform defining the end-effector
    %                 pose relative to the world frame (linear units are
    %                 defined in millimeters)
    %
    % -Tool pose
    %   ToolPose    - 4x4 rigid body transform defining the tool pose
    %                 relative to the world frame (linear units are defined
    %                 in millimeters)
    %
    % -Frame Definitions
    %   Frame0      - Frame 0 (transformation relative to World Frame)
    %   Frame1      - Frame 1 (transformation relative to Frame 0)
    %   Frame2      - Frame 2 (transformation relative to Frame 1)
    %   Frame3      - Frame 3 (transformation relative to Frame 2)
    %   Frame4      - Frame 4 (transformation relative to Frame 3)
    %   Frame5      - Frame 5 (transformation relative to Frame 4)
    %   Frame6      - Frame 6 (transformation relative to Frame 5)
    %   FrameE      - End-effector Frame (transformation relative to
    %                 Frame 6)
    %   FrameT      - Tool Frame (transformation relative to the
    %                 End-effector Frame)
    %
    % -Frame Handles (hidden)
    %   hFrame0     - hgtransform object for Frame 0
    %   hFrame1     - hgtransform object for Frame 1
    %   hFrame2     - hgtransform object for Frame 2
    %   hFrame3     - hgtransform object for Frame 3
    %   hFrame4     - hgtransform object for Frame 4
    %   hFrame5     - hgtransform object for Frame 5
    %   hFrame6     - hgtransform object for Frame 6
    %   hFrameE     - hgtransform object for the End-Effector Frame
    %   hFrameT     - hgtransform object for the Tool Frame
    %
    % -Joint Handles (hidden)
    %   hJoint1     - hgtransform object for Joint 1,
    %                 Rz(theta1) relative to Frame 0
    %   hJoint2     - hgtransform object for Joint 2,
    %                 Rz(theta2) relative to Frame 1
    %   hJoint3     - hgtransform object for Joint 3,
    %                 Rz(theta3) relative to Frame 2
    %   hJoint4     - hgtransform object for Joint 4,
    %                 Rz(theta4) relative to Frame 3
    %   hJoint5     - hgtransform object for Joint 5,
    %                 Rz(theta5) relative to Frame 4
    %   hJoint6     - hgtransform object for Joint 6,
    %                 Rz(theta6) relative to Frame 5
    %
    % -Patch Handles (hidden)
    %   pLink0      - patch objects associated with the robot base
    %   pLink1      - patch objects associated with link 1
    %   pLink2      - patch objects associated with link 2
    %   pLink3      - patch objects associated with link 3
    %   pLink4      - patch objects associated with link 4
    %   pLink5      - patch objects associated with link 5
    %   pLink6      - patch objects associated with link 6
    %
    % Example:
    %
    %       % Create, initialize, and visualize
    %       ur5 = URsim;            % Create simulation object
    %       ur5.Initialize('UR5');  % Designate as UR5 simulation
    %
    %       % Send simulation to zero configuration
    %       ur5.Zero;
    %       pause(1);
    %       % Send simulation to hold configuration
    %       ur5.Home;
    %       pause(1);
    %       % Send simulation to random configuration
    %       ur5.Joints = 2*pi*rand(1,6);
    %       pause(1);
    %
    % See also
    %
    %   M. Kutzer 21July2016, USNA
    
    % Updates
    %   24Jan2017 - Update to help example
    
    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public')
        Figure      % Figure containing the simulation axes
        Axes        % Axes containing the simulation
    end
    
    properties(GetAccess='public', SetAccess='private')
        URmodel     % Specified type of Universal Robot Manipulator
    end
    
    properties(GetAccess='public', SetAccess='public')
        Joints      % 1x6 array containing joint values (radians)
        Pose        % 4x4 homogeneous transform representing the end-effector pose relative to the world frame
        ToolPose    % 4x4 homogeneous transform representing the tool pose relative to the world frame
    end % end properties
    
    properties(GetAccess='public', SetAccess='private')
        DHtable     % DH table associated with robot
    end % end properties
    
    properties(GetAccess='public', SetAccess='public')
        Frame0      % Frame 0 (transformation relative to World/Axes Frame)
    end % end properties
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        Frame1      % Frame 1 (transformation relative to Frame 0)
        Frame2      % Frame 2 (transformation relative to Frame 1)
        Frame3      % Frame 3 (transformation relative to Frame 2)
        Frame4      % Frame 4 (transformation relative to Frame 3)
        Frame5      % Frame 5 (transformation relative to Frame 4)
        Frame6      % Frame 6 (transformation relative to Frame 5)
        FrameE      % End-effector Frame (transformation relative to Frame 6)
    end % end properties
    
    properties(GetAccess='public', SetAccess='public')
        FrameT      % Tool Frame (transformation relative to the End-effector Frame)
    end % end properties
    
    properties(GetAccess='public', SetAccess='public', Hidden=true)
        Joint1      % Joint 1 value (radians)
        Joint2      % Joint 2 value (radians)
        Joint3      % Joint 3 value (radians)
        Joint4      % Joint 4 value (radians)
        Joint5      % Joint 5 value (radians)
        Joint6      % Joint 6 value (radians)
    end % end properties
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        hFrame0     % hgtransform object for Frame 0
        hFrame1     % hgtransform object for Frame 1
        hFrame2     % hgtransform object for Frame 2
        hFrame3     % hgtransform object for Frame 3
        hFrame4     % hgtransform object for Frame 4
        hFrame5     % hgtransform object for Frame 5
        hFrame6     % hgtransform object for Frame 6
        hFrameE     % hgtransform object for the end-effector frame
        hFrameT     % hgtransform object for the tool
    end % end properties
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        hJoint1     % hgtransform object for Joint 1
        hJoint2     % hgtransform object for Joint 2
        hJoint3     % hgtransform object for Joint 3
        hJoint4     % hgtransform object for Joint 4
        hJoint5     % hgtransform object for Joint 5
        hJoint6     % hgtransform object for Joint 6
    end % end properties
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        pLink0      % patch objects associated with the robot base
        pLink1      % patch objects associated with link 1
        pLink2      % patch objects associated with link 2
        pLink3      % patch objects associated with link 3
        pLink4      % patch objects associated with link 4
        pLink5      % patch objects associated with link 5
        pLink6      % patch objects associated with link 6
    end % end properties
    
    % --------------------------------------------------------------------
    % Internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        Joints_Old	% Previous joint configuration (used with Undo)
    end
    
    % --------------------------------------------------------------------
    % Constructor/Destructor
    % --------------------------------------------------------------------
    methods(Access='public')
        function obj = URsim
            % Create URsim Object
        end
        
        function delete(obj)
            % Object destructor
            if ishandle(obj.hFrame0)
                delete(obj.hFrame0) % Delete UR simulation
            end
            
            if ishandle(obj.Axes)
                kids = get(obj.Axes,'Children');
                axsPrompt = false;
                if numel(kids) == 1
                    % Check if remaining object is a light
                    switch lower(kids(1).Type)
                        case 'light'
                            delete(obj.Axes)
                        otherwise
                            axsPrompt = true;
                    end
                else
                    axsPrompt = true;
                end
                
                if axsPrompt
                    % TODO - consider prompting user to delete axes
                end
            end
            
            if ishandle(obj.Figure)
                kids = get(obj.Figure,'Children');
                if numel(kids) > 0
                    % TODO - consider prompting user to delete figure
                else
                    delete(obj.Figure);
                end
            end
        end
    end % end methods
    
    % --------------------------------------------------------------------
    % Initialization
    % --------------------------------------------------------------------
    methods(Access='public')
        function Initialize(obj,varargin)
            % Initialize initializes a Universal Robot simulation
            %
            % Initialize(obj)
            %
            % Initialize(obj,URmodel)
            %
            % Initialize(obj,URmodel,complexity)
            
            % TODO - add resolution
            
            % Check inputs
            % TODO - consider narginchk
            % Define complexity
            narginchk(1,3);
            if nargin < 3
                complexity = 'Coarse';
            else
                complexity = varargin{3};
                complexity = [ upper(complexity(1)),lower(complexity(2:end))];
            end
            % Define robot model
            if nargin < 2
                % Prompt user for robot type
                URmods = {'UR3','UR5','UR10'};
                [s,v] = listdlg(...
                    'Name','Select Model',...
                    'PromptString','Select UR model:',...
                    'SelectionMode','single',...
                    'ListString',URmods);
                if v
                    % User selected model
                    obj.URmodel = URmods{s};
                else
                    % No value selected.
                    delete(obj);
                end
            else
                obj.URmodel = upper( varargin{1} );
            end
            
            % Check UR Model
            switch upper(obj.URmodel)
                case 'UR3'
                    % UR3
                    % Define visualization forward kinematics
                    obj.Frame0 = eye(4);                                        % H^w_0
                    obj.Frame1 = Tx(   0.00)*Ty(   0.00)*Tz(  86.05);           % H^0_1
                    obj.Frame2 = Tx(   0.00)*Ty( -54.00)*Tz(  65.85)*Rx( pi/2); % H^1_2
                    obj.Frame3 = Tx(-243.65)*Ty(  -0.04)*Tz(  23.60);           % H^2_3
                    obj.Frame4 = Tx(-212.70)*Ty(   0.00)*Tz(  -8.00);           % H^3_4
                    obj.Frame5 = Tx(   0.00)*Ty( -42.60)*Tz(  40.80)*Rx( pi/2); % H^4_5
                    obj.Frame6 = Tx(   0.00)*Ty(  42.60)*Tz(  40.80)*Rx(-pi/2); % H^5_6
                    obj.FrameE = Tx(   0.00)*Ty(   0.00)*Tz(  39.80);           % H^6_e
                    obj.FrameT = eye(4);                                        % H^e_t
                    
                    % Define files
                    folderName = 'SimulationComponents, UR3';
                    f{1,1} = {'UR3_Link0'};
                    f{2,1} = {'UR3_Link1'};
                    f{3,1} = {'UR3_Link2_P1','UR3_Link2_P2','UR3_Link2_P3'};
                    f{4,1} = {'UR3_Link3_P1','UR3_Link3_P2','UR3_Link3_P3'};
                    f{5,1} = {'UR3_Link4'};
                    f{6,1} = {'UR3_Link5'};
                    f{7,1} = {'UR3_Link6'};
                    % Define plotting information
                    Scale = 100;
                    LineWidth = 3;
                    xlimit = [-700,700];
                    ylimit = [-700,700];
                    zlimit = [ -150,700];
                case 'UR5'
                    % UR5
                    % Define visualization forward kinematics
                    obj.Frame0 = eye(4);                                        % H^w_0
                    obj.Frame1 = Tx(   0.00)*Ty(   0.00)*Tz(  24.00);           % H^0_1
                    obj.Frame2 = Tx(   0.00)*Ty( -70.50)*Tz(  65.20)*Rx( pi/2); % H^1_2
                    obj.Frame3 = Tx(-425.00)*Ty(   0.00)*Tz(   0.00);           % H^2_3
                    obj.Frame4 = Tx(-392.43)*Ty(   0.00)*Tz(  -7.00);           % H^3_4
                    obj.Frame5 = Tx(   0.00)*Ty( -47.50)*Tz(  45.50)*Rx( pi/2); % H^4_5
                    obj.Frame6 = Tx(   0.00)*Ty(  47.50)*Tz(  45.50)*Rx(-pi/2); % H^5_6
                    obj.FrameE = Tx(   0.00)*Ty(   0.00)*Tz(  34.50);           % H^6_e
                    obj.FrameT = eye(4);                                        % H^e_t
                    
                    % Define files
                    folderName = 'SimulationComponents, UR5';
                    f{1,1} = {'UR5_Link0'};
                    f{2,1} = {'UR5_Link1'};
                    f{3,1} = {'UR5_Link2_P1','UR5_Link2_P2','UR5_Link2_P3'};
                    f{4,1} = {'UR5_Link3_P1','UR5_Link3_P2','UR5_Link3_P3'};
                    f{5,1} = {'UR5_Link4'};
                    f{6,1} = {'UR5_Link5'};
                    f{7,1} = {'UR5_Link6'};
                    % Define plotting information
                    Scale = 100;
                    LineWidth = 3;
                    xlimit = [-1000,1000];
                    ylimit = [-1000,1000];
                    zlimit = [ -200,1000];
                case 'UR10'
                    % UR10
                    % Define visualization forward kinematics
                    obj.Frame0 = eye(4);                                        % H^w_0
                    obj.Frame1 = Tx(   0.00)*Ty(   0.00)*Tz(  38.00);           % H^0_1
                    obj.Frame2 = Tx(   0.00)*Ty( -86.00)*Tz(  90.00)*Rx( pi/2); % H^1_2
                    obj.Frame3 = Tx(-612.90)*Ty(   0.00)*Tz(  21.89);           % H^2_3
                    obj.Frame4 = Tx(-571.60)*Ty(   0.00)*Tz(   2.00);           % H^3_4
                    obj.Frame5 = Tx(   0.00)*Ty( -61.70)*Tz(  54.00)*Rx( pi/2); % H^4_5
                    obj.Frame6 = Tx(   0.00)*Ty(  61.70)*Tz(  54.00)*Rx(-pi/2); % H^5_6
                    obj.FrameE = Tx(   0.00)*Ty(   0.00)*Tz(  30.50);           % H^6_e
                    obj.FrameT = eye(4);                                        % H^e_t
                    
                    % Define files
                    folderName = 'SimulationComponents, UR10';
                    f{1,:} = {'UR10_Link0'};
                    f{2,:} = {'UR10_Link1'};
                    f{3,:} = {'UR10_Link2_P1','UR10_Link2_P2','UR10_Link2_P3'};
                    f{4,:} = {'UR10_Link3_P1','UR10_Link3_P2','UR10_Link3_P3'};
                    f{5,:} = {'UR10_Link4'};
                    f{6,:} = {'UR10_Link5'};
                    f{7,:} = {'UR10_Link6'};
                    % Define plotting limits
                    Scale = 150;
                    LineWidth = 3;
                    xlimit = [-1500,1500];
                    ylimit = [-1500,1500];
                    zlimit = [ -200,1500];
                otherwise
                    error('URsim:BadModel','"%s" is not a recognized type of Universal Robot.',obj.URmodel);
            end
            
            % Setup figure and axes
            % Create new figure
            fig = figure;
            % Create axes in scorSim.Figure
            axs = axes('Parent',fig);
            % Update figure properties
            set(fig,'Name',sprintf('%s Visualization',obj.URmodel),...
                'MenuBar','none','NumberTitle','off','ToolBar','Figure');
            set(fig,'Units','Normalized','Position',[0.30,0.25,0.40,0.60]);
            % Set tag to help confirm validity of global variable
            set(fig,'Tag','UR Visualization Figure, Do Not Change');
            % Set axes limits
            set(axs,'XLim',xlimit,'YLim',ylimit,'ZLim',zlimit);
            % Set axes aspect ratio, hold status, view, and add a light
            daspect(axs,[1 1 1]);
            hold(axs,'on');
            view(axs,3);
            addSingleLight(obj.Axes);
            % Define axes labels
            xlabel(axs,'x (mm)');
            ylabel(axs,'y (mm)');
            zlabel(axs,'z (mm)');
            
            % Set axes and figure property
            obj.Axes = axs;
            
            % Create robot visualization
            % -> Robot Frames (0, 1, 2, etc)
            frameIDs = {'0','1','2','3','4','5','6','E','T'};
            for i = 1:numel(frameIDs)
                % Define frame visualization
                AxisLabels{1} = sprintf('x_%s',frameIDs{i});
                AxisLabels{2} = sprintf('y_%s',frameIDs{i});
                AxisLabels{3} = sprintf('z_%s',frameIDs{i});
                
                % Define relative transformation
                eval( sprintf('H = obj.Frame%s;',  frameIDs{i})   );
                % Define parent
                if i == 1
                    % For Frame 0
                    mom = obj.Axes;
                elseif i == 2
                    % For Frame 1
                    mom = obj.hFrame0;
                elseif i > 8
                    % For Frame T
                    mom = obj.hFrameE;
                else
                    % Get prior frame
                    eval( sprintf('mom = obj.hFrame%s;',frameIDs{i-1}) );
                    % Create "Joint" Frame
                    mom = hgtransform('Parent',mom,'Tag',...
                        sprintf('Joint Frame %s',frameIDs{i-1}));
                    % Set "Joint" object
                    eval( sprintf('obj.hJoint%s = mom;',frameIDs{i-1}) );
                end
                
                % Load visualization
                if i > 1 && i < 9
                    for j = 1:numel(f{i-1})
                        filename = sprintf('%s_%s.fig',f{i-1}{j},complexity);
                        open( fullfile(folderName,filename) );
                        
                        figname = sprintf('%s_%s',f{i-1}{j},complexity);
                        fig = findobj('Parent',0,'Name',figname);
                        if isempty(fig)
                            % Use current figure if no figure is found
                            warning('URsim:unknownFigureName',...
                                'The figure name for "%s" does not appear to be "%s". Attempting to use current figure instead.',filename,figname);
                            drawnow;
                            fig = gcf;
                        end
                        if numel(fig) > 1
                            % Multiple candidate figures found
                            %  - Cycle through figures
                            warning('URsim:multipleFigureName',...
                                'Multiple instances of "%s" are currently open.',figname);
                            figs = fig;
                            for fig_idx = 1:numel(figs)
                                fig = figs(fig_idx);
                                try
                                    set(fig,'Visible','off');
                                    axs = get(fig,'Children');
                                    body = get(axs,'Children');
                                    set(body,'Parent',mom);
                                    eval( sprintf('obj.pLink%d(j) = body;',i-2) );
                                    close(fig);
                                    break
                                catch
                                    close(fig);
                                end
                            end
                        else
                            % Single figure found
                            set(fig,'Visible','off');
                            axs = get(fig,'Children');
                            body = get(axs,'Children');
                            set(body,'Parent',mom);
                            eval( sprintf('obj.pLink%d(j) = body;',i-2) );
                            close(fig);
                        end
                    end
                end
                
                % Define transformation
                eval( sprintf('H = obj.Frame%s;',frameIDs{i}) );
                % Create Frame Visualization
                h = triad(...
                    'Parent',mom,'Scale',Scale,'LineWidth',LineWidth,...
                    'Matrix',H,'AxisLabels',AxisLabels);
                % Set "Frame" object
                eval( sprintf('obj.hFrame%s = h;',frameIDs{i}) );
                
            end
            % Update DHtable
            obj.DHtable = UR_DHtable(obj.URmodel);
            % Initialize Joint Configuration
            obj.Joints = zeros(6,1);
            
        end
    end % end methods
    
    % --------------------------------------------------------------------
    % General Use
    % --------------------------------------------------------------------
    methods(Access='public')
        function Home(obj)
            % Move the UR simulation to the home configuration
            % TODO - confirm home position of UR3 and UR5
            joints = [ 0.00;...
                -pi/2;...
                0.00;...
                -pi/2;...
                0.00;...
                0.00];
            obj.Joints = joints;
        end
        
        function Stow(obj)
            % Move the UR simulation to the stow configuration
            % TODO - confirm stow position of UR3 and UR5
            joints = [ 0.00000;...
                -0.01626;...
                -2.77643;...
                1.22148;...
                1.57080;...
                0.00000];
            obj.Joints = joints;
        end
        
        function Zero(obj)
            % Move the UR simulation to the zero configuration
            obj.Joints = zeros(6,1);
        end
        
        function Undo(obj)
            % Undo the previous move of the UR
            alljoints = obj.Joints_Old;
            if ~isempty(alljoints)
                obj.Joints = alljoints(:,end);
                alljoints(:,end) = [];
                obj.Joints_Old = alljoints;
            end
        end
        
    end % end methods
    
    % --------------------------------------------------------------------
    % Getters/Setters
    % --------------------------------------------------------------------
    methods
        % GetAccess & SetAccess ------------------------------------------
        
        % Figure - figure handle containing simulation axes
        function fig = get.Figure(obj)
            fig = obj.Figure;
        end
        
        function obj = set.Figure(obj,fig)
            fig_old = obj.Figure;
            if ishandle(fig)
                switch lower(fig.Type)
                    case 'figure'
                        axs = obj.Axes;
                        set(axs,'Parent',fig);
                        obj.Figure = fig;
                        
                        if ~isempty(fig_old) && ishandle(fig_old)
                            close(fig_old);
                        end
                        return
                end
            end
            error('Specified figure handle must be valid.');
        end
        
        % Axes - axes handle containing simulation
        function axs = get.Axes(obj)
            axs = obj.Axes;
        end
        
        function obj = set.Axes(obj,axs)
            fig_old = obj.Figure;
            if ishandle(axs)
                switch lower(axs.Type)
                    case 'axes'
                        base = obj.hFrame0;
                        set(base,'Parent',axs);
                        daspect(axs,[1 1 1]);
                        addSingleLight(axs);
                        obj.Axes = axs;
                        fig = get(axs,'Parent');
                        obj.Figure = fig;
                        
                        if ~isempty(fig_old) && ishandle(fig_old)
                            close(fig_old);
                        end
                        return
                end
            end
            error('Specified figure handle must be valid.');
        end
        
        % Joints - 1x6 array containing joint values (radians)
        function joints = get.Joints(obj)
            % Get current joint configuration of the simulation
            joints = obj.Joints;
        end
        
        function obj = set.Joints(obj,joints)
            % Set the joint configuration of the simulation
            if numel(joints) ~= 6
                error('Joint configuration must be specified as a 6-element array.');
            end
            joints = reshape(joints,6,1);
            for i = 1:numel(joints)
                eval( sprintf('g = obj.hJoint%d;',i) );
                set(g,'Matrix',Rz(joints(i)));
            end
            obj.Joints = joints;
            
            alljoints = obj.Joints_Old;
            alljoints(:,end+1) = joints;
            obj.Joints_Old = alljoints;
        end
        
        % JointI - individaul joints of the robot
        % Joint 1
        function joint = get.Joint1(obj)
            % Get current angle of joint 1
            joints = obj.Joints;
            joint = joints(1);
        end
        function obj = set.Joint1(obj,joint)
            % Set current angle of joint 1
            joints = obj.Joints;
            joints(1) = joint;
            obj.Joints = joints;
        end
        % Joint 2
        function joint = get.Joint2(obj)
            % Get current angle of joint 2
            joints = obj.Joints;
            joint = joints(2);
        end
        function obj = set.Joint2(obj,joint)
            % Set current angle of joint 2
            joints = obj.Joints;
            joints(2) = joint;
            obj.Joints = joints;
        end
        % Joint 3
        function joint = get.Joint3(obj)
            % Get current angle of joint 3
            joints = obj.Joints;
            joint = joints(3);
        end
        function obj = set.Joint3(obj,joint)
            % Set current angle of joint 3
            joints = obj.Joints;
            joints(3) = joint;
            obj.Joints = joints;
        end
        % Joint 4
        function joint = get.Joint4(obj)
            % Get current angle of joint 4
            joints = obj.Joints;
            joint = joints(4);
        end
        function obj = set.Joint4(obj,joint)
            % Set current angle of joint 4
            joints = obj.Joints;
            joints(4) = joint;
            obj.Joints = joints;
        end
        % Joint 5
        function joint = get.Joint5(obj)
            % Get current angle of joint 5
            joints = obj.Joints;
            joint = joints(5);
        end
        function obj = set.Joint5(obj,joint)
            % Set current angle of joint 5
            joints = obj.Joints;
            joints(5) = joint;
            obj.Joints = joints;
        end
        % Joint 6
        function joint = get.Joint6(obj)
            % Get current angle of joint 6
            joints = obj.Joints;
            joint = joints(6);
        end
        function obj = set.Joint6(obj,joint)
            % Set current angle of joint 6
            joints = obj.Joints;
            joints(6) = joint;
            obj.Joints = joints;
        end
        
        % Pose - 4x4 homogeneous transform representing the end-effector
        %        pose relative to the world frame
        function pose = get.Pose(obj)
            % Get the current end-effector pose of the simulation
            pose0 = UR_fkin(obj.URmodel,obj.Joints);
            pose = obj.Frame0 * pose0;   % Account for world frame offset
        end
        
        function obj = set.Pose(obj,pose)
            % Set the current end-effector pose of the simulation
            pose0 = invSE(obj.Frame0) * pose;   % Account for world frame offset
            q_all = UR_ikin(obj.URmodel,pose0); % Solve inverse kinematics
            if size(q_all,2) > 0
                % Account for multiple solutions
                % Find solution closest to current configuration
                q = obj.Joints;                 % Get current joint configuration
                [q_star,q_sort] = findClosestVector(q_all,q);
                
                %{
                % TODO - notify user is multiple options are close
                % Prompt user to select from multiple options
                if max( abs(q-q_star) ) < deg2rad(2)
                    q_idx = 1;
                    q_max = size(q_sort,2);
                    while true
                        % TODO - Make internal dialog to take care of this.
                        choice = questdlg('Select viable solution', ...
                            'Large Movement Solution', ...
                            'Previous','Select','Next','Select');
                        switch choice
                            case 'Previous'
                                q_idx = mod(q_idx - 1, q_max);
                                if q_idx == 0
                                    q_idx = q_max;
                                end
                                obj.Joints = q_sort(:,q_idx);
                                drawnow
                            case 'Next'
                                q_idx = mod(q_idx + 1, q_max);
                                if q_idx == 0
                                    q_idx = q_max;
                                end
                                obj.Joints = q_sort(:,q_idx);
                                drawnow
                            case 'Select'
                                q_star = q_sort(:,q_idx);
                                break
                            otherwise
                                disp(choice);
                                error('Unexpected response.');
                        end
                        
                    end
                    
                end
                %}
                
                obj.Joints = q_star;            % Set new joint configuration
                obj.Pose = pose;                % Update pose
            else
                warning('Specified pose is outside of the workspace.');
            end
        end
        
        % ToolPose - 4x4 homogeneous transform representing the tool pose
        %            relative to the world frame
        function toolpose = get.ToolPose(obj)
            % Get the current tool pose of the simulation
            pose = obj.Pose;
            toolpose = pose * obj.FrameT;
        end
        
        function obj = set.ToolPose(obj,toolpose)
            % Set the current tool pose of the simulation
            pose = toolpose * invSE(obj.FrameT);
            obj.Pose = pose;
        end
        
        % Frame 0 - 4x4 homogeneous transform relative to World/Axes Frame)
        function frame0 = get.Frame0(obj)
            % Get the transformation relating the base frame to the world
            frame0 = obj.Frame0;
        end
        
        function obj = set.Frame0(obj,frame0)
            % Set the transformation relating the base frame to the world
            obj.Frame0 = frame0;
            h = obj.hFrame0;
            set(h,'Matrix',frame0);
        end
        
        % FrameT - Tool Frame (transformation relative to the End-effector
        %          Frame)
        function frameT = get.FrameT(obj)
            % Get the transformation relating the tool frame to the
            % end-effector frame
            frameT = obj.FrameT;
        end
        
        function obj = set.FrameT(obj,frameT)
            % Set the transformation relating the tool frame to the
            % end-effector frame
            obj.FrameT = frameT;
            h = obj.hFrameT;
            set(h,'Matrix',frameT);
        end
        
        function obj = set.Joints_Old(obj,allJoints)
            % Set the history for undo method
            n = 50; % Limit size of history
            % alljoints(:,end+1) = joints;
            if size(allJoints,2) > 50
                allJoints(:,1) = [];
            end
            obj.Joints_Old = allJoints;
        end
        
        % GetAccess ------------------------------------------------------
        
        % URmodel - Specified type of Universal Robot Manipulator
        function urmodel = get.URmodel(obj)
            urmodel = obj.URmodel;
        end
        % DHtable - DH table associated with robot
        function dhtable = get.DHtable(obj)
            q = obj.Joints;
            urMod = obj.URmodel;
            dhtable = UR_DHtable(urMod,q);
        end
        % Frame1 - 4x4 transformation relative to Frame 0
        function frame1 = get.Frame1(obj)
            frame1 = obj.Frame1;
        end
        % Frame2 - 4x4 transformation relative to Frame 1
        function frame2 = get.Frame2(obj)
            frame2 = obj.Frame2;
        end
        % Frame3 - 4x4 transformation relative to Frame 2
        function frame3 = get.Frame3(obj)
            frame3 = obj.Frame3;
        end
        % Frame4 - 4x4 transformation relative to Frame 3
        function frame4 = get.Frame4(obj)
            frame4 = obj.Frame4;
        end
        % Frame5 - 4x4 transformation relative to Frame 4
        function frame5 = get.Frame5(obj)
            frame5 = obj.Frame5;
        end
        % Frame6 - 4x4 transformation relative to Frame 5
        function frame6 = get.Frame6(obj)
            frame6 = obj.Frame6;
        end
        % FrameE - 4x4 transformation relative to Frame 6
        function frameE = get.FrameE(obj)
            frameE = obj.FrameE;
        end
        
        % GetAccess & Hidden ---------------------------------------------
        % hFrame0 - hgtransform object for Frame 0
        function hframe0 = get.hFrame0(obj)
            hframe0 = obj.hFrame0;
        end
        % hFrame1 - hgtransform object for Frame 1
        function hframe1 = get.hFrame1(obj)
            hframe1 = obj.hFrame1;
        end
        % hFrame2 - hgtransform object for Frame 2
        function hframe2 = get.hFrame2(obj)
            hframe2 = obj.hFrame2;
        end
        % hFrame3 - hgtransform object for Frame 3
        function hframe3 = get.hFrame3(obj)
            hframe3 = obj.hFrame3;
        end
        % hFrame4 - hgtransform object for Frame 4
        function hframe4 = get.hFrame4(obj)
            hframe4 = obj.hFrame4;
        end
        % hFrame5 - hgtransform object for Frame 5
        function hframe5 = get.hFrame5(obj)
            hframe5 = obj.hFrame5;
        end
        % hFrame6 - hgtransform object for Frame 6
        function hframe6 = get.hFrame6(obj)
            hframe6 = obj.hFrame6;
        end
        % hFrameE - hgtransform object for the end-effector frame
        function hframeE = get.hFrameE(obj)
            hframeE = obj.hFrameE;
        end
        % hFrameT - hgtransform object for the tool
        function hframeT = get.hFrameT(obj)
            hframeT = obj.hFrameT;
        end
        
        % hJoint1 - hgtransform object for Joint 1
        function hjoint1 = get.hJoint1(obj)
            hjoint1 = obj.hJoint1;
        end
        % hJoint2 - hgtransform object for Joint 2
        function hjoint2 = get.hJoint2(obj)
            hjoint2 = obj.hJoint2;
        end
        % hJoint3 - hgtransform object for Joint 3
        function hjoint3 = get.hJoint3(obj)
            hjoint3 = obj.hJoint3;
        end
        % hJoint4 - hgtransform object for Joint 4
        function hjoint4 = get.hJoint4(obj)
            hjoint4 = obj.hJoint4;
        end
        % hJoint5 - hgtransform object for Joint 5
        function hjoint5 = get.hJoint5(obj)
            hjoint5 = obj.hJoint5;
        end
        % hJoint6 - hgtransform object for Joint 6
        function hjoint6 = get.hJoint6(obj)
            hjoint6 = obj.hJoint6;
        end
        
    end % end methods
end % end classdef
