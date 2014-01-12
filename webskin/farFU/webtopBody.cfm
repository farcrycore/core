<cfsetting enablecfoutputonly="true">
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
|| DESCRIPTION ||
$Description: Image library administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<ft:processForm action="edit">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		<cfset stFU = createObject("component", application.stcoapi["farFU"].packagePath).getData(objectid="#form.selectedObjectID#") />
		<cfif len(stFU.refObjectID)>		
			<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#stFU.refObjectID#") />	
			<cfif not structIsEmpty(stRefObject)>
				<cfset EditURL = "#application.url.webtop#/conjuror/invocation.cfm?objectid=#stRefObject.objectid#&typename=#stRefObject.typename#&method=edit&ref=extjsIFrame">
				<skin:onReady>
					<cfoutput>
					$fc.openDialogIFrame('Edit', '#EditURL#');
					</cfoutput>
				</skin:onReady>
				<cfset form.FARCRYFORMSUBMITTED = "" />
				<cfset form.FARCRYFORMSUBMITBUTTON = "" />	
			</cfif>
		</cfif>
	</cfif>
	<!--- CANCEL REGULAR OVERVIEW PROCESSING --->
	<cfset form.FARCRYFORMSUBMITTED = "" />
	<cfset form.FARCRYFORMSUBMITBUTTON = "" />
</ft:processForm>
<ft:processForm action="overview">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		<cfset stFU = createObject("component", application.stcoapi["farFU"].packagePath).getData(objectid="#form.selectedObjectID#") />
		<cfif len(stFU.refObjectID)>		
			<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#stFU.refObjectID#") />			
			<cfif not structIsEmpty(stRefObject)>
				<cfset EditURL = "#application.url.webtop#/edittabOverview.cfm?objectid=#stRefObject.objectid#&typename=#stRefObject.typename#&method=edit&ref=extjsIFrame">
				<skin:onReady>
					<cfoutput>
					$fc.openDialogIFrame('Edit', '#EditURL#');
					</cfoutput>
				</skin:onReady>
			</cfif>	
		</cfif>
	</cfif>
	<!--- CANCEL REGULAR OVERVIEW PROCESSING --->
	<cfset form.FARCRYFORMSUBMITTED = "" />
	<cfset form.FARCRYFORMSUBMITBUTTON = "" />
</ft:processForm>



<cfset stFilterMetaData = structNew() />
<cfset stFilterMetaData.refObjectID = StructNew() />
<cfset stFilterMetaData.refObjectID.ftType = "string" />
<cfset stFilterMetaData.fuStatus = StructNew() />
<cfset stFilterMetaData.fuStatus.ftType = "list" />
<cfset stFilterMetaData.fuStatus.ftList = ":ALL,1:System Generated,2:Custom,0:Archived" />
<cfset stFilterMetaData.fuStatus.ftDefault = "" />

<cfset aCustomColumns = arraynew(1) />

<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].title = "Object" />
<cfset aCustomColumns[1].sortable = false />
<cfset aCustomColumns[1].property = "refobjectid" />
<cfset aCustomColumns[1].webskin = "objectAdminRefObject" />


<ft:objectadmin
	typename="farFU"
	columnList="friendlyURL,queryString,fuStatus,bDefault,redirectionType,redirectTo" 
	aCustomColumns="#aCustomColumns#" 
	sortableColumns="fuStatus"
	lFilterFields="refobjectid,friendlyURL,fuStatus"
	bPreviewCol="false"
	sqlorderby="friendlyURL"
	stFilterMetaData="#stFilterMetaData#" />


<cfsetting enablecfoutputonly="false">