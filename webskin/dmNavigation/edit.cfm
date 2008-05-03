<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@timeout: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<cfset setLock(stObj=stObj,locked=true) />

<cfset onExit = structNew() />
<cfset onExit.Type = "HTML" />
<cfsavecontent variable="onExit.Content">
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<cfoutput>
		<script type="text/javascript">
			parent['content'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>
</cfsavecontent>

<ft:processForm action="Save" Exit="true">
	<cfset setLock(stObj=stObj,locked=false) />
	<cfif arraylen(stObj.aObjectIDs)>
		<ft:processFormObjects typename="#stobj.typename#" />
	<cfelse>
		<ft:processFormObjects typename="#stobj.typename#">
			<cfif arraylen(stProperties.aObjectIDs)>
				<cfset newtypename = application.coapi.coapiadmin.findType(stProperties.aObjectIDs[1]) />
				<cfset oType = createobject("component",application.stCOAPI[newtypename].packagepath) />
				<cfset oType.setData(stProperties=oType.getData(objectid=stProperties.aObjectIDs[1],bUseInstanceCache=true)) />
				
				<cfset onExit.type = "html" />
				<cfsavecontent variable="onExit.content">
					<!--- get parent to update tree --->
					<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
					
					<!--- update tree --->
					<nj:updateTree objectId="#parentID#">
					
					<cfoutput>
						<script type="text/javascript">
							parent['content'].location.href = "#application.url.webtop#/edittabEdit.cfm?objectid=#stProperties.aObjectIDs[1]#&ref=overview&typename=#newtypename#";
						</script>
					</cfoutput>
				</cfsavecontent>
			</cfif>
		</ft:processFormObjects>
	</cfif>
</ft:processForm>

<ft:processForm action="Cancel" Exit="true">
	<cfset setLock(stObj=stObj,locked=false) />
</ft:processForm>

<ft:form>
	<cfoutput><h1>#stobj.label#</h1></cfoutput>
	
	<ft:object stObject="#stObj#" lFields="title,lNavIDAlias" legend="General Details" />
	
	<cfif not arraylen(stObj.aObjectIDs)>
		<cfset stPropMetadata = structnew() />
		<cfset stPropMetadata.aObjectIDs.ftLabel = "Create child" />
		
		<ft:object stObject="#stObj#" lFields="ExternalLink,typewebskin,aObjectIDs" legend="Advanced Options" stPropMetadata="#stPropMetadata#" bShowLibraryLink="false" />
	</cfif>
	
	<ft:farcrybuttonpanel>
		<ft:button value="Save" color="orange" /> 
		<ft:button value="Cancel" validate="false" />
	</ft:farcrybuttonpanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />