

<cfcomponent extends="field" name="navigation" displayname="navigation" hint="Field component to liase with all navigation field types"> 

	<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
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
		
		<cfparam name="arguments.stMetadata.ftAlias" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLegend" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Tree" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="5" type="numeric" />
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="" type="string" />
		
		<cfif structKeyExists(application.navid, arguments.stMetadata.ftAlias)>
			<cfset navid = application.navid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset navid = application.navid['root'] >
		</cfif>

		<cfset lSelectedNaviIDs = arguments.stObject['#arguments.stMetadata.name#'] />

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdownDoesNotWorkJustNow">
				<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=navid) />
							
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
						<cfif i EQ navid>
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
			
			<cfdefaultcase>
				<cfsavecontent variable="html">
					
						<cfoutput><fieldset style="width: 300px;">
							<cfif len(arguments.stMetadata.ftLegend)><legend>#arguments.stMetadata.ftLegend#</legend></cfif>
						
							<div class="fieldsection optional full">
													
								<div class="fieldwrap">
								</cfoutput>
<!---									<ft:prototypeTree id="#arguments.fieldname#" navid="#navid#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedNaviIDs#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
										<ft:prototypeTreeNode>
											<ft:prototypeTreeNode>
											
											</ft:prototypeTreeNode>
										</ft:prototypeTreeNode>
									</ft:prototypeTree> --->
									<ft:NTMPrototypeTree id="#arguments.fieldname#" navid="#navid#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedNaviIDs#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
								
								<cfoutput>
								</div>
								
								<br class="fieldsectionbreak" />
							</div>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
						</fieldset></cfoutput>
								
				</cfsavecontent>
			</cfdefaultcase>
			
		</cfswitch>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var returnHTML = ""/>

		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		
		<!--- We need to get the Array Field Items as a query --->
		<cfset o = createObject("component",application.types[arguments.typename].typepath)>
		<cfset q = o.getArrayFieldAsQuery(objectid="#arguments.stObject.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftJoin="#stMetadata.ftJoin#")>
	
		<cfset stJoinObjects = StructNew() />
		
		<!--- Create each of the the Linked Table Types as an object  --->
		<cfloop list="#arguments.stMetadata.ftJoin#" index="i">			
			<cfset stJoinObjects[i] = createObject("component",application.types[i].typepath)>
		</cfloop>

		
		<cfsavecontent variable="returnHTML">
		<cfoutput>
				
			<cfset ULID = "#arguments.fieldname#_list">
			
			<cfif q.RecordCount>
				<div id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
					<cfloop query="q">
						<!---<li id="#arguments.fieldname#_#q.objectid#"> --->
							
							<div>
							<cfset stobj = stJoinObjects[q.typename].getData(objectid=q.data) />
							<cfif FileExists("#application.path.project#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm")>
								<cfset html = stJoinObjects[q.typename].getView(stObject=stobj,template="#arguments.stMetadata.ftLibrarySelectedWebskin#") />
								#html#								
								<!---<cfinclude template="/farcry/projects/#application.applicationname#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm"> --->
							<cfelse>
								#stobj.label#
							</cfif>
							</div>
													
						<!---</li> --->
					</cfloop>
				</div>
			</cfif>

				
		</cfoutput>
		</cfsavecontent>

		<cfreturn returnHTML>
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



