# Description  
This extension is able to create a MarkDown file format that contains all commit comments associated to the build.  
The file can be placed in any valid path, by default it will part of the artifacts.

### How it works?  
Essentially the extension use the agent environment variables to get an access to VSTS\TFS API service, using the same credentials supplied to the agent (in this way is impossible to stole access credentials); then with a powershell script the extension will retrieve all the commit comments and fulfill a markdown template.

### What's new in v1.0.16?  
* Improved overview

### How to config? 
1. Give access to REST API like image below.
![Build Config](img/configOAuth.png)
2. Set the correct output file path, the default should work but it can be changed as you need.
![Step Config](img/configOutput.png)

