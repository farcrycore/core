<cfoutput>
<p>This verity config has been deprecated.</p>
<p>Please use Admin : Verity Managemnet : Verity Config</p>
</cfoutput>
<cfabort>

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/config_verity.cfm,v 1.10.2.1 2006/04/19 00:45:50 geoff Exp $
$Author: geoff $
$Date: 2006/04/19 00:45:50 $
$Name: p300_b113 $
$Revision: 1.10.2.1 $

|| DESCRIPTION || 
$DESCRIPTION: Verity config edit handler$

$TODO: 
lot of work here.. taking ownership and band-aiding for now to allow for new functionality.
Will look to sweep through when we revamp config to a bona fide content type 20060415 GB
$
 
|| DEVELOPER ||
$DEVELOPER: Geoff Bowers (modius@daemon.com.au)$
--->

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<sec:CheckPermission error="true" permission="AdminGeneralTab">
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
	
			<form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="update">
			<input type="Hidden" name="stName" value="#url.configName#">
			
			<ul class="nomarker"></cfoutput>
			
			<!--- loop through all application types --->
			<cfloop collection="#application.types#" item="typeName">
				<cfoutput>
				<li>
					<a href="javascript:void(0);" onclick="showHide('#typename#','#typename#-a');return false;"><img id="#typename#-a" style="margin-bottom:-5px" src="../images/icons/xsmall/expand.png" alt="" /></a> <a href="javascript:void(0);" onclick="showHide('#typename#','#typename#-a');return false;">#typename#</a>
					
					<ul id="#typename#" style="display:none;margin: 5px 0 15px 25px" class="nomarker"> 
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
					<li><label for="type--#typename#--#field#"><input class="f-checkbox" type="checkbox" name="type--#typename#--#field#" id="type--#typename#--#field#" <cfif checked>checked="checked"</cfif> /> #field#</label></li>
						</cfoutput>
					</cfif>
				</cfloop>
				
				<cfoutput>
					</ul>
				</li>
				</cfoutput>
			</cfloop>
			
			<cfoutput>
			</ul>
	
			<h3>#application.adminBundle[session.dmProfile.locale].externalFileCollection#</h3>
	
			<table id="files" class="table-4" cellspacing="0">
			<!--- allow for new file collection to be added --->
			<input type="hidden" name="file__filecol" value="extFiles">
			<tr>
				<th class="alt">#application.adminBundle[session.dmProfile.locale].UNCpath#</th>
				<td><input type="text" size="50" name="file__uncpath" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles")>value="#application.config.verity.contenttype.extFiles.aprops.uncpath#"</cfif>></td>
			</tr>
			<tr>
				<th class="alt">#application.adminBundle[session.dmProfile.locale].recursive#</th>
				<td><input type="checkbox" class="f-checkbox" name="file__recursive" value="#application.adminBundle[session.dmProfile.locale].yes#" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles") and application.config.verity.contenttype.extFiles.aprops.recursive eq "yes">checked</cfif>></td>
			</tr>
			<tr>
				<th class="alt">File Types allowed</th>
				<td><input type="text" name="file__filetypes" <cfif structKeyExists("#application.config.verity.contenttype#", "extFiles")>value="#application.config.verity.contenttype.extFiles.aprops.fileTypes#"</cfif>> eg .pdf,.doc</td>
			</tr>
			<tr>
				<th class="alt">&nbsp;</th>
				<td><input type="submit" value="#application.adminBundle[session.dmProfile.locale].updateConfig#" class="f-submit" /></td>
			</tr>
			</table>
			</form>
			
			<hr />
			</cfoutput>
			
		</cfcase>	
	</cfswitch>
</sec:CheckPermission>
