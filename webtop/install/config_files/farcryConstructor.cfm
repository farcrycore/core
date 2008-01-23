<!--- Set up the application. --->	
<cfset THIS.Name = "@@applicationName@@" />


<cfset THIS.sessionmanagement = true  />

<cfset THIS.sessiontimeout = createTimeSpan(0,0,20,0) />

<cfset THIS.applicationtimeout = createTimeSpan(2,0,0,0) />

<cfset THIS.clientmanagement = false />

<cfset THIS.clientstorage = "registry" />

<cfset THIS.loginstorage = "cookie" />

<cfset THIS.scriptprotect = "" />

<cfset THIS.setclientcookies = true />

<cfset THIS.setdomaincookies = true />

<cfset THIS.mappings = structNew() />




<!--- FARCRY SPECIFIC --->
<cfset THIS.locales = "en_AU" />

<cfset THIS.dsn = "@@dsn@@" /> 

<cfset THIS.dbType = "@@dbType@@" /> 

<cfset THIS.plugins = "@@plugins@@" /> 

<!--- 
THE NAME OF THE FOLDER THAT CONTAINS YOUR FARCRY PROJECT
 --->
<cfset THIS.projectDirectoryName = "@@applicationName@@" /><!--- Defaults to application name --->

<!--- 
THE VIRTUAL WEBSERVER PROJECT FOLDER
 --->
<cfset THIS.projectURL = "@@projectURL@@" /><!--- Defaults to application name --->


<!--- Define the page request properties. --->

<!--- <cfsetting requesttimeout="30" /> --->
<!--- <cfsetting showdebugoutput="true" /> --->
<!--- <cfsetting enablecfoutputonly="true" /> --->

