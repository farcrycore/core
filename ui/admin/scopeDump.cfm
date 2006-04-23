<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/scopeDump.cfm,v 1.3 2003/04/28 23:46:00 brendan Exp $
$Author: brendan $
$Date: 2003/04/28 23:46:00 $
$Name: b131 $
$Revision: 1.3 $

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

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfoutput>
<span class="FormTitle">Scope Dump</span>
<p></p>
<form action="" method="post">
	<select name="scope">
		<option value="application" <cfif isdefined("form.scope") and form.scope eq "application">selected</cfif>>Application
		<option value="request" <cfif isdefined("form.scope") and form.scope eq "request">selected</cfif>>Request
		<option value="session" <cfif isdefined("form.scope") and form.scope eq "session">selected</cfif>>Session
		<option value="server" <cfif isdefined("form.scope") and form.scope eq "server">selected</cfif>>Server
	</select>
	<input type="submit" value="Dump">
</form><p></p>
</cfoutput>

<cfif isdefined("form.scope")>
	<cfdump var="#evaluate(form.scope)#" label="#form.scope# scope">
</cfif>			
<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">