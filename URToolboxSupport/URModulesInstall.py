#
# installURModules.py
#
# Runs one time to install the necessary modules when the URToolbox
# is first loaded
#
# Eliminates the need for the user to manually add modules in the command
# line window and can help prevent accidental directory mismatch
#
# ENS Kevin Strotz, USN
# 22 September 2016
#

def installURModules():
    import pip
    pip.main(["install","math3d"])
    pip.main(["install","numpy"])
    pip.main(["install","urx"])

