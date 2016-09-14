UR10/UR5 Python Interface and Control

ENS Kevin Strotz
29 June 2016


User-Machine Interface

Download Python v. 3.5.2
https://www.python.org/downloads/release/python-352/
 - Windows x86 executable installer
 - Store in default location

In command line, use pip utility to download math3d, urx, and numpy modules
 - Directory: C:\Users\strotz\AppData\Local\Programs\Python\Python35-32\Scripts
 - Enter commands:
	pip install math3d
	pip install numpy
	pip install urx
 - Provides necessary modules to utilize urx modules with matrices for transforms/trajectories


File Transfer Protocol Interface

Download WinSCP v. 5.7.7
https://winscp.net/download/winscp577setup.exe
 - Windows x86 executable installer
 - Store in default location
Use to transfer .script files to UR, which will then compile into .urp programs when saved on Teach Pendant
System does not like using imported .urp files -> convert text to .script and allow system to compile upon saving


Network Settings

IP Addresses:
 - UR10: 10.1.1.2
 - UR5: 10.1.1.4
 - Computer: 10.1.1.5

Subnet Mask:  255.255.255.0
Default Gateway: 10.1.1.1

Use Network and Sharing Center to configure IPv4 for Local Area Network

FTP:
 - Username: root
 - Password: easybot
 - Host: IP address of desired robot
 - Port: 22
Create programs in Notepad, saved as exampleName.script
Connect FTP, and upload from computer into /programs directory of UR
Then use teach pendant to place script in a program and run
 - Make sure it is nested in program, not outside
 - Still some issues when trying to run URP files
 - Instead, load script and then save natively to allow UR to compile .urp file

TCP/IP
 - Host: IP address of desired robot
 - Port: 30002 
	- Automatically applied when using urx module
	- If using manual socket construction, must specify port

Other Useful Modules
 - time: sleep, wait, other clock functions
 - socket: for manual communication in case urx modules fails
	Basic steps for client (send one line commands to be instantly executed):
	>>> s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	>>> s.connect((HOST,PORT))
	>>> POS = "movej([0,-1.570795,0,0,0,0])\n"
	>>> s.sendall(POS.encode())
	>>> s.close()
	>>> exit()
	Basic steps for server to interact with onboard controllers
	>>> s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	>>> s.bind((HOST,PORT))
	>>> s.listen(backlog)	# For this purpose, only a single connection is needed (backlog = 1)
	>>> client, addr = s.accept() # Accepts socket from UR and creates it as socket with name client
	>>> # Open socket on UR system at this step
	>>> # To send a command, create a string and use client.send()
	>>> msg = '(0,0,0,0,0,0)' # String of joint positions
	>>> client.send(msg.encode())
 - sys: system properties
 - math: basic trig and algebra functionts
	*** NEED NUMPY AND MATH3D FOR MATRICES AND TRAJECTORIES ***

Easy UR Socket Class: written by ENS Strotz to simplify server communications with UR5/UR10
	*** MAKE SURE URSocketClass.py IS IN THE CORRECT FOLDER TO BE IMPORTED
		-> On the laptop setup, put it in C:\Users\Research\AppData\Local\Programs\Python\Python35-35\Lib
	>>> import URSocketClass
	>>> s = URSocketClass.URSocket()
	>>> s.cnct(HOST,PORT)
	>>> s.sendmsg(msg)
	>>> s.close()

URX Module: establishes socket connection with UR5/UR10 as a client, vice URSocketClass working as server
	>>> import urx
	>>> r = urx.Robot(IP)
	>>> # Several useful commands listed:
	>>> r.movej([joint_poses]) # Moves to joint positions. Very slow unless user specifies vel and acc
	>>> r.send_message('Enter text here.') # Sends text to log on UR5/UR10
	>>> r.send_program('Enter URScript commands for robot to execute.') # Send URScript commands

URX Failsafe
 - portName.send_program('entercommandhere') to bypass Python library functions and use onboard commands
	*** works the same because this is what the library does internally anyway ***

URScript Basics
 - Syntax is similar to Python, but with some unique commands and requirements
 - Comments are still hashtags
 - Basic commands needed:
	-> socket_open('IP',PORT) # open socket communications with Python server
		*** to get around InfiniteLoop error, use a handle for the socket as a while loop condition
		-> isRunning = socket_open('10.1.1.5',30002)
		-> while isRunning:
			enter main program here
	-> socket_close() # close socket
	-> floatVar = socket_read_ascii_float(numOfValues) # read number values into a variable 
	-> thread myThread(): # establish threads, no input or return arguments possible
		*** CAN reference variables from outside the thread, not isolated like a function ***
	-> threadHandle = run myThread() # run a thread
	-> kill threadHandle # kill a thread and any children it has
	-> join threadHandle # wait for a thread to finish running
	-> textmsg('text') or textmsg(var) # enter message/variable into UR log, useful to display values as a check
	-> popup('text') # pause program with a popup message window, gives option to stop program or continue

*****************************SUCCESSFUL COMMS STRUCTURE [6 JUL 16]********************************

Download Socket Test v. 3.0.0
https://sourceforge.net/projects/sockettest

URX module in Python allows for computer to be a client, this allows computer to be a server
Establish server connection listening on computer
 - IP Address: 10.1.1.5
 - Port: 30002

Start listening, then run successfulTest.urp on robot (see successfulText.script for full onboard code)

Formatting:
 - Send numbers in format (1.0,-1.0,...)
 - First number in list received onboard (varName[0]) is an index indicating the number of values received
	*** VERY helpful as a check to make sure data is received (is varName[0] > 0)

*************************************END SOCKET DETAILS*******************************************

******************************SUCCESSFUL ONBOARD CONTROL [12 JUL 16]*********************************

Original code structure sourced from BIGSSURServer.ur by Ryan Murphy (JHU)
	*** NOTE: THIS IS NOT A PD CONTROLLER
		-> IT ONLY HAS PROPORTIONAL CONTROL WITH A HARD THRESHOLD

For full modified file, see C:\Users\Research\Documents\threadController.script
Overview of changes:
 - Remove def BISSURServer(): and corresponding end
 - Change ADDRESS and HOST pointers to UR5/UR10 IP address and 30002 respectively
 - Remove spatial velocity thread
 - Remove joint velocity thread
 - Keep initialized variables and main thread
	-> Change pos_dist[i] = qcurr[i] - pd_qdes[i] to pos_dist[i] = pd_qdes[i] - qcurr[i]
	-> Swap elif and if clauses to allow for stopping at desired pose
	-> Adjust thresholds and multipliers as desired
	-> Change speedj to speedj(pos_vel, 1.0,0.1)
 - Keep only mode 6 of main loop
 - Change val read command to val = socket_read_ascii_float(6) instead of (7)
 - Creat valOld to send old position if no new position is received on a given cycle

********************************END BASIC CONTROL********************************

********************************PID CONTROLLER******************************

Use modified controller in C:\Users\Research\Document\threadController.script as base
Incorporates more sophisticated PID control law according to following law:

           .                {            .  
	-> x = Kp*(xd-x)+Ki*|(xd-x)dt+Ka*xd -> Ka should nominally be 1
                            }

Needs to receive twelve values instead of just six: val = [[joint_pos][joint_vel]]
	-> val = socket_read_ascii_float(12)
	-> val = [12,joint1,joint2,joint3,joint4,joint5,joint6,jointvel1,jointvel2,jointvel3,jointvel4,jointvel5,jointvel6]

PID Controller succesfully implemented, still working on tuning gains.  For now:
	-> Kp = 1.0
	-> Ki = 0.0 (increase slowly as tests, such as Ki += 0.05)
	-> Ka = 1.0 

UPDATE
Found that best results were acheived with:
	-> Kp = 1.0
	-> Ki = 0.0
	-> Ka = 0.0
 - This is just proportional control, needs to be checked with a wide variety of movements to be sure

*********************************END PID CONTROLLER*****************************

********************************MATLAB INTERFACING*******************************

*** MUST USE PYTHON VERSION 3.4 --> MATLAB IS NOT COMPATIBLE WITH 3.5 ***
Created custom MATLAB class and Python module to enable control in MATLAB only
 - Do not use any print() statements in Python, MATLAB does not like them
 - In MATLAB class, make sure to set as a handle type
 - Set modules as global variables so that all functions in the class can call them
 - Put Python files in MATLAB directory, or use addpath() function at initialization
 - Make sure set and get functions are included for properties that change
 - Allows for double connection:
	-> Computer serves as server to feed desired waypoints to onboard UR client socket
	-> Computer also opens URX connection to get immediate telemetry back
 - Be sure to explore URXNAME.secmon._dict -> contains all possible data from UR
	-> Not all was made easily accessible via higher level functions, ie:
		 - URXNAME.getj() will return joint data
		 - No corresponding function for joint velocities -> use dictionary with specific keys to extract
 - When sending numbers/variables from MATLAB to a Python function, make sure they are the right type
	-> MATLAB creates as a double (float), so it must be manually changed (usually to int16)
	-> Python lists, tuples, dictionaries, and other types not normally found in MATLAB must be extracted
		 - Use for loops to creat cell arrays, and then pull values from that into MATLAB arrays/vectors

On laptop setup, see following files (easier if they are in the same directory as trajectory scripts):
 -> C:\Users\Research\Documents\URSocketMatlab.py
 -> C:\Users\Research\Documents\URMatlabClass.m

Default values for calling from MATLAB class:
 - Server IP Address: 10.1.1.5
 - Server Port: 30002
 - Backlog: 1 (refers to number of connections server will accept)
 - URX IP Address: for UR5:: 10.1.1.4; for UR10:: 10.1.1.2

Currently configured to create a plot of each joint's position and velocity against the commanded values

To import Python modules in MATLAB: moduleHandle = py.importlib.import_module('moduleName')
	-> Do not include the .py extension when importing, MATLAB will not recognize it

********************************END MATLAB INTERFACING***********************************

********************************DUAL ROBOT CONTROL****************************************

Use network switch to connect both manipulators to the same computer

UR class allows for multiple objects of that type to be created, provided only one server is initialized
For the 1st connection, give no initial input variables --> user will then be prompted for specs to create server
For subsequent connections, give handle of first UR object as input variable --> MATLAB will migrate server to new object

After create, simply use the different handles to specify which manipulator to query/ocontrol
