<!--- Set up the application. --->	
<cfset THIS.Name = "@@applicationName@@" />
<cfset THIS.displayName = "@@applicationDisplayName@@" />


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
<cfset THIS.locales = "@@locales@@" />

<cfset THIS.dsn = "@@dsn@@" /> 

<cfset THIS.dbType = "@@dbType@@" /> 

<cfset THIS.plugins = "@@plugins@@" /> 

<!--- 
THE VIRTUAL WEBSERVER PROJECT FOLDER
 --->
<cfset THIS.projectURL = "@@projectURL@@" />
<cfset THIS.webtopURL = "@@webtopURL@@" />

<!--- 
THE NAME OF THE FOLDER THAT CONTAINS YOUR FARCRY PROJECT
SET THIS VALUE IF IT IS DIFFERENT FROM THE APPLICATION NAME
 --->
<!--- <cfset THIS.projectDirectoryName = "@@applicationName@@" /> --->




<!--- Define the page request properties. --->

<!--- <cfsetting requesttimeout="30" /> --->
<!--- <cfsetting showdebugoutput="true" /> --->
<!--- <cfsetting enablecfoutputonly="true" /> --->

