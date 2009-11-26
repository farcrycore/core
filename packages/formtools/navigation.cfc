<cfcomponent extends="field" name="navigation" displayname="navigation" hint="Field component to liase with all navigation field types"> 

	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.navigation" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var navid = "" />
		<cfset var lSelectedNaviIDs = "" />
		<cfset var i = "" />
		<cfset var html = "" />
		<cfset var lCategoryBranch = "" />
		<cfset var CategoryName = "" />
		<cfset var oNav = createObject("component",application.stCOAPI.dmNavigation.packagepath) />
		<cfset var stNav = structnew() />
		<cfset var rootID = "" />
		
		<cfparam name="arguments.stMetadata.ftAlias" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLegend" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="jquery" type="string" />
		
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stObject[arguments.stMetadata.ftWatch])>
			<cfset rootID = arguments.stObject[arguments.stMetadata.ftWatch] />
		<cfelseif structKeyExists(application.navid, arguments.stMetadata.ftAlias)>
			<cfset rootID = application.navid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset rootID = application.navid['root'] >
		</cfif>

		<cfset stNav = oNav.getData(objectid=rootID) />

		<cfif isArray(arguments.stObject['#arguments.stMetadata.name#'])>
			<cfset lSelectedNaviIDs = arrayToList(arguments.stObject['#arguments.stMetadata.name#']) />
		<cfelse>
			<cfset lSelectedNaviIDs = arguments.stObject['#arguments.stMetadata.name#'] />
		</cfif>
		
		<cfset rootNodeText = stNav.label />

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdown">
				<cfreturn editDropdownTree(typename,stObject,stMetadata,fieldname,lSelectedNaviIDs,rootID) />
			</cfcase>
			
			<cfcase value="prototype">
				<cfsavecontent variable="html">
					
						<cfoutput><fieldset style="width: 300px;">
							<cfif len(arguments.stMetadata.ftLegend)><legend>#arguments.stMetadata.ftLegend#</legend></cfif>
						
							<div class="fieldsection optional full">
													
								<div class="fieldwrap">
								</cfoutput>
									<ft:NTMPrototypeTree id="#arguments.fieldname#" navid="#rootID#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedNaviIDs#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
								
								<cfoutput>
								</div>
								
								<br class="fieldsectionbreak" />
							</div>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
						</fieldset></cfoutput>
								
				</cfsavecontent>
			</cfcase>
			
			<cfcase value="jquery">
				<cfreturn editJQueryTree(typename,stObject,stMetadata,fieldname,lSelectedNaviIDs,rootID) />
			</cfcase>
			
			<cfdefaultcase>
				<skin:htmlHead library="extjs" />
				
				<cfsavecontent variable="html">
					
						<cfoutput><fieldset style="width: 300px;">
							<cfif len(arguments.stMetadata.ftLegend)><legend>#arguments.stMetadata.ftLegend#</legend></cfif>
						
							<!--- <div id="tree-div" style="border:1px solid #c3daf9;"></div> --->
							<div class="fieldsection optional full">
												
								<div class="fieldwrap">
									
									<div id="#arguments.fieldname#-tree-div"></div>	
									
		
								</div>
								
								<br class="fieldsectionbreak" />
							</div>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#lSelectedNaviIDs#" />
						</fieldset>
						</cfoutput>		
				</cfsavecontent>
				

			
				<extjs:onReady>
				<cfoutput>
				    createFormtoolTree('#arguments.fieldname#','#rootID#', '#application.url.webtop#/facade/getNavigationNodes.cfm', '#rootNodeText#','#lSelectedNaviIDs#', 'categoryIconCls');											
				</cfoutput>
				</extjs:onReady>
				
			</cfdefaultcase>
			
		</cfswitch>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="editDropdownTree" access="public" output="false" returntype="string" hint="Returns the edit UI for the dropdown rendertype">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="lSelectedNavIDs" required="true" type="string" hint="The selected nodes">
		<cfargument name="rootid" required="true" type="string" hint="The root node">
		
		<cfset var html = "" />
		<cfset var oTree = createObject("component", "#application.packagepath#.farcry.tree") />
		<cfset var qNodes = querynew("empty") />
		<cfset var rootlevel = -1 />
		
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="5" type="numeric" />
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftDepth" default="1" />
		<cfparam name="arguments.stMetadata.ftIncludeRoot" default="false" />
		
		<cfset qNodes = oTree.getDescendants(dsn=application.dsn, objectid=arguments.rootid,depth=arguments.stMetadata.ftDepth,bIncludeSelf=arguments.stMetadata.ftIncludeRoot) />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>>
					<option value="">#arguments.stMetadata.ftDropdownFirstItem#</option>
			</cfoutput>
			
			<cfloop query="qNodes">
				<cfif rootlevel eq -1><cfset rootlevel = qNodes.nlevel /></cfif>
				<cfoutput><option value="#objectid#" <cfif listFindNoCase(arguments.stMetadata.value, objectid) or arguments.stMetadata.value eq objectid> selected</cfif>>#RepeatString("-&nbsp;", qNodes.nlevel-rootlevel)##qNodes.objectName#</option></cfoutput>
			</cfloop>
			
			<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=""><br style="clear: both;"/></cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="editJQueryTree" access="public" output="false" returntype="string" hint="Returns the edit UI for the jquery render type">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="lSelectedNavIDs" required="true" type="string" hint="The selected nodes">
		<cfargument name="rootid" required="true" type="string" hint="The root node">
		
		<cfset var html = "" />
		<cfset var contextmenu = "" />
		<cfset var contenttypes = "" />
		<cfset var thistype = "" />
		<cfset var label = "" />
		<cfset var dragrules = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="false" type="boolean" />
		<cfparam name="arguments.stMetadata.ftContextMenu" default="none" />
				
		<cfswitch expression="#arguments.stMetadata.ftContextMenu#">
			<cfcase value="none" >
				<cfset contextmenu = "false" />
				<cfparam name="arguments.stMetadata.ftEnableDragDrop" default="false" />
				<cfparam name="arguments.stMetadata.ftDragDropRules" default="" />
				<cfparam name="arguments.stMetadata.ftOnChange" default="" />
				<cfparam name="arguments.stMetadata.ftOnMove" default="" />
			</cfcase>
			
			<cfdefaultcase>
				<cfif len(arguments.stMetadata.ftContextMenu)>
					<cfinvoke component="#application.stCOAPI[arguments.typename].packagepath#" method="#arguments.stMetadata.ftContextMenu#" returnvariable="contextmenu" />
				<cfelse>
					<cfset contextmenu = "false" />
				</cfif>
				<cfparam name="arguments.stMetadata.ftEnableDragDrop" default="false" />
				
				<cfparam name="arguments.stMetadata.ftDragDropRules" default="" />
				<cfif len(arguments.stMetadata.ftDragDropRules) and not refind("[^\w]",arguments.stMetadata.ftDragDropRules)>
					<cfinvoke component="#application.stCOAPI[arguments.typename].packagepath#" method="#arguments.stMetadata.ftDragDropRules#" returnvariable="arguments.stMetadata.ftDragDropRules" />
				</cfif>
				
				<cfparam name="arguments.stMetadata.ftOnChange" default="" />
				<cfif len(arguments.stMetadata.ftOnChange) and not refind("[^\w]",arguments.stMetadata.ftOnChange)>
					<cfinvoke component="#application.stCOAPI[arguments.typename].packagepath#" method="#arguments.stMetadata.ftOnChange#" returnvariable="arguments.stMetadata.ftOnChange" />
				</cfif>
				
				<cfparam name="arguments.stMetadata.ftOnMove" default="" />
				<cfif len(arguments.stMetadata.ftOnMove) and not refind("[^\w]",arguments.stMetadata.ftOnMove)>
					<cfinvoke component="#application.stCOAPI[arguments.typename].packagepath#" method="#arguments.stMetadata.ftOnMove#" returnvariable="arguments.stMetadata.ftOnMove" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<skin:loadJS id="jquery" />
		<skin:htmlHead id="navigation_jquery"><cfoutput>
			<script type="text/javascript" src="#application.url.webtop#/js/jquery/jstree/_lib/css.js"></script>
			<script type="text/javascript" src="#application.url.webtop#/js/jquery/jstree/tree_component.js"></script>
			<script type="text/javascript" src="#application.url.webtop#/js/jquery/jstree/_lib/jquery.metadata.js"></script>
			<script type="text/javascript" src="#application.url.webtop#/js/jquery/jstree/_lib/jquery.cookie.js"></script>
			<style type="text/css">
				@import url("#application.url.webtop#/js/jquery/jstree/tree_component.css");		/* Tree CSS */
			</style>
		</cfoutput></skin:htmlHead>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#lselectednavids#" />
				<div id="sitetree"></div>
				<script type="text/javascript">
					(function(){
						var treeconfig = {
							data 		: { 
								type 		: "json", 
								async 		: true, 
								url 		: "#application.url.webtop#/facade/children_json.cfm",
								async_data	: function (NODE) { 
									return { 
										id 		: jQuery(NODE).attr("id") || 0,
										default	: "#arguments.rootid#",
										ajaxmode: 1
									}
								} 
							},
							ui			:{
								context_left: 10,
								context		: #contextmenu#
							},
							selected	: [ <cfif len(arguments.lSelectedNavIDs)>"#listchangedelims(arguments.lSelectedNavIDs,'","')#"</cfif> ],
							rules		: {
								metadata 	: "data", 
								use_inline	: true,
								editable	: true,
						        draggable   : <cfif arguments.stMetadata.ftEnableDragDrop>"all"<cfelse>"none"</cfif>,
						        dragrules   : #arguments.stMetadata.ftDragDropRules#,
						        multiple	: <cfif arguments.stMetadata.ftSelectMultiple>"on"<cfelse>false</cfif>
								
							},
							cookies 	: { prefix : "#arguments.fieldname#tree", opts : { path : '/' } },
							callback	: {
								onchange 	: function(NODE,TREE_OBJ) {
									var selectedids = [];
									TREE_OBJ.selected.each(function(){ selectedids.push(this.id); });
									jQ("###arguments.fieldname#").val(selectedids.join());
									#arguments.stMetadata.ftOnChange#
								},
								onmove 		: function(NODE,REF_NODE,TYPE,TREE_OBJ) { 
									#arguments.stMetadata.ftOnMove#
								}
							}
						};
						jQ("##sitetree").tree(treeconfig);
					})();
				</script>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var stNav = structNew() />
		
		<cfif len(arguments.stmetadata.value)>
			<cfset stNav = createobject("component", application.types.dmnavigation.typepath).getdata(objectid=arguments.stmetadata.value) />
			<cfset html=stNav.title />
		<cfelse>
			<cfset html="No navigation folder defined.">
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
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = stFieldPost.Value>

		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 



