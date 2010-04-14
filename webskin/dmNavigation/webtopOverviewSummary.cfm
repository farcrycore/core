<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
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
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The dmNavigation specific webskin to use to render the object's summary in the webtop overview screen  --->

<!--- import tag libraries --->
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





	
	<ft:fieldset legend="Navigation Details">
		
		<!--- Using getNavID() just in case developer has added versions to dmNavigation --->
		<cfset qDescendents = createObject("component", "#application.packagepath#.farcry.tree").getDescendants(objectid=getNavID(stobj.objectid), depth=1, bIncludeSelf=0) />
		<ft:field label="Breadcrumb" bMultiField="true">
		
			<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">
			
			<cfif len(parentID)>
				<cfif stobj.typename EQ "dmNavigation">
					<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=false) />
				<cfelse>
					<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=true) />
				</cfif>
				
				<cfif qAncestors.recordCount>
					<cfloop query="qAncestors">
						<skin:buildLink href="#application.url.webtop#/editTabOverview.cfm" urlParameters="objectID=#qAncestors.objectid#" linktext="#qAncestors.objectName#" />
						<cfoutput>&nbsp;&raquo;&nbsp;</cfoutput>
					</cfloop>
					<cfoutput>#stobj.label#</cfoutput>
				<cfelse>
					<cfoutput>#stobj.label#</cfoutput>
				</cfif>
			</cfif>
			
			
			<!---<cfoutput>
            		
				<div style="background-color:##2E4E7E;padding:5px;">
					<cfset qAncestors = queryNew('nLevel')	/>
						
					<!--- BREADCRUMB --->	
					<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">
					
					<cfif len(parentID)>
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=false) />
						<cfloop query="qAncestors">
							<table class="layout navtree">
							<tr>
								<cfloop from="1" to="#qAncestors.nLevel#" index="i">
									<cfif qAncestors.nLevel EQ i>
										<td><img width="16" height="16" src="/webtop/images/treeImages/nbe.gif"/></td>	
									<cfelse>
										<td><img width="16" height="16" src="/webtop/images/treeImages/s.gif"/></td>	
									</cfif>
								</cfloop>							
								<td><img width="16" height="16" alt="#qAncestors.objectname#" src="/webtop/images/treeImages/customIcons/NavApproved.gif"/></td>
								<td class="objectname"><skin:buildLink typename="dmNavigation" href="/webtop/edittabOverview.cfm?objectid=#qAncestors.objectid#" objectid="#qAncestors.objectid#" /></td>
							</tr>
							</table>					
						</cfloop>
					</cfif>
					
					<!--- TREE --->
					
					<table class="layout navtree">
					<tr>
						<cfloop query="qAncestors">
							<cfif qAncestors.recordCount EQ qAncestors.currentRow>
								<td><img width="16" height="16" src="/webtop/images/treeImages/nbe.gif"/></td>	
							<cfelse>
								<td><img width="16" height="16" src="/webtop/images/treeImages/s.gif"/></td>	
							</cfif>
						</cfloop>
						<td><img width="16" height="16" alt="#qDescendents.objectname#" src="/webtop/images/treeImages/customIcons/NavApproved.gif"/></td>
						<td class="objectname">>> #stobj.label#</td>
					</tr>
					</table>
					
					
					<cfif qDescendents.recordCount>
						<cfloop query="qDescendents">
							<cfset stNavItem = getData(objectid="#qDescendents.objectid#") />
							
							
							<table class="layout navtree">
							<tr>
								<cfloop query="qAncestors">
									<td><img width="16" height="16" src="/webtop/images/treeImages/s.gif"/></td>
								</cfloop>
								<cfif qDescendents.recordCount EQ qDescendents.currentRow>
									<td><img width="16" height="16" src="/webtop/images/treeImages/nbe.gif"/></td>
								<cfelse>	
									<td><img width="16" height="16" src="/webtop/images/treeImages/nme.gif"/></td>
								</cfif>						
								<td><img width="16" height="16" alt="#qDescendents.objectname#" src="/webtop/images/treeImages/customIcons/NavApproved.gif"/></td>
								<td class="objectname"><skin:buildLink typename="dmNavigation" href="/webtop/edittabOverview.cfm?objectid=#qDescendents.objectid#" objectid="#qDescendents.objectid#" /></td>
							</tr>
							</table>
							
						</cfloop>
					</cfif>
					
					
					<!---<table class="layout navtree">
					<tr>
						<cfloop query="qAncestors">
							<td><img width="16" height="16" src="/webtop/images/treeImages/s.gif"/></td>
						</cfloop>	
						<td><img width="16" height="16" src="/webtop/images/treeImages/nbe.gif"/></td>							
						<td><img width="16" height="16" alt="Create Sub Navigation" src="/webtop/images/treeImages/customIcons/NavApproved.gif"/></td>
						<td class="objectname"><ft:button value="*** CREATE SUB NAVIGATION ***" renderType="link" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=dmNavigation&ref=#url.ref#" /></td>
					</tr>
					</table>--->
				</div>
				
            </cfoutput>--->
			
			<ft:fieldHint>
				<cfoutput>
				This shows you the selected navigation item in the context of your site. 
				You can <ft:button value="create a child" renderType="link" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=dmNavigation&ref=#url.ref#" /> navigation item under this.
				</cfoutput>
			</ft:fieldHint>
		</ft:field>
		
		
		
		
		<cfif arrayLen(stobj.aObjectIDs)>
			<cfsavecontent variable="contentHint">
				<cfoutput>When a visitor to your site browses to this navigation item, they will be displayed the content above. Unless instructed otherwise, you should only require a single content item here.</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="contentHint">
				<cfoutput>Select the type of content that a visitor to your site will see when they browse to this navigation item.</cfoutput>
			</cfsavecontent>
		</cfif>
		<ft:field label="Content" bMultiField="true" hint="#contentHint#">
			<cfoutput>
            	
				<cfif arrayLen(stobj.aObjectIDs)>
					<table class="objectAdmin" style="width:100%;">	
					<cfloop from="1" to="#arrayLen(stobj.aObjectIDs)#" index="i">
						<cfset contentTypename = application.fapi.findType(objectid="#stobj.aObjectIDs[i]#") />
						
						<tr>
							<td>
								<skin:icon icon="#application.stCOAPI[contentTypename].icon#" size="16" default="farcrycore" />
								<skin:view typename="#contentTypename#" objectid="#stobj.aObjectIDs[i]#" webskin="displayLabel" />
							</td>	
							<td style="width:50px;"><ft:button value="Manage" renderType="link" selectedObjectID="#stobj.aObjectIDs[i]#" /></td>	
						</tr>
							
					</cfloop>	
					</table>
					
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
				
						<skin:loadJS id="jquery" />
						<skin:loadJS id="msdropdown" baseHREF="/webtop/thirdparty" lFiles="/msdropdown/js/uncompressed.jquery.dd.js" />
						<skin:loadCSS id="msdropdown" baseHREF="/webtop/thirdparty" lFiles="/msdropdown/dd.css" />
						
						<skin:onReady>
							<cfoutput>
								$j("##createContent").msDropDown();
							</cfoutput>
						</skin:onReady>
						
								<select id="createContent" name="createContent" style="width:100%;" onChange="location = '#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=' + $j('##createContent').val() + '&ref=#url.ref#';">
									<cfif arrayLen(stobj.aObjectIDs)>
										<option value="">-- Attach More Content --</option>
									<cfelse>
										<option value="">-- Attach Content --</option>
									</cfif>
									
									<cfloop index="i" from="1" to="#ArrayLen(aTypesUseInTree)#">
										<cfif aTypesUseInTree[i].typename NEQ "dmNavigation">
											<option value="#aTypesUseInTree[i].typename#" title="#application.fapi.getIconURL(application.stCOAPI[aTypesUseInTree[i].typename].icon,16,'farcrycore')#">#aTypesUseInTree[i].description#</option>
										</cfif>
									</cfloop>
									
								</select>
						
						
					</cfif>
				</cfif>
				
            </cfoutput>	
		</ft:field>
		
		
		<ft:field label="Alias" hint="The alias is used by the programmers to refer to this navigation item in their code.">
			<cfif len(stobj.lNavIDAlias)>
				<cfoutput>#stobj.lNavIDAlias#</cfoutput>
			<cfelse>
				<cfoutput>-- No Alias Provided --</cfoutput>
			</cfif>
		</ft:field>
		
		
	</ft:fieldset>

	

