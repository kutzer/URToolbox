#
# updateURModules.py
#
# Runs with URToolboxUpdate to make sure modules are upgradede
#
# Eliminates the need for the user to manually add modules in the command
# line window and can help prevent accidental directory mismatch
#
# ENS Kevin Strotz, USN
# 22 September 2016
#

def updateURModules():
    import pip
    mathChk = pip.main(["install","math3d","--upgrade","--quiet"])
    numChk = pip.main(["install","numpy","--upgrade","--quiet"])
    urxChk = pip.main(["install","urx","--upgrade","--quiet"])
