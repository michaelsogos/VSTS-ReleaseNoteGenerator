# Description  
This extension is able to create a MarkDown file format that contains all commit comments associated to the build.  
The file can be placed in any valid path, by default it will part of the artifacts.

### How it works?  
Essentially the extension use the agent environment variables to get an access to VSTS\TFS API service, using the same credentials supplied to the agent (in this way is impossible to stole access credentials); then with a powershell script the extension will retrieve all the commit comments and fulfill a markdown template.

### What's new in v1.0.4?  
* Fixed a bug to retrieve the correct REST API url (TFS on-premise)
* Improved debug information

### General Notes
To activate debug verbosity add ``` -verbose ``` as parameter
