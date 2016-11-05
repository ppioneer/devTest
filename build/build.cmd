@echo off
:: build.bat is used to push this set of Salesforce code to an Org.
:: The Org is decided based on the user credentials given by the user
:: This script has the following dependencies:
::     - Java and JAVA_HOME
::     - Ant and ANT_HOME
::     - Salesforce Metadata API
::     - build.xml file for Salesforce
::     - build.properties file for Salesforce

set file=output.txt

Set /P precheck=This will push the current code to an org. Do you wish to continue (y/n)?

IF NOT "%precheck%" == "y" GOTO End
Set /P username=Please enter your username: 
Set /P password=Please enter your password: 
Set /P token=Please enter your token: 

ant fullDeploy -l %file% -Dsf.username=%username% -Dsf.password=%password%%token%

:End