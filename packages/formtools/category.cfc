<cfcomponent extends="field" name="category" displayname="category" hint="Field component to liase with all category field types"> 

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
		<cfset var lSelectedCategoryID = oCategory.getCategories(objectid=arguments.stObject.ObjectID,bReturnCategoryIDs=true)>
		<cfset var lCategoryBranch = "" />
		<cfset var CategoryName = "" />
		<cfset var i = "" />
		<cfset var rootNodeText = "" />
		<cfset var rootID = "" />
		
		
		<cfparam name="arguments.stMetadata.ftAlias" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLegend" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="ext" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="5" type="numeric" />
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="" type="string" />
		
		<cfif structKeyExists(application.catid, arguments.stMetadata.ftAlias)>
			<cfset rootID = application.catid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset rootID = application.catid['root'] >
		</cfif>
		
		<cfset rootNodeText = oCategory.getCategoryNamebyID(categoryid=rootID) />


		

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdown">
				<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=rootID) />
							
				<cfsavecontent variable="html">
					<cfoutput><fieldset></cfoutput>
					<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"  <cfif arguments.stMetadata.ftSelectMultiple>size="#arguments.stMetadata.ftSelectSize#" multiple="true"</cfif>></cfoutput>
					<cfloop list="#lCategoryBranch#" index="i">
						<!--- If the item is the actual alias requested then it is not selectable. --->
						<cfif i EQ rootID>
							<cfif len(arguments.stMetadata.ftDropdownFirstItem)>
								<cfoutput><option value="">#arguments.stMetadata.ftDropdownFirstItem#</option></cfoutput>
							<cfelse>
								<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='categories') />
								<cfoutput><option value="">#CategoryName#</option></cfoutput>
							</cfif>
							
						<cfelse>
							<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='categories') />
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
			
			<cfdefaultcase>
				<skin:htmlHead library="extjs" />
				<skin:htmlhead library="farcryForm" />
				
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
					</fieldset>
					</cfoutput>
				
								
				</cfsavecontent>

			
				<extjs:onReady>
				<cfoutput>
				    createFormtoolTree('#arguments.fieldname#','#rootID#', '#application.url.webtop#/facade/getCategoryNodes.cfm', '#rootNodeText#','#lSelectedCategoryID#', 'categoryIconCls');											
				</cfoutput>
				</extjs:onReady>
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
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
	
		<cfif listLen(stObject[stMetadata.name])>
			<cfloop list="#stObject[stMetadata.name]#" index="catid">
				<cfif structKeyExists(application.catID, catid) >				
					<cfset html = listAppend(html,application.catID[catid]) />
				</cfif>
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

</cfcomponent> 



