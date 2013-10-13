<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmEmail.cfc,v 1.4 2005/09/02 06:27:36 guy Exp $
$Author: guy $
$Date: 2005/09/02 06:27:36 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION ||
$Description: Email object. Allows administrators to send an email to members of FarCry Groups. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
---> 

<cfcomponent extends="farcry.core.packages.types.types" displayname="Emails" hint="Email management object that allows emails to be sent to farcry groups" bCustomType="true" bRefObjects="false">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftFieldSet="General Info" ftWizardStep="Start" name="Title" type="string" hint="Title of object." required="no" default="" ftLabel="Subject">
<cfproperty ftSeq="2" ftFieldSet="General Info" ftWizardStep="Start" name="lGroups" type="string" hint="FarCry Groups to send email to" required="no" default="" ftLabel="To" ftType="list" ftListData="getGroups" ftSelectMultiple="true">
<cfproperty ftSeq="3" ftFieldSet="General Info" ftWizardStep="Start" name="fromEmail" type="string" hint="From email address" required="no" default="" ftLabel="From Email Address">
<cfproperty ftSeq="10" ftFieldSet="Advanced Options" ftWizardStep="Advanced Options" name="replyTo" type="string" hint="Address(es) to which the recipient is directed to send replies" required="no" default="" ftLabel="Reply To Address">
<cfproperty ftSeq="11" ftFieldSet="Advanced Options" ftWizardStep="Advanced Options" name="failTo" type="string" hint="Address to which mailing systems should send delivery failure notifications. Sets the mail envelope reverse path value" required="no" default="" ftLabel="Fail To Address">
<cfproperty ftSeq="12" ftFieldSet="Advanced Options" ftWizardStep="Advanced Options" name="wraptext" type="string" hint="Specifies the maximum line length, in characters of the mail text." required="no" default="" ftLabel="Wraptext">
<cfproperty ftSeq="13" ftFieldSet="Advanced Options" ftWizardStep="Advanced Options" name="charset" type="string" hint="Character encoding of the mail message, including the headers" required="no" default="UTF-8" ftDefault="UTF-8" ftLabel="Charset">
<cfproperty ftSeq="20" ftFieldSet="Body" ftWizardStep="Body" name="Body" type="longchar" hint="Main body of content, text only." required="no" default="" ftLabel="Body">
<cfproperty ftSeq="30" ftFieldSet="HTML Body" ftWizardStep="HTML Body" name="htmlBody" type="longchar" hint="Main body of content, to be sent to users as HTML" required="no" default="" ftLabel="HTML Body" ftType="richtext" >
<cfproperty name="bSent" type="boolean" hint="Flag for email being sent" required="yes" default="0">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	

<cffunction name="display" access="public" output="true" hint="Primary display handler for the object.">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object display --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEmail/display.cfm">
</cffunction>

<cffunction name="send" access="public" output="true" hint="Prepares and sends email to members">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object display --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEmail/send.cfm">
</cffunction>

<cffunction name="getAllObjects" access="public" output="false" hint="Gets all emails">
	
	<cfset var qEmails	= '' />
	
	<!--- get emails --->
	<cfquery name="qEmails" datasource="#application.dsn#">
		SELECT *
		FROM dmEmail
	</cfquery>
	
	<cfreturn qEmails>
</cffunction>


<cffunction name="getGroups" access="public" output="false" returntype="string" hint="returns all groups to send emails to">

	<cfset var aPolicyGroups = application.factory.oAuthorisation.getAllPolicyGroups() />
	<cfset var lPolicyGroups = "" />
	<cfset var group	= '' />
	
	<cfloop from="1" to="#arrayLen(aPolicyGroups)#" index="group">
		<cfset lPolicyGroups = listAppend(lPolicyGroups, "#aPolicyGroups[group].PolicyGroupId#:#aPolicyGroups[group].PolicyGroupName#")>
	</cfloop>
	
	<cfreturn lPolicyGroups />
</cffunction>
</cfcomponent>
