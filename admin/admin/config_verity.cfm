<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/config_verity.cfm,v 1.5 2004/07/27 04:07:39 brendan Exp $
$Author: brendan $
$Date: 2004/07/27 04:07:39 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$DESCRIPTION: Verity config edit handler$
$TODO: $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<cfif iGeneralTab eq 1>
<cfswitch expression="#form.action#">

	<cfcase value="update">
		<!--- ### update verity config ### --->
		<cfset stTemp = structNew()>
		<cfset stTempFile = structNew()>
		<!--- loop over form fields and build structure of new config--->
		<cfloop list="#form.fieldnames#" index="i">
			<!--- check form fields aren't hidden values past and are actually config elements --->
			<!--- type verity collections --->
			<cfif i neq "action" and listGetAt(i,1,"--") eq "type">
				
				<!--- derive type from form field --->
				<cfset type = listgetat(i,2,"--")>
				<!--- check temp array for type exists --->
				<cfif structkeyexists(stTemp,"#type#")>
					<!--- add field to existing type array --->
					<cfset temp = arrayappend(stTemp[type],listgetat(i,3,"--"))>
				<cfelse>
					<!--- set up new array for type --->
					<cfset stTemp[type] = arrayNew(1)>
					<!--- add field to type array --->
					<cfset temp = arrayappend(stTemp[type],listgetat(i,3,"--"))>
				</cfif>
			<!--- file verity collections --->
			<cfelseif i neq "action" and listGetAt(i,1,"--") eq "file">
				
			</cfif>
		</cfloop>
		
		<cfif len(form.file__filecol)>
			<!--- file verity collections --->
			<cfparam name="form.file__recursive" default="no">
			
			<cfset stTempFile = structNew()>
			<cfset stTempFile[form.file__fileCol] = structNew()>
			<cfset stTempFile[form.file__fileCol].recursive = form.file__recursive>
			<cfset stTempFile[form.file__fileCol].uncPath = form.file__uncpath>
			<cfset stTempFile[form.file__fileCol].fileTypes = form.file__fileTypes>
		</cfif>			
		
		<!--- ### update existing config ### --->
		<!--- delete current setup --->
		<cfloop collection="#application.config.verity.contenttype#" item="typeName">
			<cfset temp = structDelete(application.config.verity.contenttype,typeName)>
		</cfloop>
		<!--- reset aIndices array --->
		<cfset application.config.verity.aindices = arrayNew(1)>
		
		<!--- loop over temp structure --->
		<cfloop collection="#stTemp#" item="typeName">
			<!--- check type exists in current config --->
			<cfif structkeyexists(evaluate('application.config.verity.contenttype'),"#typeName#")>
				<!--- update current config --->
				<cfset "application.config.verity.contenttype.#typeName#.aprops" = stTemp[typeName]>
			<cfelse>
				<!--- create config entry for type --->
				<cfset "application.config.verity.contenttype.#typeName#" = structNew()>
				<cfset "application.config.verity.contenttype.#typeName#.aprops" = stTemp[typeName]>
			</cfif>
			<!--- update aIndicies array --->
			<cfset temp = arrayappend(application.config.verity.aIndices, "#application.applicationname#_#typeName#")>
		</cfloop>
		
		<!--- loop over temp file collection structure --->
		<cfif isdefined("stTempFile")>
			<cfloop collection="#stTempFile#" item="fileCollectionName">
				<!--- check file collection exists in current config --->
				<cfif structkeyexists(evaluate('application.config.verity.contenttype'),"#fileCollectionName#")>
					<!--- update current config --->
					<cfset "application.config.verity.contenttype.#fileCollectionName#.aprops" = stTempFile[fileCollectionName]>
				<cfelse>
					<!--- create config entry for file collection --->
					<cfset "application.config.verity.contenttype.#fileCollectionName#" = structNew()>
					<cfset "application.config.verity.contenttype.#fileCollectionName#.aprops" = stTempFile[fileCollectionName]>
				</cfif>
				<!--- update aIndicies array --->
				<cfset temp = arrayappend(application.config.verity.aIndices, "#application.applicationname#_#fileCollectionName#")>
			</cfloop>
		</cfif>
		<!--- duplicate structure to send to database --->
		<cfset stTemp = duplicate(application.config.verity)>
	</cfcase>
		
		
	<cfcase value="none">
	
		<cfset stTemp = evaluate('application.config.#url.configName#.contenttype')>
						
		<cfoutput>
		<p></p>
		<form action="#cgi.script_name#" method="post">
		<input type="Hidden" name="action" value="update">
		<input type="Hidden" name="stName" value="#url.configName#">
		
		<table></cfoutput>
		
		<!--- loop through all application types --->
		<cfloop collection="#application.types#" item="typeName">
			<cfoutput>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="2">
					<div>
						<span class="frameMenuBullet">&raquo;</span> <a href="javascript:void(0);" id="show#typename#" onClick="document.getElementById('#typename#').style.display='block';document.getElementById('show#typename#').style.visibility='hidden';document.getElementById('hide#typename#').style.visibility='visible'" style="position:absolute;">#typename#</a>
						<a href="##top" id="hide#typename#" onClick="document.getElementById('#typename#').style.display='none';document.getElementById('show#typename#').style.visibility='visible';document.getElementById('hide#typename#').style.visibility='hidden'" style="position:absolute;visibility:hidden">#typename#</a>
					</div>
				</td>
			</tr>
			<tr>
				<td colspan="2">
				<table id="#typename#" style="display:none;margin-top:5px;">
			</cfoutput>
				
			<!--- loop through these types and look at each field --->
			<cfloop collection="#application.types[typeName].stProps#" item="Field">
			
				<!--- check fields aren't of type array or uuid and aren't derived from types.types --->
				<cfif application.types[typeName].stProps[field].metaData.type neq "array"
					and application.types[typeName].stProps[field].metaData.type neq "UUID"
					and findnocase("types.types",application.types[typeName].stProps[field].origin) eq 0>
			
					<!--- check against config setup --->
					<cfset checked = false>
					<cfif structkeyexists(evaluate('application.config.verity.contenttype'),"#typeName#")>
						<cfset temp = arraytolist(evaluate('application.config.verity.contenttype.#typeName#.aprops'))>
						<cfif listcontainsnocase(temp,#field#) gt 0>
							<cfset checked = true>
						</cfif>
					</cfif>
					
					<!--- display check box to add field to verity setup --->
					<cfoutput>
					<tr>
						<td><input type="checkbox" name="type--#typename#--#field#" <cfif checked>checked</cfif>></td>
						<td>#field#</td>
					</tr>
					</cfoutput>
				</cfif>
				
			</cfloop>
			
			<cfoutput>
			</table>
			</td>
			</tr>
			</cfoutput>
		</cfloop>
		
		<cfoutput>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		</table>
		<p></p>
		
		
		<strong>#application.adminBundle[session.dmProfile.locale].externalFileCollection#</strong>
		<p></p>
		<table id="files">
		<!--- allow for new file collection to be added --->
		<input type="hidden" name="file__filecol" value="extFiles">
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].UNCpath#</td>
			<td><input type="text" size="50" name="file__uncpath" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles")>value="#application.config.verity.contenttype.extFiles.aprops.uncpath#"</cfif>></td>
		</tr>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].recursive#</td>
			<td><input type="checkbox" name="file__recursive" value="#application.adminBundle[session.dmProfile.locale].yes#" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles") and application.config.verity.contenttype.extFiles.aprops.recursive eq "yes">checked</cfif>></td>
		</tr>
		<tr>
			<td>File Types allowed</td>
			<td><input type="text" name="file__filetypes" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles")>value="#application.config.verity.contenttype.extFiles.aprops.fileTypes#"</cfif>> eg .pdf,.doc</td>
		</tr>
		</table>
		
		<table>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" value="#application.adminBundle[session.dmProfile.locale].updateConfig#"></td>
		</tr>
		</table>
		</form></cfoutput>
	</cfcase>	
</cfswitch>

<cfelse>
	<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
	<admin:permissionError>
</cfif>