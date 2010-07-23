<!--- 	
	@@examples:

	<p>Basic</p>
	<code>
		<cfproperty name="catBasic" type="longchar" required="no" default="" fttype="category" />
	</code>

	<p>Start tree from branch where alias is "news"</p>
	<code>
		<cfproperty name="catNews" type="longchar" required="no" default="" fttype="category" ftAlias="news" />
	</code>

	<p>Render tree as select field</p>
	<code>
		<cfproperty name="catSelect" type="longchar" required="no" default="" fttype="category" ftRenderType="dropDown" />
	</code>
	
	<p>Render tree as select field with 10 rows displayed and first option as "Please Select..."</p>
	<code>
		<cfproperty name="catSelect" type="longchar" required="no" default="" fttype="category" ftRenderType="dropDown" ftSelectSize="10" ftDropdownFirstItem="Please Select..." />
	</code>

 --->

<cfcomponent extends="field" name="category" displayname="category" bDocument="true" hint="Field component to liase with all category field types"> 

	<cfproperty name="ftAlias" default="" hint="Used to render only a particular branch of the category tree." />
	<cfproperty name="ftLegend" default="" hint="Used when ftRenderType is set to prototype or extjs. Inserts a legend above category tree." />
	<cfproperty name="ftRenderType" default="jquery" hint="This formtool offers a number of ways to render the input. (dropdown, prototype, extjs, jquery)" />
	<cfproperty name="ftSelectMultiple" default="true" hint="Allow selection of multiple items in category tree. (true, false)" />
	<cfproperty name="ftSelectSize" default="5" hint="Used when ftRenderType is set to dropDown, specifies the size of the select field." />
	<cfproperty name="ftDropdownFirstItem" default="" hint="Used when ftRenderType is set to dropDown, prepends an option to select list with null value." />	
		
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
	<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
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
		<cfset var navid = "" />
		<cfset var oCategory = createObject("component",'farcry.core.packages.farcry.category')>
		<cfset var lSelectedCategoryID = "" >
		<cfset var lCategoryBranch = "" />
		<cfset var CategoryName = "" />
		<cfset var i = "" />
		<cfset var rootNodeText = "" />
		<cfset var rootID = "" />
		
		
		<cfif structKeyExists(application.catid, arguments.stMetadata.ftAlias)>
			<cfset rootID = application.catid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset rootID = application.catid['root'] >
		</cfif>
		
		<cfset lSelectedCategoryID = oCategory.getCategories(objectid=arguments.stObject.ObjectID,bReturnCategoryIDs=true,alias=arguments.stMetadata.ftAlias) />
		
		<cfset rootNodeText = oCategory.getCategoryNamebyID(categoryid=rootID) />


		

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdown">
				<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=rootID) />
							
				<cfsavecontent variable="html">
					<cfoutput><fieldset></cfoutput>
					<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"  <cfif arguments.stMetadata.ftSelectMultiple>size="#arguments.stMetadata.ftSelectSize#" multiple="true"</cfif> class="selectInput #arguments.stMetadata.ftSelectSize# #arguments.stMetadata.ftValidation#"></cfoutput>
					<cfloop list="#lCategoryBranch#" index="i">
						<!--- If the item is the actual alias requested then it is not selectable. --->
						<cfif i EQ rootID>
							<cfif len(arguments.stMetadata.ftDropdownFirstItem)>
								<cfoutput><option value="">#arguments.stMetadata.ftDropdownFirstItem#</option></cfoutput>
							<cfelse>
								<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='dmCategory') />
								<cfoutput><option value="">#CategoryName#</option></cfoutput>
							</cfif>
							
						<cfelse>
							<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='dmCategory') />
							<cfoutput><option value="#i#" <cfif listContainsNoCase(lSelectedCategoryID, i)>selected</cfif>>#CategoryName#</option></cfoutput>
						</cfif>
						
					</cfloop>
					<cfoutput></select></cfoutput>
					<cfoutput></fieldset></cfoutput>
				</cfsavecontent>
			</cfcase>
			
			<cfcase value="prototype">
				<cfsavecontent variable="html">
				
					<cfoutput><fieldset style="width: 300px;">
						<cfif len(arguments.stMetadata.ftLegend)><legend>#arguments.stMetadata.ftLegend#</legend></cfif>
					
						<div class="fieldsection optional full">
												
							<div class="fieldwrap">
							</cfoutput>

								<ft:NTMPrototypeTree id="#arguments.fieldname#" navid="#rootID#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedCategoryID#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
							
							<cfoutput>
							</div>
							
							<br class="fieldsectionbreak" />
						</div>
						<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					</fieldset></cfoutput>
							
				</cfsavecontent>			
			</cfcase>
			<cfcase value="extjs">
				<!--- <skin:htmlHead library="extjs" />
				<skin:htmlHead library="farcryForm" /> --->
				
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
						<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#lSelectedCategoryID#" />
						<input type="hidden" name="#arguments.fieldname#" value="" />
					</fieldset>
					</cfoutput>
				
								
				</cfsavecontent>

			
				<extjs:onReady>
				<cfoutput>
				    createFormtoolTree('#arguments.fieldname#','#rootID#', '#application.url.webtop#/facade/getCategoryNodes.cfm', '#rootNodeText#','#lSelectedCategoryID#', 'categoryIconCls');											
				</cfoutput>
				</extjs:onReady>
			</cfcase>
			<cfcase value="jquery">
				

				<skin:onReady>
				<cfoutput>
					$j("###arguments.fieldname#_list").treeview({
						url: "#application.url.webtop#/facade/getCategoryNodes.cfm?node=#rootID#&fieldname=#arguments.fieldname#&multiple=#arguments.stMetadata.ftSelectMultiple#&lSelectedItems=#lSelectedCategoryID#"
					})
				</cfoutput>
				</skin:onReady>
				
				<cfsavecontent variable="html">
				

					<cfoutput>
					<div class="multiField">
						<ul id="#arguments.fieldname#_list" class="treeview"></ul>
					</div>
					<input type="hidden" name="#arguments.fieldname#" value="" />	
					</cfoutput>
					
				</cfsavecontent>			
			</cfcase>
			
			
			<cfdefaultcase>
				
				<skin:loadJS id="jquery" />
				<skin:loadJS id="jquery-checkboxtree" basehref="#application.url.webtop#/thirdparty/checkboxtree/js" lFiles="jquery.checkboxtree.js" />
				<skin:loadCSS id="jquery-checkboxtree" basehref="#application.url.webtop#/thirdparty/checkboxtree/css" lFiles="checkboxtree.css" />
					
							
				<skin:onReady>
				<cfoutput>
					$j.ajax({
					   type: "POST",
					   url: '#application.fapi.getLink(type="dmCategory", objectid="#rootID#", view="displayCheckboxTree", urlParameters="ajaxmode=1")#',
					   data: {
					   	fieldname: '#arguments.fieldname#',
					   	rootNodeID:'#rootID#', 
					   	selectedObjectIDs: '#lSelectedCategoryID#'
						},
					   cache: false,
					   success: function(msg){
					   		$j("###arguments.fieldname#-checkboxDiv").html(msg);
							$j("###arguments.fieldname#-checkboxTree").checkboxTree({
									collapsedarrow: "#application.url.webtop#/thirdparty/checkboxtree/images/checkboxtree/img-arrow-collapsed.gif",
									expandedarrow: "#application.url.webtop#/thirdparty/checkboxtree/images/checkboxtree/img-arrow-expanded.gif",
									blankarrow: "#application.url.webtop#/thirdparty/checkboxtree/images/checkboxtree/img-arrow-blank.gif",
									checkchildren: false,
									checkparents: false
							});	
							$j("###arguments.fieldname#-checkboxDiv input:checked").addClass('mjb');	 
							$j("###arguments.fieldname#-checkboxDiv input:checked").parent().addClass('mjb');	     	
					   }
					 });
				
					
				</cfoutput>
				</skin:onReady>
				
				<cfsavecontent variable="html">
				

					<cfoutput>
					<div class="multiField">
						<div id="#arguments.fieldname#-checkboxDiv">loading...</div>
						<input type="hidden" name="#arguments.fieldname#" value="" />			
					</div>
					</cfoutput>
					
				</cfsavecontent>			
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
		
		<!---
		
		<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
			<cfinvokeargument name="objectID" value="#stObject.ObjectID#"/>
			<cfinvokeargument name="bReturnCategoryIDs" value="false"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
		</cfinvoke>
		
		<cfsavecontent variable="html">
			<cfoutput>#lSelectedCategoryID#</cfoutput>
		</cfsavecontent> --->
		
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
		<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
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



