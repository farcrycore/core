<!--- 	
	@@examples:

	<p>Basic</p>
	<code>
		<cfproperty 
			name="catBasic" type="longchar" required="no" default="" 
			fttype="category" />
	</code>

	<p>Start tree from branch where alias is "news"</p>
	<code>
		<cfproperty 
			name="catNews" type="longchar" required="no" default="" 
			fttype="category" ftAlias="news" />
	</code>

	<p>Render tree as select field</p>
	<code>
		<cfproperty 
			name="catSelect" type="longchar" required="no" default="" 
			fttype="category" ftRenderType="dropDown" />
	</code>
	
	<p>Render tree as select field with 10 rows displayed and first option as "Please Select..."</p>
	<code>
		<cfproperty 
			name="catSelect" type="longchar" required="no" default="" 
			fttype="category" ftRenderType="dropDown" ftSelectSize="10" 
			ftDropdownFirstItem="Please Select..." />
	</code>

 --->

<cfcomponent extends="field" name="category" displayname="category" bDocument="true" hint="Field component to liase with all category field types"> 

	<cfproperty name="ftAlias" default="" hint="Used to render only a particular branch of the category tree." />
	<cfproperty name="ftRenderType" default="jquery" hint="This formtool offers a number of ways to render the input. (dropdown, prototype, extjs, jquery)" />
	<cfproperty name="ftSelectMultiple" default="true" hint="Allow selection of multiple items in category tree. (true, false)" />
	<cfproperty name="ftSelectSize" default="5" hint="Used when ftRenderType is set to dropDown, specifies the size of the select field." />
	<cfproperty name="ftDropdownFirstItem" default="" hint="Used when ftRenderType is set to dropDown, prepends an option to select list with null value." />	
	<cfproperty name="ftHideRootNode" default="false" hint="Set to true to hide the root node from being rendered in the category tree." />	
	
	<cfproperty name="ftJQueryAllowEdit" default="true" />
	<cfproperty name="ftJQueryAllowAdd" default="true" />
	<cfproperty name="ftJQueryAllowRemove" default="true" />
	<cfproperty name="ftJQueryAllowMove" default="true" />
	<cfproperty name="ftJQueryAllowSelect" default="true" />
	<cfproperty name="ftJQueryQuickEdit" default="false" hint="If ftJQueryAllowSelect is false and this is true, then clicking a node shows the edit icons (default behaviour is to only show them on a long click)" />
	<cfproperty name="ftJQueryOnEdit" default="" hint="Overrides the default Javascript which performs this task (should expect 'node' variable)" />
	<cfproperty name="ftJQueryOnAdd" default="" hint="Overrides the default Javascript which performs thistask (should expect 'node' and 'newid' variables)" />
	<cfproperty name="ftJQueryOnRemove" default="" hint="Overrides the default Javascript which performs thistask (should expect 'node' variable)" />
	<cfproperty name="ftJQueryOnMove" default="" hint="Overrides the default Javascript which performs thistask (should expect 'node', 'parent', 'position', and 'finishMove' variables)" />
	<cfproperty name="ftJQueryOnSelect" default="" hint="Overrides the default Javascript which performs thistask (should expect 'node' and 'selected' variables)" />
	<cfproperty name="ftJQueryOnUpdateStart" default="" hint="Overrides the default Javascript which runs when an ajax update operation starts" />
	<cfproperty name="ftJQueryOnUpdateFinish" default="" hint="Overrides the default Javascript which runs when an ajax update operation finishes" />
	<cfproperty name="ftJQueryOnUpdateError" default="" hint="Overrides the default Javascript which runs when an ajax update operation errors (should expect 'error' and 'code' variables)" />
	<cfproperty name="ftJQueryVisibleInputs" default="true" hint="Controls whether the checkbox / radio buttons are shown to the user" />
	<cfproperty name="ftEditableProperties" default="categoryLabel" hint="List of the properties that the user can edit in the case of ftJQueryAllowEdit and ftJQueryAllowAdd" />
	<cfproperty name="ftJQueryURL" default="true" hint="Overrides the AJAX URL" />
	
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >


	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.category" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="dropdown">
				<cfset html = editDropdown(argumentCollection=arguments) />
			</cfcase>
			
			<cfdefaultcase>
				<cfset html = editJQuery(argumentCollection=arguments) />		
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var catid = "" />

		<cfif listLen(stObject[stMetadata.name])>
			<cfloop list="#stObject[stMetadata.name]#" index="catid">		
					<cfset html = listAppend(html,application.factory.oCategory.getCategoryNameByID(catid)) />
			</cfloop>
		</cfif>

		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#arguments.stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfinvoke  component="#application.fapi.getContentType('dmCategory')#" method="assignCategories" returnvariable="stStatus">
			<cfinvokeargument name="objectID" value="#arguments.ObjectID#"/>
			<cfinvokeargument name="lCategoryIDs" value="#arguments.stFieldPost.Value#"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
					
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="editDropdown" access="public" output="false" returntype="string" hint="Returns a string for editing">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var oCategory = createObject("component",'farcry.core.packages.farcry.category')>
		<cfset var lSelectedCategoryID = "" >
		<cfset var lCategoryBranch = "" />
		<cfset var CategoryName = "" />
		<cfset var i = "" />
		<cfset var rootNodeText = "" />
		<cfset var rootID = application.catid['root'] />
		
		<cfif structKeyExists(application.catid, arguments.stMetadata.ftAlias)>
			<cfset rootID = application.catid[arguments.stMetadata.ftAlias] >
		</cfif>

		<cfset lSelectedCategoryID = oCategory.getCategories(objectid=arguments.stObject.ObjectID,bReturnCategoryIDs=true,alias=arguments.stMetadata.ftAlias) />
		<cfset rootNodeText = oCategory.getCategoryNamebyID(categoryid=rootID) />
		<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=rootID) />
		
		<cfsavecontent variable="html">
			<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"  <cfif arguments.stMetadata.ftSelectMultiple>size="#arguments.stMetadata.ftSelectSize#" multiple="true"</cfif> class="selectInput #arguments.stMetadata.ftSelectSize# #arguments.stMetadata.ftClass#"></cfoutput>
			<cfloop list="#lCategoryBranch#" index="i">
				<!--- If the item is the actual alias requested then it is not selectable. --->
				<cfif i EQ rootID>
					<cfif len(arguments.stMetadata.ftDropdownFirstItem)>
						<cfoutput><option value="">#arguments.stMetadata.ftDropdownFirstItem#</option></cfoutput>
					<cfelseif len(arguments.stMetadata.ftHideRootNode) AND arguments.stMetadata.ftHideRootNode>
							<!--- Do not display root node if this option is on. --->
					<cfelse>	
						<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='dmCategory') />
						<cfoutput><option value="">#CategoryName#</option></cfoutput>
					</cfif>
				<cfelse>
					<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='dmCategory') />
					<cfoutput><option value="#i#"<cfif listContainsNoCase(lSelectedCategoryID, i)> selected="selected"</cfif>>#CategoryName#</option></cfoutput>
				</cfif>
				
			</cfloop>
			<cfoutput></select></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="editJQuery" access="public" output="false" returntype="string" hint="Returns a string for editing">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var stTree = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid.root) />
		<cfset var stBranch = structnew() />
		<cfset var lCatIDs = "">

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
		
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="jquery-tree" />
		<skin:loadCSS id="jquery-tree" />
		<skin:loadJS id="category-formtool" />
		<skin:loadJS id="jquery-modal" />
		<skin:loadCSS id="jquery-modal" />
		<skin:loadCSS id="fc-icons" />
		
		<cfif (len(arguments.stMetadata.ftAlias) AND arguments.stMetadata.ftAlias eq "root") or not structkeyexists(application.catid,arguments.stMetadata.ftAlias)>
			<cfset stBranch = stTree />
		<cfelse>
			<cfset stBranch = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid[arguments.stMetadata.ftAlias]) />
		</cfif>
		<cfset stBranch["roothash"] = stTree.hash />

		<cfloop list="#arguments.stMetadata.value#" index="catID">
			<cfset qParent = application.factory.oTree.getParentID(objectid=catID)>
			<cfif NOT listFindNoCase(lCatIDs, qParent.parentID)>
				<cfset lCatIDs = listAppend(lCatIDs, qParent.parentID)>
			</cfif>
		</cfloop>

		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<div id="#arguments.fieldname#-tree"></div>
				<cfif arguments.stMetadata.ftHideRootNode>
					<style>
						###arguments.fieldname#-tree > ul > li > div:first-child{ display:none; }
					</style>
				</cfif>	
				<input type="hidden" name="#arguments.fieldname#" value="">
				<script type="text/javascript">
					$j("###arguments.fieldname#-tree").farcryTree({
						data : [#serializeJSON(stBranch)#],
						dataUrl : <cfif len(arguments.stMetadata.ftJQueryURL)>'#arguments.stMetadata.ftJQueryURL#'<cfelse>'#getAjaxUrl(argumentCollection=arguments)#'</cfif>,
						rootid : '#stBranch.id#',
						newid : '#createuuid()#',
						fieldName : '#arguments.fieldname#',
						selected : #serializeJSON(listtoarray(arguments.stMetadata.value))#,
						allowEdit : #serializeJSON(arguments.stMetadata.ftJQueryAllowEdit)#,
						allowAdd : #serializeJSON(arguments.stMetadata.ftJQueryAllowEdit)#,
						allowRemove : #serializeJSON(arguments.stMetadata.ftJQueryAllowEdit)#,
						allowMove : #serializeJSON(arguments.stMetadata.ftJQueryAllowEdit)#,
						allowSelect : #serializeJSON(arguments.stMetadata.ftJQueryAllowEdit)#,
						quickEdit : #serializeJSON(arguments.stMetadata.ftJQueryQuickEdit)#,
						selectMultiple : #serializeJSON(arguments.stMetadata.ftSelectMultiple)#,
						visibleInputs : #serializeJSON(arguments.stMetadata.ftJQueryVisibleInputs)#,
						openNodes : #serializeJSON(listtoarray(lCatIDs))#

						<cfif len(arguments.stMetadata.ftJQueryOnEdit)>,onEditNode:function onEdit#arguments.fieldname#(node){ #arguments.stMetadata.ftJQueryOnEdit# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnAdd)>,onAddNode:function onAdd#arguments.fieldname#(node,newid){ #arguments.stMetadata.ftJQueryOnAdd# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnRemove)>,onRemoveNode:function onRemove#arguments.fieldname#(node){ #arguments.stMetadata.ftJQueryOnRemove# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnMove)>,onMoveNode:function onMove#arguments.fieldname#(node,parent,position,finishMove){ #arguments.stMetadata.ftJQueryOnMove# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnSelect)>,onSelectNode:function onSelect#arguments.fieldname#(node,selected){ #arguments.stMetadata.ftJQueryOnSelect# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnUpdateStart)>,onUpdateStart:function onUpdateStart#arguments.fieldname#(event){ #arguments.stMetadata.ftJQueryOnUpdateStart# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnUpdateFinish)>,onUpdateFinish:function onUpdateFinish#arguments.fieldname#(event){ #arguments.stMetadata.ftJQueryOnUpdateFinish# }</cfif>
						<cfif len(arguments.stMetadata.ftJQueryOnUpdateError)>,onUpdateError:function onUpdateError#arguments.fieldname#(event,error,code){ #arguments.stMetadata.ftJQueryOnUpdateError# }</cfif>
					});
				</script>
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stTree = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid.root) />
		<cfset var stResult = structnew() />
		<cfset var stCat = structnew() />
		<cfset var stSource = structnew() />
		<cfset var thisfield = "" />
		<cfset var html = "" />

		<cfif arguments.stMetadata.ftRenderType neq "jquery">
			<cfreturn super.ajax(argumentCollection=arguments) />
		</cfif>
		
		<cfif isdefined("url.hash") and stTree.hash neq url.hash>
			<cfset stResult = structnew() />
			<cfset stResult["error"] = "The tree has changed since you last loaded the page." />
			<cfset stResult["code"] = "treechanged" />
			<cfreturn serializeJSON(stResult) />
		</cfif>
		
		<cftry>
			<cfif arguments.stMetadata.ftJQueryAllowMove and isdefined("url.move")>
				<cfset stResult = application.factory.oTree.moveBranch(objectid=url.move,parentid=url.to,pos=url.position) />
				<cfset stTree = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid.root) />
				<cfset stResult["roothash"] = stTree.hash />
				<cfreturn serializeJSON(stResult) />
			<cfelseif arguments.stMetadata.ftJQueryAllowAdd and isdefined("url.add")>
				<cfset stCat = application.fapi.getContentObject(objectid=url.add) />
				<cfset stResult = application.factory.oTree.setYoungest(objectid=url.add,parentid=url.to,objectname=stCat.label,typename=stCat.typename) />
				<cfset stTree = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid.root) />
				<cfset stResult["roothash"] = stTree.hash />
				<cfreturn serializeJSON(stResult) />
			<cfelseif arguments.stMetadata.ftJQueryAllowRemove and isdefined("url.remove")>
				<cfset stResult = application.fapi.getContentType("dmCategory").deleteCategory(dsn=application.dsn,categoryid=url.remove) />
				<cfset stTree = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=application.catid.root) />
				<cfset stResult["roothash"] = stTree.hash />
				<cfreturn serializeJSON(stResult) />
			<cfelseif isdefined("url.node")>
				<cfif url.node eq stTree.id>
					<cfset stResult = stTree />
					<cfset stResult["roothash"] = stTree.hash />
				<cfelse>
					<cfset stResult = application.factory.oTree.getDescendantsAsNestedStruct(dsn=application.dsn,objectid=url.node) />
					<cfset stResult["roothash"] = stTree.hash />
				</cfif>
				<cfset stResult["newid"] = createuuid() />
				<cfreturn serializeJSON(stResult) />
			<cfelseif (arguments.stMetadata.ftJQueryAllowAdd or arguments.stMetadata.ftJQueryAllowEdit) and isdefined("url.update")>
				<cfset stSource = structnew() />
				<cfset stSource.objectid = url.update />
				<cfset stSource.typename = "dmCategory" />
				<cfloop list="#arguments.stMetadata.ftEditableProperties#" index="thisfield">
					<cfset stSource[thisfield] = form["_#thisfield#"] />
				</cfloop>
				<cfif structkeyexists(stSource,"categoryLabel")>
					<cfset stSource.label = stSource.categoryLabel />
				</cfif>
				<cfset application.fapi.setData(stProperties=stSource) />
				
				<cfreturn serializeJSON(stSource) />
			<cfelseif (arguments.stMetadata.ftJQueryAllowAdd or arguments.stMetadata.ftJQueryAllowEdit) and isdefined("url.edit")>
				<cfset request.mode.ajax = true />
				<cfsavecontent variable="html"><cfoutput>
					<div style="border: 1px solid ##c8c8c8\9;background-color:##FFFFFF;padding:15px;-webkit-box-shadow: 0 0 8px rgba(128,128,128,0.75);-moz-box-shadow: 0 0 8px rgba(128,128,128,0.75);box-shadow: 0 0 8px rgba(128,128,128,0.75);">
						<ft:form>
							<ft:object objectid="#url.edit#" typename="dmCategory" lFields="#arguments.stMetadata.ftEditableProperties#" r_stPrefix="editprefix" />
							<ft:buttonPanel>
								<a href="##" class="closeModal">cancel</a>&nbsp;<ft:button value="Save" onclick="var base={};var props='#arguments.stMetadata.ftEditableProperties#'.split(',');for (var i in props) base[props[i]]='';$fc.tree.saveObject('#url.edit#',getValueData(base,'#editprefix#'));$fc.closeModal();return false;" />
							</ft:buttonPanel>
						</ft:form>
					</div>
				</cfoutput></cfsavecontent>
				
				<cfset stResult["html"] = html />
				<cfreturn serializeJSON(stResult) />
			<cfelse>
				<cfset stResult = structnew() />
				<cfset stResult["error"] = "That is not a valid request" />
				<cfset stResult["code"] = "apierror" />
				<cfreturn serializeJSON(stResult) />
			</cfif>
			
			<cfcatch>
				<cfset stResult = structnew() />
				<cfset stResult["error"] = cfcatch.message />
				<cfset stResult["code"] = "cfmlerror" />
				<cfreturn serializeJSON(stResult) />
			</cfcatch>
		</cftry>
		
		<cfreturn "" />
	</cffunction>
	
	
	<cffunction name="branchAsLI" access="private" output="false" returntype="string">
		<cfargument name="branch" type="struct" required="true" />
		
		<cfset var result = "" />
		<cfset var thisarg = "" />
		<cfset var i = 0 />
		
		<cfset result = result & '<li id="#arguments.branch.objectid#">#arguments.branch.objectname#<ul>' />
		
		<cfloop from="1" to="#arraylen(arguments.branch.children)#" index="i">
			<cfset result = result & branchAsLI(branch=arguments.branch.children[i]) />
		</cfloop>
			
		<cfset result = result & '</ul></li>' />
		
		<cfreturn result />
	</cffunction>
	

	<!------------------ 
	FILTERING FUNCTIONS
	 ------------------>	
	<cffunction name="getFilterUIOptions">
		
		<cfreturn "related to all,related to any" />
	</cffunction>
	
	<cffunction name="editFilterUI">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var oCategory = createObject("component",'farcry.core.packages.farcry.category')>
		<cfset var alias = application.fapi.getPropertyMetadata(	typename = "#arguments.filterTypename#" ,
																	property = "#arguments.filterProperty#" ,
																	md = "ftAlias" ,
																	default = "root" )>
		<cfset var rootID = application.fapi.getCatID( alias ) />
		
		<cfset var rootNodeText = oCategory.getCategoryNamebyID(categoryid=rootID) />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfdefaultcase>
					<cfparam name="arguments.stFilterProps.value" default="" />
				
	
					<skin:onReady>
					<cfoutput>
						$j("###arguments.fieldname#_list").treeview({
							url: "#application.url.webtop#/facade/getCategoryNodes.cfm?node=#rootID#&fieldname=#arguments.fieldname#value&multiple=true&lSelectedItems=#arguments.stFilterProps.value#"
						})
					</cfoutput>
					</skin:onReady>
				
					<cfoutput>
					<div class="multiField">
						<ul id="#arguments.fieldname#_list" class="treeview"></ul>
					</div>
					<input type="hidden" name="#arguments.fieldname#value" value="" />	
					</cfoutput>
						
				</cfdefaultcase>
							
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="displayFilterUI">
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var catID = "" />
		<cfset var catHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfdefaultcase>
					<cfif structKeyExists(arguments.stFilterProps, "value") AND listLen(arguments.stFilterProps.value)>
						<cfloop list="#arguments.stFilterProps.value#" index="catid">		
							<cfset catHTML = listAppend(catHTML,application.factory.oCategory.getCategoryNameByID(catid)) />
						</cfloop>
						<cfoutput>#catHTML#</cfoutput>
					</cfif>				
				</cfdefaultcase>		
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	

	<cffunction name="getFilterSQL">
		
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var iCat = "" />
		<cfset var iCounter = 0 />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="related to all">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>
						(
							<cfloop list="#arguments.stFilterProps.value#" index="iCat">
								<cfset iCounter = iCounter + 1 />
								<cfif iCounter GT 1>
									AND
								</cfif>
								objectID IN (
									SELECT objectID
									FROM refCategories
									WHERE categoryID = '#iCat#'
								)
							</cfloop> 
						)
						</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="related to any">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>(
							objectID IN (
								SELECT objectID
								FROM refCategories
								WHERE categoryID IN (#ListQualify(arguments.stFilterProps.value,"'",",","ALL")#)
							)
						)
						</cfoutput>
									
					</cfif>
				</cfcase>
			</cfswitch>
			
		</cfsavecontent>

		<cfreturn resultHTML />
	</cffunction>
		
	
	
</cfcomponent> 



