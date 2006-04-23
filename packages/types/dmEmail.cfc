<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmEmail.cfc,v 1.4 2005/09/02 06:27:36 guy Exp $
$Author: guy $
$Date: 2005/09/02 06:27:36 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

|| DESCRIPTION ||
$Description: Email object. Allows administrators to send an email to members of FarCry Groups. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
---> 

<cfcomponent extends="farcry.farcry_core.packages.types.types" displayname="Emails" hint="Email management object that allows emails to be sent to farcry groups" bCustomType="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="Title" type="string" hint="Title of object." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content, text only." required="no" default="">
<cfproperty name="htmlBody" type="longchar" hint="Main body of content, to be sent to users as HTML" required="no" default="">
<cfproperty name="lGroups" type="string" hint="FarCry Groups to send email to" required="no" default="">
<cfproperty name="fromEmail" type="string" hint="From email address" required="no" default="">
<cfproperty name="replyTo" type="string" hint="Address(es) to which the recipient is directed to send replies" required="no" default="">
<cfproperty name="wraptext" type="string" hint="Specifies the maximum line length, in characters of the mail text." required="no" default="">
<cfproperty name="bSent" type="boolean" hint="Flag for email being sent" required="yes" default="0">
<cfproperty name="failTo" type="string" hint="Address to which mailing systems should send delivery failure notifications. Sets the mail envelope reverse path value" required="no" default="">
<cfproperty name="charset" type="string" hint="Character encoding of the mail message, including the headers" required="no" default="UTF-8">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true" hint="Editing wizard for entering information.">
	<cfargument name="objectid" required="yes" type="UUID">
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEmail/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true" hint="Primary display handler for the object.">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object display --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEmail/display.cfm">
</cffunction>

<cffunction name="send" access="public" output="true" hint="Prepares and sends email to members">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object display --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEmail/send.cfm">
</cffunction>

<cffunction name="getAllObjects" access="public" output="false" hint="Gets all emails">
	<!--- get emails --->
	<cfquery name="qEmails" datasource="#application.dsn#">
		SELECT *
		FROM dmEmail
	</cfquery>
	
	<cfreturn qEmails>
</cffunction>

</cfcomponent>
