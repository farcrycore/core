<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/scopeDump.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Scope dumper$


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

	
	<form method="post" class="f-wrap-1 f-bg-short" action="">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].scopeDump#</h3>
		
		<label for="permname"><b>Choose scope:</b>
		<select name="scope">
			<option value="application" <cfif isdefined("form.scope") and form.scope eq "application">selected</cfif>>#application.adminBundle[session.dmProfile.locale].application#</option>
			<option value="request" <cfif isdefined("form.scope") and form.scope eq "request">selected</cfif>>#application.adminBundle[session.dmProfile.locale].request#</option>
			<option value="session" <cfif isdefined("form.scope") and form.scope eq "session">selected</cfif>>#application.adminBundle[session.dmProfile.locale].session#</option>
			<option value="server" <cfif isdefined("form.scope") and form.scope eq "server">selected</cfif>>#application.adminBundle[session.dmProfile.locale].server#</option>
		</select><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].dump#" class="f-submit" />
		</div>
		
		</form>
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