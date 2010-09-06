<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@timeout: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfset setLock(stObj=stObj,locked=true) />


<ft:processForm action="Save,Manage">
	<cfset setLock(stObj=stObj,locked=false) />
	
	<!--- Initialise the new content ID --->
	<cfset newContentID = "" />
	
	<!--- If we already have children, then simply save. --->
	<cfif arraylen(stObj.aObjectIDs)>
		<ft:processFormObjects typename="#stobj.typename#" />
	<cfelse>
		<!--- Here we may have a new child. If we do then we want to redirect to the editing page of that child after saving. --->
		<ft:processFormObjects typename="#stobj.typename#">
			
			<cfif arraylen(stProperties.aObjectIDs)>
				<cfset newContentID = stProperties.aObjectIDs[1] />
			</cfif>
		</ft:processFormObjects>
	</cfif>
</ft:processForm>

<ft:processForm action="Save" bHideForms="true">
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<cfoutput>
		<script type="text/javascript">
			<cfif len(newContentID)>
				location.href = '#application.url.webtop#/edittabEdit.cfm?objectid=#newContentID#&ref=overview&typename=#application.fapi.findType(newContentID)#';
			<cfelse>
				location.href = '#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
			</cfif>
		</script>
	</cfoutput>
</ft:processForm>

<ft:processForm action="Manage" bHideForms="true">
	
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
		
	<cfif structKeyExists(form, "selectedObjectID")>
		<cfoutput>
			<script type="text/javascript">
				location.href = '#application.url.webtop#/edittabOverview.cfm?objectid=#form.selectedObjectID#';
			</script>
		</cfoutput>		
	</cfif>
</ft:processForm>

<ft:processForm action="Cancel" bHideForms="true">
	<cfset setLock(stObj=stObj,locked=false) />
	
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<cfoutput>
		<script type="text/javascript">
			location.href = '#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>	
</ft:processForm>

<ft:form>


<cfoutput>
<table class="layout" style="width:100%;padding:5px;">
<tr>
	<td style="width:50px;"><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" size="48" default="farcrycore" alt="#uCase(application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename))#" /></td>
	<td><h1>#stobj.label#</h1></td>
	
</tr>
</table>
</cfoutput>

	
	<ft:object stObject="#stObj#" lFields="title" legend="General Details" />
	
	<cfif not arraylen(stObj.aObjectIDs)>
			
		<ft:object stObject="#stObj#" lFields="aObjectIDs" legend="Content Options" bShowLibraryLink="false" 
			helpSection="Select the type of content to appear when the visitor browses to this navigation item. If you select this option, you will be automatically redirected to edit the new content item." />
	
	</cfif>
	
	
	<ft:object stObject="#stObj#" lFields="lNavIDAlias,ExternalLink" legend="Advanced Settings" />
	
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" /> 
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />