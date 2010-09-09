<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/scopeDump.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	<cfoutput>

	
	<form method="post" class="f-wrap-1 f-bg-short" action="">
	<fieldset>
	
		<h3>#application.rb.getResource("general.headings.scopeDump@text","Scope Dump")#</h3>
		
		<label for="permname"><b>Choose scope:</b>
		<select name="scope">
			<option value="application"<cfif isdefined("form.scope") and form.scope eq "application"> selected="selected"</cfif>>#application.rb.getResource("general.constants.application@label","Application")#</option>
			<option value="request"<cfif isdefined("form.scope") and form.scope eq "request"> selected="selected"</cfif>>#application.rb.getResource("general.constants.request@label","Request")#</option>
			<option value="session"<cfif isdefined("form.scope") and form.scope eq "session"> selected="selected"</cfif>>#application.rb.getResource("general.constants.session@label","Session")#</option>
			<option value="server"<cfif isdefined("form.scope") and form.scope eq "server"> selected="selected"</cfif>>#application.rb.getResource("general.constants.server@label","Server")#</option>
		</select><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.rb.getResource('general.labels.dump@label','Dump')#" class="f-submit" />
		</div>
		
		</form>
	</cfoutput>
	
	<cfif isdefined("form.scope")>
		<cfdump var="#evaluate(form.scope)#" label=" #application.rb.formatRBString('general.labels.xscope@label',form.scope,'{1} scope')#">
	</cfif>			
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">