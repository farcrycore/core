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
$Header: /cvs/farcry/core/tags/container/container.cfm,v 1.19 2005/10/30 09:12:41 geoff Exp $
$Author: geoff $
$Date: 2005/10/30 09:12:41 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: Displays containers$


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />

<!--- quit tag if running in end mode --->
<cfif thistag.executionmode eq "end">
	<cfexit />
</cfif>

<cfparam name="attributes.label" default="" type="string">
<cfparam name="attributes.objectID" default="">
<cfparam name="attributes.preHTML" default="" type="string">
<cfparam name="attributes.postHTML" default="" type="string">
<cfparam name="attributes.bShowIfEmpty" type="boolean" default="true">
<cfparam name="attributes.defaultMirrorID" default="" type="string"><!--- optional UUID --->
<cfparam name="attributes.defaultMirrorLabel" default="" type="string">

<!--- try and set objectid by looking for request.stobj.objectid --->
<cfif NOT len(attributes.objectid) AND isDefined("request.stobj.objectid")>
	<cfset attributes.objectid=request.stobj.objectid>
</cfif>

<!--- must have at least a label or objectid to lookup container instance --->
<cfif NOT len(attributes.label) AND NOT len(attributes.objectID)>
	<cfthrow type="container" message="Missing parameters: label or objectID is required to invoke a container.">
</cfif>

<!--- TODO: this should be using the factory container object, no? GB --->
<cfset oCon = createObject("component","#application.packagepath#.rules.container")>
<cfset qGetContainer = oCon.getContainer(dsn=application.dsn,label=attributes.label)>
<cfif qGetContainer.recordCount EQ 0>
	<!--- create a new container if one doesn't exist --->
	<!--- if defaultMirror set then look-up and apply --->
	<cfif Len(attributes.defaultMirrorID) AND REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", attributes.defaultmirrorid)>
		<!--- if UUID then lookup container by objectid --->
		<cfset stMirror = oCon.getData(dsn=application.dsn,objectid=attributes.defaultMirrorid)>
		<!--- TODO: if this returns emptystruct then we need to make sure mirror container is created with this UUID GB --->
	<cfelseif Len(attributes.defaultMirrorlabel)>
		<!--- else lookup container by label --->
		<cfset stMirror = oCon.getContainerbylabel(dsn=application.dsn,label=attributes.defaultMirrorlabel)>
	<cfelse>
		<!--- no default mirror specified --->
		<cfset stMirror = StructNew()>
		<cfset stMirror.objectID = "">
	</cfif>

	<!--- create the mirror container if it is specified but missing --->
	<cfif NOT StructKeyExists(stMirror, "objectid")>
		<!--- create the default mirror container --->
		<cfset stMirror = StructNew()>
		<cfset stMirror.objectid = application.fc.utils.createJavaUUID()>
		<cfset stMirror.label = attributes.defaultmirrorlabel>
		<cfif Len(stMirror.label) EQ 0>
			<cfset stMirror.label="Mirror Container: #stMirror.objectid#">
		</cfif>

		<cfset stMirror.mirrorid = "">
		<cfset stMirror.bShared = 1>
		<cfset oCon.createData(dsn=application.dsn,stProperties=stMirror)>
	</cfif>

	<!--- set default container properties --->
	<cfset stProps = structNew()>
	<cfset stProps.objectid = application.fc.utils.createJavaUUID()>
	<cfset stProps.label = attributes.label>
	<cfset stProps.mirrorid = stmirror.objectid>
	<cfset stProps.bShared = 0>
	<cfset containerID = stProps.objectID>
	<cfset oCon.createData(dsn=application.dsn, stProperties=stProps, parentobjectid=attributes.objectid)>
<cfelse>
	<cfset containerID = qGetContainer.objectID>
</cfif>

<!--- get the container data --->
<cfset stConObj = oCon.getData(dsn=application.dsn,objectid=containerid)>
<!--- if a mirrored container has been set then reset the container data --->
<cfif (StructKeyExists(stConObj, "mirrorid") AND Len(stConObj.mirrorid))>
	<cfset stOriginal = stConObj />
	<cfset stConObj = oCon.getData(dsn=application.dsn,objectid=stConObj.mirrorid)>
<cfelse>
	<cfset stOriginal = structnew() />
</cfif>

<!--- quit tag if running in end mode --->
<cfif thistag.executionmode eq "end">
	<cfexit />
</cfif>

<cfif request.mode.design and request.mode.showcontainers gt 0>
	<cfif not structisempty(stOriginal)>
		<cfoutput><div id="#replace(stOriginal.objectid,'-','','ALL')#"></cfoutput>
	<cfelse>
		<cfoutput><div id="#replace(stConObj.objectid,'-','','ALL')#"></cfoutput>
	</cfif>
</cfif>

<!--- Used by rules to reference the container they're a part of --->
<cfif structisempty(stOriginal)>
	<cfset request.thiscontainer = stConObj.objectid />
<cfelse>
	<cfset request.thiscontainer = stOriginal.objectid />
</cfif>

<cfif structkeyexists(form,"container")>
	<cfset url.container = form.container />
</cfif>
<cfparam name="url.container" default="" />

<cfif structkeyexists(form,"rule_action")>
	<cfset url.rule_action = form.rule_action />
	<cfset url.rule_id = form.rule_id />
	<cfset url.rule_index = form.rule_index />
	<cfif isdefined("form.confirm")>
		<cfset url.confirm = form.confirm />
	</cfif>
</cfif>

<con:isolate active="#request.mode.ajax and url.container eq request.thiscontainer#">
	
<!--- display edit widget --->
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<skin:view stObject="#stConObj#" webskin="displayAdminToolbar" alternatehtml="" original="#stOriginal#" />
	
	<cfif structkeyexists(url,"rule_action") and structkeyexists(url,"rule_id") and structkeyexists(url,"rule_index") and url.rule_index lte arraylen(stConObj.aRules)>
		<cfset redirecturl = "#cgi.script_name#" />
		<cfif isdefined("url.objectid")>
			<cfset redirecturl = "#redirecturl#?objectid=#url.objectid#" />
		<cfelseif isdefined("url.type") and isdefined("url.view")>
			<cfset redirecturl = "#redirecturl#?type=#url.type#&view=#url.view#" />
		</cfif>
		
		<cfswitch expression="#url.rule_action#">
			<cfcase value="moveup">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id and url.rule_index gt 1>
					<cfset temp = stConObj.aRules[url.rule_index] />
					<cfset stConObj.aRules[url.rule_index] = stConObj.aRules[url.rule_index-1] />
					<cfset stConObj.aRules[url.rule_index-1] = temp />
					<cfset oCon.setData(stProperties=stConObj) />
					<extjs:bubble title="Container management"><cfoutput>The rule has been moved up</cfoutput></extjs:bubble>
					<cfif not request.mode.ajax>
						<cflocation url="#redirecturl#" />
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="movedown">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id and url.rule_index lt arraylen(stConObj.aRules)>
					<cfset temp = stConObj.aRules[url.rule_index] />
					<cfset stConObj.aRules[url.rule_index] = stConObj.aRules[url.rule_index+1] />
					<cfset stConObj.aRules[url.rule_index+1] = temp />
					<cfset oCon.setData(stProperties=stConObj) />
					<extjs:bubble title="Container management"><cfoutput>The rule has been moved down</cfoutput></extjs:bubble>
					<cfif not request.mode.ajax>
						<cflocation url="#redirecturl#" />
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="delete">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id>
					<cfif structkeyexists(url,"confirm") and url.confirm eq "true">
						<cfset oFourq = createObject("component", "farcry.core.packages.fourq.fourq") />
						<cfset oRule = createObject("component", application.stcoapi[oFourq.findType(objectid=url.rule_id)].packagepath) />
						<cfset oRule.delete(objectid=url.rule_id) />
						<cfset arraydeleteat(stConObj.aRules,url.rule_index) />
						<cfset oCon.setData(stProperties=stConObj) />
						<extjs:bubble title="Container management"><cfoutput>The rule has been deleted</cfoutput></extjs:bubble>
						<cfif not request.mode.ajax>
							<cflocation url="#redirecturl#" />
						</cfif>
					<cfelseif structkeyexists(url,"confirm") and url.confirm eq "false">
						<extjs:bubble title="Container management"><cfoutput><p class="success">Deletion has been canceled</p></cfoutput></extjs:bubble>
						<cflocation url="#redirecturl#" />
					<cfelse>
						<cfoutput>
							<script type="text/javascript">
								if (window.confirm(Are you sure you want to delete this rule?))
									window.location = "#redirecturl#&rule_id=#url.rule_id#&rule_index=#url.rule_index#&rule_action=delete&confirm=true";
								else
									window.location = "#redirecturl#&rule_id=#url.rule_id#&rule_index=#url.rule_index#&rule_action=delete&confirm=false";"
							</script>
						</cfoutput>
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	</cfif>
</cfif>

<cfif arrayLen(stConObj.aRules)>

	<!--- delay the populate so we can see the content --->
	<cfsavecontent variable="conOutput">
		<cfset oCon.populate(aRules=stConObj.aRules)>
	</cfsavecontent>

	<!--- output if conOutput is not empty or the bShowIfEmpty attribute is set to true --->
	<cfparam name="stConObj.displayMethod" default="">
	<cfif len(stConObj.displayMethod)>
		<cfset oCon.getDisplay(containerBody=conOutput,template=stConObj.displayMethod)>		
	<cfelseif Len(Trim(conOutput)) OR attributes.bShowIfEmpty>
		<cfif attributes.preHTML NEQ "">
			<cfoutput>#attributes.preHTML#</cfoutput>
		</cfif>
		<cfoutput>#conOutput#</cfoutput>
		
		<cfif attributes.postHTML NEQ "">
			<cfoutput>#attributes.postHTML#</cfoutput>
		</cfif>
	</cfif>
</cfif>

</con:isolate>

<cfset structdelete(request,"thiscontainer") />

<cfif request.mode.design and request.mode.showcontainers gt 0>
	<cfoutput></div></cfoutput>
</cfif>