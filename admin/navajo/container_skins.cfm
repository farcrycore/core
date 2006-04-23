<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/container_skins.cfm,v 1.1.2.1 2006/02/14 03:38:40 tlucas Exp $
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
			<option value="#qContainerSkins.methodname#" <cfif stObj.displayMethod IS qContainerSkins.methodName>selected</cfif>>#qContainerSkins.displayname#</option>
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

