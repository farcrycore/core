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
		<cfparam name="arguments.stMetadata.ftRenderType" default="ext" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="5" type="numeric" />
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="" type="string" />
		
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
		
		<cfif structKeyExists(application.navid, arguments.stMetadata.ftAlias)>
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
			
			<cfcase value="dropdownDoesNotWorkJustNow">
				<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=rootID) />
							
				<cfsavecontent variable="html">
					<cfoutput><fieldset>
					<p>Not quite ready yet.  Please use tree option.</p>
					</cfoutput>
					<!--- 
					TODO: 
						- this is slap dash copy from category picker; needs to be updated to Navigation nodes GB 20070511
						- see http://bugs.farcrycms.org:8080/browse/FC-731
					--->	
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
							<cfoutput><option value="#i#" <cfif listContainsNoCase(lSelectedNaviIDs, i)>selected</cfif>>#CategoryName#</option></cfoutput>
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
									<ft:NTMPrototypeTree id="#arguments.fieldname#" navid="#rootID#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedNaviIDs#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
								
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



