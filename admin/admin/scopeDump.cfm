<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/scopeDump.cfm,v 1.4 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Scope dumper$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>

	<cfoutput>
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].scopeDump#</span>
	<p></p>
	<form action="" method="post">
		<select name="scope">
			<option value="application" <cfif isdefined("form.scope") and form.scope eq "application">selected</cfif>>#application.adminBundle[session.dmProfile.locale].application#
			<option value="request" <cfif isdefined("form.scope") and form.scope eq "request">selected</cfif>>#application.adminBundle[session.dmProfile.locale].request#
			<option value="session" <cfif isdefined("form.scope") and form.scope eq "session">selected</cfif>>#application.adminBundle[session.dmProfile.locale].session#
			<option value="server" <cfif isdefined("form.scope") and form.scope eq "server">selected</cfif>>#application.adminBundle[session.dmProfile.locale].server#
		</select>
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].dump#">
	</form><p></p>
	</cfoutput>
	
	<cfif isdefined("form.scope")>
		<cfdump var="#evaluate(form.scope)#" label=" #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].scopeLabel,'#form.scope#')#">
	</cfif>			

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">