<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Ext Notification Message --->
<!--- @@description: Displays a notification message on next request end.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />




<cfparam name="attributes.title" default="" /><!--- The title of the message --->
<cfparam name="attributes.message" default="" /><!--- The actual message. This can be replaced with generatedContent --->
<cfparam name="attributes.pause" default="3" type="numeric" /><!--- How long the message appears before being removed --->
<cfparam name="attributes.bAutoHide" default="true" type="boolean" /><!--- Automatically hide the message after the pause --->

<cfif thistag.executionMode eq "Start">

</cfif>

<cfif thistag.executionMode eq "End">

	<cfif not len(attributes.message)>
		<cfset attributes.message = thisTag.generatedContent />
	</cfif>
	
	<cfparam name="session.aExtMessages" default="#arrayNew(1)#" />
	<cfset stMessage = structNew() />
	<cfset stMessage.title = JSStringFormat(attributes.title) />
	<cfset stMessage.message = JSStringFormat(attributes.message) />
	<cfset stMessage.pause = attributes.pause />
	<cfset stMessage.bAutoHide = attributes.bAutoHide />
	<cfset arrayAppend(session.aExtMessages, stMessage) />
	<!------------------ 
	START WEBSKIN
	 ------------------>
	<cfset thisTag.generatedContent = "" />
</cfif>
<cfsetting enablecfoutputonly="false">