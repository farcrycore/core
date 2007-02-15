<!---------------------------------------------------------
DETERMINE WHICH PROJECT WE ARE ATTEMPTING TO ADMINISTER

 dynamically determine the right farcry application instance to administer
 and include the relevant Application.cfm file from the project; default
 to webroot.

 --------------------------------------------------------->	
<cfmodule template="/farcry/core/tags/farcry/callProjectApplication.cfm" plugin="farcry" />