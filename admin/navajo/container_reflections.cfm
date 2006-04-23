<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/container_reflections.cfm,v 1.4 2005/10/31 04:10:52 guy Exp $
$Author: guy $
$Date: 2005/10/31 04:10:52 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $ 

|| DESCRIPTION || 
$Description: Container management editing interface, this page is specificall for listing the availables and selected rules for this container only. $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->
<cfparam name="containerID" default="">
<cfparam name="errormessage" default="">
<cfparam name="formSubmitted" default="no">
<cfparam name="reflectionid" default="">
<cfparam name="successmessage" default="">

<cfif formSubmitted EQ "yes">
	<cfif Trim(reflectionid) EQ ""> <!--- delete the reflection id --->
		<cfset oCon.deleteReflection(objectid=containerID)>
	<cfelse> <!--- set the reflection id --->
		<cfset oCon.setReflection(objectid=containerID,mirrorid=reflectionid)>
	</cfif>
	<cfset successmessage = successmessage & "Updated Container reflection.<br />">
	<cfset stObj.mirrorID = Trim(reflectionid)>
	<cfset oCon.setData(stproperties=stObj)>
	<cfif Trim(reflectionid) EQ "">
		<cflocation url="#cgi.script_name#?#cgi.query_string#" addtoken="false">
		<cfabort>
	</cfif>
</cfif>

<!--- check if container and mirror object is valid struct --->
<cfif StructIsEmpty(stObj)>
	<cfset errormessage = errormessage & "Incorrect ContainerID.<br />">
<cfelse>
	<cfif stobj.mirrorid NEQ "">
		<cfset stMirror = oCon.getReflection(mirrorid=stobj.mirrorid, containerid=containerid)>
		<cfif StructIsEmpty(stMirror)>
			<cfset errormessage = errormessage & "Incorrect MirrorID.<br />">
		</cfif>	
	</cfif>
</cfif>
<cfset qListReflections = oCon.getSharedContainers()>
<cfsetting enablecfoutputonly="false"><cfoutput>
<!--- form for the rule selection only --->
<form name="frm" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2">
	<fieldset>
	<cfif errormessage NEQ ""> <!--- display error --->
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	<cfelse> <!--- all good show form --->
		<cfif isDefined("stMirror.objectid")>
		<p>This container is mirroring the content of another container:<br /> &nbsp; &raquo; #stmirror.label#<br /><cfelse>
		This container is unique for this page.</p>
		</cfif>
		<p>Choose a shared container to be used for this container instance.  
		This will override the unique container settings and use the mirrored container instead.</p>
		
		<p>Select NO REFLECTIONS to remove container mirroring</p>
	
		<cfif successmessage NEQ "">
		<p id="fading2" class="fade"><span class="success">#successmessage#</span></p></cfif>
	
		<label for="reflectionid"><b>Relection:</b>
			<select id="reflectionid" name="reflectionid">
				<option value=""<cfif stObj.mirrorid EQ ""> selected="selected"</cfif>>no reflections</option><cfloop query="qListReflections">
				<option value="#qListReflections.objectid#"<cfif stObj.mirrorid EQ qListReflections.objectid> selected="selected"</cfif>>#qListReflections.label#</option></cfloop>
			</select><br />
		</label>
		<div class="f-submit-wrap">
		<input type="submit" name="submit" value="Update Reflection Details" class="f-submit" />
		</div>
	<!--- <input type="hidden" name="containerID" value="#containerID#"> --->
	<input type="hidden" name="formSubmitted" value="yes" />
	</cfif>
	</fieldset>
</form></cfoutput>

