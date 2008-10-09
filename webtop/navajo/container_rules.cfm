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
$Header: /cvs/farcry/core/webtop/navajo/container_rules.cfm,v 1.11 2005/10/27 05:09:23 guy Exp $
$Author: guy $
$Date: 2005/10/27 05:09:23 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $ 

|| DESCRIPTION || 
$Description: Container management editing interface, this page is specificall for listing the availables and selected rules for this container only. $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->
<cfparam name="containerID" default="">
<cfparam name="errormessage" default="">
<cfparam name="formSubmitted_container_rule" default="no">
<cfparam name="dest" default="">
<cfparam name="bAllowUpdateName" default="0">

<cfif FindNoCase("container_edit",cgi.script_name)>
	<cfset bAllowUpdateName = 1>
</cfif>

<cfif containerID NEQ "">
	<!--- get the container data --->
	<cfset stObj = oCon.getData(objectid=containerID)>
	<cfif StructIsEmpty(stObj)>
		<cfset errormessage = errormessage & "Invalid Container ID: [#containerID#]">
	</cfif>
	
	<cfif formSubmitted_container_rule EQ "yes" AND errormessage EQ ""> <!--- form is submitted --->
		<!--- reinit aRules array for re-sequencing  --->
		<cfset stObj.aRules = ArrayNew(1)>
		<cfloop index="i" from="1" to="#ListLen(dest)#">
			<cfset key = listGetAt(dest,i)>
			<cfif NOT IsCFUUID(key)> <!--- Get the properties for this type - and create a rule instance --->
				<cfset obj = createObject("component", application.rules[key].rulePath)>
				<cfset aProps = obj.getProperties()>
				<cfset stProps = StructNew()>
				<cfloop index="j" from="1" to="#ArrayLen(aProps)#">
					<cfif StructKeyExists(aProps[j],"default")>
						<cfset stProps[aProps[j].name] = aProps[j].default>
					</cfif>
				</cfloop>
				<cfset stProps.objectid = CreateUUID()>
				<cfset obj.createData(stProperties=stProps)>
				<cfset ArrayAppend(stObj.aRules,stProps.objectID)>
			<cfelse>
				<cfset ArrayAppend(stObj.aRules,key)>
			</cfif>
		</cfloop>
		<cfset stObj.label = label>
		<!--- update the container object --->
		<cfset oCon.setData(stProperties=stObj)>

		<cflocation url="#cgi.script_name#?containerid=#containerID#&section=container_contents" addtoken="false">
		<cfabort>
	</cfif>

	<cfset qRules = oRules.getRules()>
	<cfset qActiveRules = queryNew("objectID,typename")>
	<cfloop index="i" from="1" to="#arrayLen(stObj.aRules)#">
		<cfset queryAddRow(qActiveRules,1)>
		<cfset ruletype = oCon.findType(objectid=stObj.aRules[i])>
		<cfset querySetCell(qActiveRules,"objectID",stObj.aRules[i])>
		<cfset querySetCell(qActiveRules,"typename",ruletype)>
	</cfloop>
<cfelse>
	<cfset errormessage = errormessage & "Invalid Container ID: [not passed]">
</cfif>

<cfsetting enablecfoutputonly="false"><cfoutput>
<cfinclude template="../includes/editcontainer_js.cfm">
<script type="text/javascript">
function doSubmit(objForm){
// clean up functions
objSelect = objForm.dest;

for(i=0;i < objSelect.length;i++)
	objSelect.options[i].selected = true;
}
</script>

<form name="frm" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" onsubmit="return doSubmit(document.frm);">
	<fieldset>
<cfif errormessage NEQ ""> <!--- display error --->
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
<cfelse> <!--- all good show form --->
	<cfif bAllowUpdateName>
	<label for="label"><b>#application.rb.getResource("containers.labels.title@label","Title")#</b>
		<input type="textbox" name="label" id="label" value="#stobj.label#"><br />
	</label><cfelse>
	<input type="hidden" name="label" value="#stobj.label#"></cfif>

	<label for="source"><b>#application.rb.getResource("containers.labels.availableRuleTypes@label","Available Rule Types")#:</b>
	<select multiple id="source" name="source" size="6" style="width:200px" onchange="renderHint(this.value);"><cfloop query="qRules">
	<option value="#qRules.rulename#"><cfif structKeyExists(application.rules[qRules.rulename],'displayname')>#application.rules[qRules.rulename].displayname#<cfelse>#qRules.rulename#</cfif></option></cfloop>
	</select><br />
	
		<span class="f-toolwrap">
		<!-- TODO: i18n -->
		<input type="button" id="B1" name="B1" value="Move to Active Rules" onmouseover="this.className='f-downarrow f-downarrowhover'" onmouseout="this.className='f-downarrow'" class="f-downarrow" onClick="move(this.form.source,this.form.dest)" style="padding-right:10px" />
		</span>
		
	</label>
	<label for="dest"><b>#application.rb.getResource("containers.labels.activeRules@label","Active Rules")#</b>
	<select multiple name="dest" id="dest" size="6" style="width:200px"><cfloop query="qActiveRules"><!--- need check here for displayname key --->
	<option value="#qActiveRules.objectid#"><cfif structKeyExists(application.stcoapi, qActiveRules.typename)>#application.stcoapi[qActiveRules.typename].displayname#<cfelse>RULE NO LONGER EXISTS(#qActiveRules.typename#)</cfif></option></cfloop>
	</select><br />
		<span class="f-toolwrap">
		<!-- TODO: i18n -->
		<input type="button" value="Move up" onClick="moveindex(this.form.dest.selectedIndex,-1)" onmouseover="this.className='f-uparrow f-uparrowhover'" onmouseout="this.className='f-uparrow'" class="f-uparrow" style="padding-right:81px" />
		<input type="button" value="Move down" onClick="moveindex(this.form.dest.selectedIndex,+1)" onmouseover="this.className='f-downarrow f-downarrowhover'" onmouseout="this.className='f-downarrow'" class="f-downarrow" style="padding-right:65px" />
		<input type="button" value="#application.rb.getResource('containers.buttons.deleteRule@label','Delete Rule')#" onClick="deleteRule(this.form.dest);" onmouseover="this.className='f-delete f-deletehover'" onmouseout="this.className='f-delete'" class="f-delete" style="padding-right:65px" />					 
		</span>
	</label>
	<div class="f-submit-wrap">
	<input type="Submit" name="Update" value="#application.rb.getResource('containers.buttons.commitChanges@label','Commit Changes')#" class="f-submit">
	</div>
</cfif>
	<input type="hidden" name="reflectionID" value="">
	<input type="hidden" name="containerID" value="#containerID#">
	<input type="hidden" name="lSelectedRulesID" value="">
	<input type="hidden" name="formSubmitted_container_rule" value="yes">
</fieldset>

</form></cfoutput>
