<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<!------------------ 
START TAG
 ------------------>
<cfset baseTagData = getBaseTagData("cf_tab")>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id" default="#createUUID()#">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.icon" default="">
	<cfparam name="attributes.collapsed" default="true">
	<cfparam name="attributes.html" default="">


	<cfset stPanel = structNew() />
	<cfset stPanel.id = attributes.id />
	<cfset stPanel.title = attributes.title />
	<cfset stPanel.icon = attributes.icon />
	<cfset stPanel.collapsed = attributes.collapsed />
	<cfset stPanel.html = attributes.html />
	
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset stPanel.html = "#stPanel.html##thisTag.GeneratedContent#" />
	<cfset arrayAppend(baseTagData.attributes.aPanels, stPanel) />
	
	<cfset thisTag.GeneratedContent = "" />
	
</cfif>

<cfsetting enablecfoutputonly="false">

