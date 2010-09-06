<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
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
$Header: /cvs/farcry/core/webtop/navajo/container_skins.cfm,v 1.1.2.1 2006/02/14 03:38:40 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/14 03:38:40 $
$Name: milestone_3-0-1 $
$Revision: 1.1.2.1 $ 

|| DESCRIPTION || 
$Description: Container management editing interface, this page is specifically for managing display methods for containers $

|| DEVELOPER ||
$Developer: Paul Harrison (paul@enpresiv.com) $
--->
<cfparam name="containerID" default="">
<cfparam name="errormessage" default="">
<cfparam name="successmessage" default="">

<cfscript>
if (isDefined("form.formSubmitted"))
{
	form.objectid=containerid;
	oCon.setData(form);
	successmessage = "<p><strong>Display method has been updated</strong></p>";
	stObj = oCon.getData(dsn=application.dsn,objectid=containerid);
}
</cfscript>	
<cfsetting enablecfoutputonly="false">
<cfoutput>

<form name="frm" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2">
	<fieldset>
	<cfif errormessage NEQ ""> <!--- display error --->
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	<cfelse> <!--- all good show form --->

		<p>Select a container display method to surround your container content:</p>
	
		<cfif successmessage NEQ "">
		<p id="fading2" class="fade"><span class="success">#successmessage#</span></p></cfif>
	
		<label for="displayMethod"><b>Skin:</b>
			<select name="displayMethod">
			<option value="">None</option>
			<cfloop query="qContainerSkins">
			<option value="#qContainerSkins.methodname#"<cfif stObj.displayMethod IS qContainerSkins.methodName> selected="selected"</cfif>>#qContainerSkins.displayname#</option>
			</cfloop>
			</select><br />
		</label>
		<div class="f-submit-wrap">
		<input type="submit" name="submit" value="Update Container Skin" class="f-submit" />
		</div>
		<input type="hidden" name="formSubmitted" value="yes" />
	</cfif>
	</fieldset>
</form>
</cfoutput>

