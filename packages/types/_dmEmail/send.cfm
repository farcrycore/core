<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/send.cfm,v 1.4 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmEmail Send Handler $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out: $
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<!--- build send to structure --->
<cfset stSendList = structNew()>

<!--- get users in selected groups --->
<cfobject component="#application.packagepath#.security.authorisation" name="oAuthorisation">
<cfset aUsers = oAuthorisation.getPolicyGroupUsers(stObj.lGroups)>

<!--- get profiles of users and add to send structure if active and has email address --->
<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
    <cfscript>
	    o_profile = createObject("component", application.types.dmProfile.typePath);
	    stProfile = o_profile.getProfile(aUsers[i]);
		if (not structIsEmpty(stProfile) AND stProfile.bActive AND len(stProfile.emailAddress)) stSendList[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>

<cftry>
	<!--- loop over send to list and email --->
	<cfloop collection="#stSendList#" item="to">
<cfmail from="#stObj.fromEmail#" to="#stSendList[to].emailAddress#" subject="#stObj.title#" failto="#stobj.failto#"  replyto="#stobj.replyto#" charset="#stobj.charset#" >
<cfif trim(len(stObj.body))>
<cfmailpart type="text">
#stObj.body#
</cfmailpart>
</cfif>
<cfif trim(len(stObj.htmlbody))>
<cfmailpart type="html">
#stobj.htmlbody#
</cfmailpart>
</cfif>
</cfmail>
	</cfloop>
	
	<cfscript>
		// flag email as sent
		stProperties = Duplicate(stObj);
		stProperties.bsent = 1;
		stProperties.datetimelastupdated = now();
		stProperties.datetimecreated = createodbcdatetime(stObj.datetimecreated);
	
		// update the OBJECT	
		oType = createobject("component", application.types.dmEmail.typePath);
		oType.setData(stProperties=stProperties,auditNote="Email sent");
	</cfscript>
		
	<cfcatch><cfdump var="#cfcatch#"><cfabort></cfcatch>
</cftry>	

<!--- return to email listing --->
<cflocation url="#application.url.farcry#/admin/messageCentre.cfm" addtoken="no">

<cfsetting enablecfoutputonly="no">
