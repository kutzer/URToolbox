#
# Class Definition for Constant Socket Comms to UR Platforms
#
# ENS Kevin Strotz
# Assistant Professor Michael Kutzer, Principal Investigator
# 19 AUG 2016
#
# Referenced in MATLAB class, make sure directory is appropriate and command names match
# Do NOT need direct Python interface for functionality, everything is called in MATLAB
#
# Be careful of variable types when passing values Python <-> MATLAB
# - Some are not supported in the other, ie. tuples, MATLAB doubles
# - Manually convert to force compatibility 
#
# Ensure modules and variable to be returned have proper scope (usually global)
#

# Initialize socket in correct family, bind as a server, and begin listening for clients
# Return socket structure to the MATLAB workspace for future use
# Three input parameters:
#  host = server IP address
#  port = port to listen for connections on
#  backlog = number of connections to listen for
def initServer(host,port,backlog):    
    import socket           # import socket module to Python environment
    global socketname       # create global handle to for server socket to be returned to MATLAB
    socketname = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # initialize socket type
    socketname.bind((host, port))   # Bind socket to specified host address and port
    socketname.listen(backlog)      # Begin listening for client connections from manipulators
    return socketname       # return established server socket to MATLAB workspace

# Accept client connections on a previously established server
# One input parameter:
#  socketname = established server socket handle
def cnctClient(socketname):
    global client           # create global handle for client to be returned to MATLAB 
    sockettuple = socketname.accept()   # Accept a connection and store [client, address] in handle
    client = sockettuple[0] # Separate actual socket object out of tuple
    return client           # return established client socket to MATLAB workspace

# Create URX connection to manipulator
# One input parameter:
# robotip = IP address of manipulator
def cnctURX(robotip):
    import urx              # import module
    global r                # global handle for urx connection to be returned to MATLAB
    r = urx.Robot(robotip)  # establish connection
    return r                # return connection to MATLAB

# Send message from server to client (UR robot)
# Message is simply a string, Python does not format it at all
# Ensure correct formatting in MATLAB that will be understood by onboard controllers
# Needs .encode() to convert to binary before sending
# Two input parameters:
#  client = established client socket destination
#  msg = string to be sent to client
def sendmsg(client,msg):
    client.send(msg.encode())   # Encode string as binary and send to designated client

# Close socket connection
# Does not eliminate handle or object, simply closes connection
# One dual manipulator setup has three sockets to close: 2x clients, 1x server
# One input parameter:
#  socketname = handle of socket to be closed
def closeSocket(socketname):
    socketname.close()      # Close designated socket

# Close URX connection
# Same functionality as closeSocket
# One dual manipulator setup has two URX connections
def closeURX(robot):
    robot.close()

#************************************TELEMETRY*********************************************
# Following section contains functions to get data from a UR manipulator and return it to MATLAB
# All functions have one input argument of the URX connection handle
# -> When called in MATLAB, should not need input as the internal class function handles it
# Generally return a Python list to MATLAB which can be parsed there

# Get current joint positions
# ***Prexisting function, no need to call dictionary and manually extract data
def getJPos(robot):
    import urx
    global jPos
    jPos = robot.getj()
    return jPos

# Get current joint velocities from a manipulator
# ***NO NATIVE URX FUNCTION, CONSIDER IMPLEMENTING THIS IN URX MODULE VICE HERE***
def getJVels(robot):
    global jVels            # create global handle for joint velocities to be returned to MATLAB
    jData = robot.secmon._dict["JointData"] # Extract all joint info from URX dictionary using key "JointData"
    # Extract joint velocities from all joint data using variable names
    jVels = [jData["qd_actual0"],jData["qd_actual1"],jData["qd_actual2"],jData["qd_actual3"],jData["qd_actual4"],jData["qd_actual5"]]
    return jVels            # return joint velocity list to MATLAB workspace

# Get current joint torques
def getJTorq(robot):
    global jTorq
    jData = robot.secmon._dict["JointData"]
    jTorq = [jData["T_motor0"],jData["T_motor1"],jData["T_motor2"],jData["T_motor3"],jData["T_motor4"],jData["T_motor5"]]
    return jTorq

# Get current joint voltages
def getJVolt(robot):
    global jVolt
    jData = robot.secmon._dict["JointData"]
    jVolt = [jData["V_actual0"],jData["V_actual1"],jData["V_actual2"],jData["V_actual3"],jData["V_actual4"],jData["V_actual5"]]
    return jVolt

# Get current joint currents
def getJCurr(robot):
    global jCurr
    jData = robot.secmon._dict["JointData"]
    jCurr = [jData["I_actual0"],jData["I_actual1"],jData["I_actual2"],jData["I_actual3"],jData["I_actual4"],jData["I_actual5"]]
    return jCurr

# Get current tool position [X,Y,Z]
def getTPos(robot):
    global tPos
    tData = robot.secmon._dict["CartesianInfo"]
    tPos = [tData["X"],tData["Y"],tData["Z"]]
    return tPos

# Get current tool rotation vectors [Rx,Ry,Rz]
def getTVec(robot):
    global tVec
    tData = robot.secmon._dict["CartesianInfo"]
    tVec = [tData["Rx"],tData["Ry"],tData["Rz"]]
    return tVec

# Get current tool transform
def getTTrans(robot):
    global tTrans
    tTrans = robot.get_pose()
    return tTrans

# Get general tool data {returns as dictionary, not list}
def getTInfo(robot):
    global tInfo
    tInfo = robot.secmon._dict["ToolData"]
    return tInfo

# Get current analog inputs
def getAIn(robot):
    global analogIn
    ioData = robot.secmon._dict["MasterBoardInfo"]
    analogIn = [ioData["analog_in0"],ioData["analog_in1"],ioData["analog_in2"],ioData["analog_in3"],ioData["analog_in4"],ioData["analog_in5"]]
    return analogIn

# Get current digital inputs
def getDIn(robot):
    global digitalIn
    ioData = robot.secmon._dict["MasterBoardInfo"]
    digitalIn = [ioData["digital_in0"],ioData["digital_in1"],ioData["digital_in2"],ioData["digital_in3"],ioData["digital_in4"],ioData["digital_in5"]]
    return digitalIn

# Get current analog outputs           
def getAOut(robot):
    global analogOut
    ioData = robot.secmon._dict["MasterBoardInfo"]
    analogOut = [ioData["analog_out0"],ioData["analog_out1"],ioData["analog_out2"],ioData["analog_out3"],ioData["analog_out4"],ioData["analog_out5"]]
    return analogOut

# Get current digital outputs
def getDOut(robot):
    global digitalOut
    ioData = robot.secmon._dict["MasterBoardInfo"]
    digitalOut = [ioData["digital_out0"],ioData["digital_out1"],ioData["digital_out2"],ioData["digital_out3"],ioData["digital_out4"],ioData["digital_out5"]]
    return digitalOut


        
    
