
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<ft:processForm action="Manage">
	
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
		
	<cfif structKeyExists(form, "selectedObjectID")>
		<skin:location url="#application.url.webtop#/edittabOverview.cfm?objectid=#form.selectedObjectID#" />
	</cfif>
</ft:processForm>


<cfoutput>
<h2>CONTENT ITEM INFORMATION</h2>
ALIAS: <cfif len(stobj.lNavIDAlias)>#stobj.lNavIDAlias#<cfelse>N/A</cfif><br />
</cfoutput>



<cfif not arraylen(stObj.aObjectIDs)>
		
	<cfoutput>
	<div style="margin-left:50px;padding:5px;border:1px solid ##A4C8E5;">
		<p class="highlight">You do not currently have any content under this navigation item. You have two options:</p>
	</cfoutput>				
		
		<cfset stPropMetadata = structnew() />
		<cfset stPropMetadata.aObjectIDs.ftLabel = "Content Type" />
		<cfset stPropMetadata.aObjectIDs.ftHint = "Select a content type to create as a child of this navigation item. If you select this option, you will be automatically redirected to edit the new content item." />
		<ft:object stObject="#stObj#" lFields="aObjectIDs" legend="OPTION 1: Create Content" stPropMetadata="#stPropMetadata#" bShowLibraryLink="false" />
		
		<cfset stPropMetadata = structnew() />
		<cfset stPropMetadata.ExternalLink.ftHint = "Select a navigation alias to redirect to when this navigation item is browsed too." />

		<ft:object stObject="#stObj#" lFields="ExternalLink" legend="OPTION 2: Redirect"  stPropMetadata="#stPropMetadata#"  />
	
	<cfoutput>
	</div>
	</cfoutput>
	
<cfelse>
	<cfoutput>
	<h2>ATTACHED CONTENT</h2>
	<table class="objectAdmin">
	
	<cfloop from="1" to="#arrayLen(stobj.aObjectIDs)#" index="i">
		<cfset contentTypename = application.fapi.findType(objectid="#stobj.aObjectIDs[i]#") />
		
		<tr>
			<td><skin:icon icon="#application.stCOAPI[contentTypename].icon#" size="16" default="farcrycore" /></td>	
			<td><skin:view typename="#contentTypename#" objectid="#stobj.aObjectIDs[i]#" webskin="displayLabel" /></td>	
			<td><ft:button value="Manage" renderType="link" selectedObjectID="#stobj.aObjectIDs[i]#" /></td>	
		</tr>
			
	</cfloop>	
	
	</table>
	</cfoutput>
</cfif>
	


<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">

<cfif application.fapi.checkObjectPermission(objectID=parentID, permission="Create")>
	<cfset objType = application.fapi.getContentType(stobj.typename) />
	<cfset lPreferredTypeSeq = "dmNavigation,dmHTML"> <!--- this list will determine preffered order of objects in create menu - maybe this should be configurable. --->
	<!--- <cfset aTypesUseInTree = objType.buildTreeCreateTypes(lPreferredTypeSeq)> --->
	<cfset lAllTypes = structKeyList(application.types)>
	<!--- remove preffered types from *all* list --->
	<cfset aPreferredTypeSeq = listToArray(lPreferredTypeSeq)>
	<cfloop index="i" from="1" to="#arrayLen(aPreferredTypeSeq)#">
		<cfset lAlltypes = listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]))>
	</cfloop>
	<cfset lAlltypes = ListAppend(lPreferredTypeSeq,lAlltypes)>
	<cfset aTypesUseInTree = objType.buildTreeCreateTypes(lAllTypes)>
	<cfif ArrayLen(aTypesUseInTree)>
		<cfoutput>
		<select id="createContent" name="createContent" style="width:180px;margin-top:10px;">
			<option value="">-- Attach New Content --</option>
			<cfloop index="i" from="1" to="#ArrayLen(aTypesUseInTree)#">
				<option value="#aTypesUseInTree[i].typename#">Create #aTypesUseInTree[i].description#</option>
				<!--- <ft:button value="Create #aTypesUseInTree[i].description#" rbkey="coapi.#aTypesUseInTree[i].typename#.buttons.createtype" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=#aTypesUseInTree[i].typename#&ref=#url.ref#" /> --->
			</cfloop>
		</select>
		</cfoutput>	
		
		<skin:onReady>
			<cfoutput>
			$j('##createContent').change(function() {
				location = '#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=' + $j('##createContent').val() + '&ref=#url.ref#';
			});
			</cfoutput>
		</skin:onReady>
	</cfif>
</cfif>