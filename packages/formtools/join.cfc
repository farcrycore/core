<cfcomponent extends="farcry.core.packages.formtools.field" name="join" displayname="join" hint="Used to liase with join type fields (array and uuid)"> 


	<cfproperty name="ftLabelAlignment" required="false" default="inline" options="inline,block" hint="Used by FarCry Form Layouts for positioning of labels. inline or block." />

	<cfproperty name="ftAllowAttach" required="false" default="true" />
	<cfproperty name="ftAllowAdd" required="false" default="false" />
	<cfproperty name="ftAllowEdit" required="false" default="false" />
	<cfproperty name="ftRemoveType" required="false" default="detach" />
	
	<cfproperty name="ftLibrarySelectedWebskin" default="librarySelected" type="string" />
	<cfproperty name="ftLibrarySelectedListClass" default="arrayDetail" type="string" />
	<cfproperty name="ftLibrarySelectedListStyle" default="" type="string" />
	<cfproperty name="ftLibraryListItemWidth" default="" type="string" />
	<cfproperty name="ftLibraryListItemHeight" default="" type="string" />
	<cfproperty name="ftRenderType" default="Library" type="string" />
	<cfproperty name="ftSelectSize" default="" type="string" />
	<cfproperty name="ftSelectMultiple" default="true" type="boolean" />
	<cfproperty name="ftAllowLibraryEdit" default="false">
	<cfproperty name="ftLibraryEditWebskin" default="edit">
	<cfproperty name="ftFirstListLabel" default="-- SELECT --">
	<cfproperty name="ftLibraryData" default="" /><!--- Name of a function to return the library data --->
	<cfproperty name="ftLibraryDataTypename" default="" /><!--- Typename containing the function defined in ftLibraryData --->	
	
	
	

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />		
		<cfset var qArrayField = "" />
				
		
		<skin:loadJS id="jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
		

		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		
			<cfcase value="list">
				<cfif arguments.stMetadata.type EQ "array">		
					<cfset joinItems = arrayToList(arguments.stObject[arguments.stMetadata.name]) />
				<cfelse>
					<cfset joinItems = arguments.stObject[arguments.stMetadata.name] />
				</cfif>		
				
				<!-------------------------------------------------------------------------- 
				generate library data query to populate library interface 
				--------------------------------------------------------------------------->
				<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
				
					<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
						<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
					</cfif>
					<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
					
					<!--- use ftlibrarydata method from primary content type --->
					<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
						<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
							<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
							<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
						</cfinvoke>					
						
						<cfif isStruct(libraryData)>
							<cfset qLibraryList = libraryData.q>
						<cfelse>
							<cfset qLibraryList = libraryData />
						</cfif>					
					</cfif>
				<cfelse>
					<!--- if nothing exists to generate library data then cobble something together --->
					<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
				</cfif>
		
				<cfsavecontent variable="returnHTML">
				<cfif qLibraryList.recordcount>
					<cfoutput>
					<select  id="#arguments.fieldname#" name="#arguments.fieldname#" <cfif len(arguments.stMetadata.ftSelectSize)> size="#arguments.stMetadata.ftSelectSize#"</cfif> <cfif arguments.stMetadata.ftSelectMultiple>multiple="multiple"</cfif> style="width:auto;" class="selectInput #arguments.stMetadata.ftClass#">
					<cfif len(arguments.stMetadata.ftFirstListLabel) AND NOT arguments.stMetadata.ftSelectMultiple>
						<option value="">#arguments.stMetadata.ftFirstListLabel#</option>
					</cfif>
					<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#" <cfif listFindNoCase(joinItems,qLibraryList.objectid)>selected</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
					</select>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					
					</cfoutput>
					
					
				<cfelse>
					<!--- todo: i18n --->
					<cfoutput>
					<em>No options available.</em>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					</cfoutput>
				</cfif>
				
				</cfsavecontent>
			
			</cfcase>		
		
			<cfdefaultcase>
				<cfif arguments.stMetadata.type EQ "array">		
					<cfquery datasource="#application.dsn#" name="qArrayField">
					SELECT *
					FROM #arguments.typename#_#arguments.stMetaData.Name#
					WHERE parentID = '#arguments.stObject.objectID#'
					ORDER BY seq
					</cfquery>	
					<cfset joinItems = valueList(qArrayField.data) />
				<cfelse>
					<cfset joinItems = arguments.stObject[arguments.stMetadata.name] />
				</cfif>		
							
			
			
				<cfsavecontent variable="returnHTML">	
					<grid:div class="multiField">

		
					<cfif listLen(joinItems)>
						<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
							<cfset counter = 0 />
							<cfloop list="#joinItems#" index="i">
								<cfset counter = counter + 1 />
								<skin:view objectid="#i#" webskin="librarySelected" r_html="htmlLabel" />
								<cfoutput>
								<li id="join-item-#i#" class="sort #iif(counter mod 2,de('oddrow'),de('evenrow'))#" serialize="#i#" style="clear:both;margin-bottom:5px;">
									<div class="buttonGripper"><p></p></div>
									<div class="arrayDetail" style="float:left;">#htmlLabel#</div>
									<div class="join-remove" style="float:right;white-space: nowrap;">
										
										<cfif arguments.stMetadata.ftAllowEdit or 1 eq 1>
											<ft:button
												Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Edit"
												text="edit" 
												onClick="fcForm.openLibraryEdit('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
								
										</cfif>
										
										<cfif arguments.stMetadata.ftRemoveType EQ "delete">
											<ft:button
												Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Delete" 
												text="delete" 
												confirmText="Are you sure you want to delete this item" 
												onClick="fcForm.deleteLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
										<cfelseif arguments.stMetadata.ftRemoveType EQ "detach">
											<ft:button
												Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Detach" 
												text="detach" 
												confirmText="Are you sure you want to detach this item" 
												onClick="fcForm.detachLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
								
										</cfif>
										
									</div>
									<br style="clear:both;" />
								</li>
								</cfoutput>	
							</cfloop>
						<cfoutput></ul></cfoutput>
						
						<cfoutput><input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#joinItems#" /></cfoutput>
					</cfif>
					
					<ft:buttonPanel>
					<cfoutput>
						
						
							<cfif arguments.stMetadata.ftAllowAttach>
								<ft:button	Type="button" 
											renderType="button"
											class="ui-state-default ui-corner-all"
											value="attach" 
											onClick="fcForm.openLibrarySelect('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');" />
								
							</cfif>
							
							<cfif listLen(joinItems)>
								
								<cfif arguments.stMetadata.ftRemoveType EQ "delete">
									<ft:button	Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Delete All" 
												text="delete all" 
												confirmText="Are you sure you want to delete all the attached items?"
												onClick="fcForm.deleteAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />								
								<cfelseif arguments.stMetadata.ftRemoveType EQ "detach">
									<ft:button	Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Detach All" 
												text="detach all" 
												confirmText="Are you sure you want to detach all the attached items?"
												onClick="fcForm.detachAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />								
									
								</cfif>
							</cfif>
							<cfif arguments.stMetadata.ftAllowAdd or 1 eq 1>
								<ft:button	Type="button" 
											renderType="button"
											class="ui-state-default ui-corner-all"
											value="Add" 
											text="add" 
											onClick="fcForm.openLibraryAdd('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');" />
								
							</cfif>
						
					</cfoutput>
					</ft:buttonPanel>
					<cfif listLen(joinItems) GT 1>
						<cfoutput>
							<script type="text/javascript">
							$j(function() {
								fcForm.initSortable('#arguments.stobject.typename#','#arguments.stobject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');
							});
							</script>
						</cfoutput>
					</cfif>
					</grid:div>
				</cfsavecontent>
			</cfdefaultcase>
			
			
		</cfswitch>
		
		<cfif structKeyExists(request, "hideLibraryWrapper") AND request.hideLibraryWrapper>
			<cfreturn "#returnHTML#" />
		<cfelse>
			<cfreturn "<div id='#arguments.fieldname#-library-wrapper'>#returnHTML#</div>" />	
		</cfif>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var returnHTML = ""/>
		<cfset var i = "" />
		<cfset var o = "" />
		<cfset var q = "" />
		<cfset var ULID = "" />
		<cfset var stobj = "" />
		<cfset var html = "" />
		<cfset var oData = "" />

		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		<cfparam name="arguments.stMetadata.ftJoin" default="">
		
		<!--- We need to get the Array Field Items as a query --->
		<cfset o = createObject("component",application.stcoapi[arguments.typename].packagepath)>
		
		<cfif arguments.stMetadata.type EQ "array">
			<cfset q = o.getArrayFieldAsQuery(objectid="#arguments.stObject.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftJoin="#stMetadata.ftJoin#")>
			
			<cfsavecontent variable="returnHTML">
			<cfoutput>
					
				<cfset ULID = "#arguments.fieldname#_list">
				
				<cfif q.RecordCount>
				 
					<div id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
						<cfloop query="q">
							<!---<li id="#arguments.fieldname#_#q.objectid#"> --->
								
								<div>
									<cfif listContainsNoCase(arguments.stMetadata.ftJoin,q.typename)>
										<cfset oData = createObject("component",application.stcoapi[q.typename].packagepath) />
										<cfset stobj = oData.getData(objectid=q.data) />
										<cfif FileExists("#application.path.project#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm")>
											<cfset html = oData.getView(stObject=stobj,template="#arguments.stMetadata.ftLibrarySelectedWebskin#") />
											#html#								
											<!---<cfinclude template="/farcry/projects/#application.projectDirectoryName#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm"> --->
										<cfelse>
											#stobj.label#
										</cfif>
									<cfelse>
										INVALID ATTACHMENT (#q.typename#)
									</cfif>
								</div>
														
							<!---</li> --->
						</cfloop>
					</div>
				</cfif>
	
					
			</cfoutput>
			</cfsavecontent>			
		<cfelseif len(arguments.stObject[arguments.stMetaData.Name])>
			<cfset stobj = application.fapi.getContentObject(objectid=arguments.stObject[arguments.stMetaData.Name])>
			<cfset returnHTML = application.fapi.getContentType("#stobj.typename#").getView(stObject=stobj, template=arguments.stMetaData.ftLibrarySelectedWebskin, alternateHtml=stobj.label) />
		</cfif>
		
		

		<cfreturn returnHTML>
	</cffunction>


	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var aField = ArrayNew(1) />
		<cfset var qArrayRecords = queryNew("blah") />
		<cfset var stResult = structNew()>	
		<cfset var i = "" />
		<cfset var lColumn = "" />
		<cfset var qArrayRecordRow = queryNew("blah") />
		<cfset var stArrayData = structNew() />
		<cfset var iColumn = "" />
		<cfset var qCurrentArrayItem = queryNew("blah") />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<!---
		IT IS IMPORTANT TO NOTE THAT THE STANDARD ARRAY TABLE UI, PASSES IN A LIST OF DATA IDS WITH THEIR SEQ
		ie. dataid1:seq1,dataid2:seq2...
		 --->
		
		<cfif listLen(stFieldPost.value)>
			<!--- Remove any leading or trailing empty list items --->
			<cfif stFieldPost.value EQ ",">
				<cfset stFieldPost.value = "" />
			</cfif>
			<cfif left(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = right(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>
			<cfif right(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = left(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>	
					
			<cfquery datasource="#application.dsn#" name="qArrayRecords">
		    SELECT * 
		    FROM #application.dbowner##arguments.typename#_#stMetadata.name#
		    WHERE parentID = '#arguments.objectid#'
		    </cfquery>
		    	
			
			<cfloop list="#stFieldPost.value#" index="i">			
						
				<cfquery dbtype="query" name="qCurrentArrayItem">
			    SELECT * 
			    FROM qArrayRecords
			    WHERE data = '#listFirst(i,":")#'
			    <cfif listLast(i,":") NEQ listFirst(i,":")><!--- SEQ PASSED IN --->
			    	AND seq = #listLast(i,":")#
			    </cfif>
			    </cfquery>
			
				<!--- If it is an extended array (more than the standard 4 fields), we return the array as an array of structs --->
				<cfif listlen(qCurrentArrayItem.columnlist) GT 4>
					<cfset stArrayData = structNew() />
					
					<cfloop list="#qCurrentArrayItem.columnList#" index="iColumn">
						<cfif qCurrentArrayItem.recordCount>
							<cfset stArrayData[iColumn] = qCurrentArrayItem[iColumn][1] />
						<cfelse>
							<cfset stArrayData[iColumn] = "" />
						</cfif>
					</cfloop>
					
					<cfset stArrayData.seq = arrayLen(aField) + 1 />
					 
					<cfset ArrayAppend(aField,stArrayData)>
				<cfelse>
					<!--- Otherwise it is just an array of value --->
					<cfset ArrayAppend(aField, listFirst(i,":"))>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset stResult.value = aField>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
		
		
	<cffunction name="libraryCallback" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset var returnHTML = "" />
		<cfset var stobj = structnew() />
		<cfset var i = "" />
		<cfset var qArrayField = queryNew("blah") />
		<cfset var oPrimary = "" />
		<cfset var qLibraryList = queryNew("blah") />
		<cfset var ULID = "" />
		<cfset var HTML = "" />
		<cfset var stTemp = structNew() />
		<cfset var dataID = "" />
		<cfset var dataLabel = "" />
		<cfset var dataSEQ = "" />
		<cfset var oData = "" />
		<cfset var stO = structNew() />
		<cfset var libraryData = "" />
		
		
		
		<!---
		<cfset var oFourQ = createObject("component","farcry.core.packages.fourq.fourq")><!--- TODO: this needs to be removed when we add typename to array tables. ---> 
		 --->
		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="arrayDetail" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemWidth" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemHeight" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Library" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="10" type="numeric" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="string" />
		<cfparam name="arguments.stMetadata.ftAllowLibraryEdit" default="false">
		<cfparam name="arguments.stMetadata.ftLibraryEditWebskin" default="edit">
		<cfparam name="arguments.stMetadata.ftLibraryData" default="" /><!--- Name of a function to return the library data --->
		<cfparam name="arguments.stMetadata.ftLibraryDataTypename" default="" /><!--- Typename containing the function defined in ftLibraryData --->

		<!--- An array type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(arguments.stMetadata,"ftJoin") or not len(arguments.stMetadata.ftJoin)>
			<cfreturn "">
		</cfif>

		<!--- Make sure scriptaculous libraries are included. --->
		<cfset Request.InHead.ScriptaculousDragAndDrop = 1>
		<cfset Request.InHead.ScriptaculousEffects = 1>	
		
			
		<cfquery datasource="#application.dsn#" name="qArrayField">
		SELECT *
		FROM #arguments.typename#_#arguments.stMetaData.Name#
		WHERE parentID = '#arguments.stObject.objectID#'
		ORDER BY seq
		</cfquery>	
		
		<!--------------------------------------------- 
		RENDER TYPE SWITCH
			- select specific form element output
 		----------------------------------------------->
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		<cfcase value="list">
			
			<!-------------------------------------------------------------------------- 
			generate library data query to populate library interface 
			--------------------------------------------------------------------------->
			<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
				<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
					<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
				</cfif>
				<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
				
				<!--- use ftlibrarydata method from primary content type --->
				<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
					<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
						<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
						<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
					</cfinvoke>	
						
					<cfif isStruct(libraryData)>
						<cfset qLibraryList = libraryData.q>
					<cfelse>
						<cfset qLibraryList = libraryData />
					</cfif>		
					
				</cfif>
			</cfif>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfif NOT isDefined("qLibraryList")>
				<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
			</cfif>
	
			<cfsavecontent variable="returnHTML">
			<cfif qLibraryList.recordcount>
				<cfoutput>
				<select  id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" multiple="#arguments.stMetadata.ftSelectMultiple#" class="selectInput #arguments.stMetadata.class#">
				<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#" <cfif valuelist(qArrayField.data) contains qLibraryList.objectid>selected</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
				</select>
				</cfoutput>
				
			<cfelse>
				<!--- todo: i18n --->
				<cfoutput>
				<em>No options available.</em>
				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
				</cfoutput>
			</cfif>
			
			</cfsavecontent>
		
		</cfcase>
		
		<cfdefaultcase>
		
			<!--- ID of the unordered list. Important to use this so that the object can be referenced even if their are multiple objects referencing the same field. --->
			<cfset ULID = "#arguments.fieldname#_list">
			
			<cfsavecontent variable="returnHTML">
				
				<cfoutput>
				<ul id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#View" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
				</cfoutput>				

				<cfif qArrayField.Recordcount>
					
					<!-----------------------
					NEW ARRAY LAYOUT
					 ----------------------->					
					<cfloop query="qArrayField">
						
						<cfset dataID = qArrayField.data />
						<cfset dataSEQ = qArrayField.seq />
						<cfset dataTypename = qArrayField.typename />
						<cfset HTML = "" />
					
 						<cfif isDefined("qArrayField.label") AND len(qArrayField.label)>
							<cfset variables.alternateHTML = qArrayField.Label />
						<cfelse>
							<cfset variables.alternateHTML = "" />
						</cfif>
				
						<!--- if typename is missing from query (ie. array data is corrupted) --->
						<cfif NOT len(dataTypename)>
							<cfset dataTypename=application.coapi.coapiUtilities.findtype(objectid=dataID) />
							<cfif NOT len(dataTypename)>
								<cfset HTML = "Object Not Found">
							</cfif>
						</cfif> 
						<cfif NOT len(HTML)>
							<cfif not structKeyExists(stO, dataTypename) >
								<cfset stO[dataTypename] = createObject("component",application.stcoapi[dataTypename].packagepath) />
							</cfif>
							<cfset HTML = stO[dataTypename].getView(objectID="#dataID#", template="#arguments.stMetadata.ftLibrarySelectedWebskin#", alternateHTML=variables.alternateHTML) />
							<cfif NOT len(trim(HTML))>
								<cfset stTemp = stO[dataTypename].getData(objectid=dataID) />
								<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
									<cfset HTML = stTemp.label />
								<cfelse>
									<cfset HTML = stTemp.objectid />
								</cfif>
							</cfif>
						</cfif>
						
						<cfoutput>							
						<li id="#arguments.fieldname#_#dataID#:#dataSEQ#" class="#ULID#handle" style="<cfif len(arguments.stMetadata.ftLibraryListItemWidth)>width:#arguments.stMetadata.ftLibraryListItemWidth#;</cfif><cfif len(arguments.stMetadata.ftLibraryListItemheight)>height:#arguments.stMetadata.ftLibraryListItemHeight#;</cfif>">
							<div class="buttonGripper"><p>&nbsp;</p></div>
														
							<input type="checkbox" name="#arguments.fieldname#Selected" id="#arguments.fieldname#Selected" class="checkboxInput #arguments.fieldname#Selected" value="#dataID#:#dataSEQ#" />

							<div class="#arguments.stMetadata.ftLibrarySelectedListClass#">
								<p>#HTML#</p>
							</div>
								
						</li>
						</cfoutput>
					</cfloop>
					
				</cfif>

				<cfoutput>
				</ul>
				</cfoutput>
				
			
			</cfsavecontent>
		</cfdefaultcase>
		</cfswitch>
		
 		<cfreturn ReturnHTML />

	</cffunction>
		
	
	<cffunction name="getFilterUIOptions">
		<cfreturn "relatedTo" />
	</cffunction>
	
	<cffunction name="getFilterUI">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="renderType" />
		<cfargument name="stProps" />
		
		<!--- <cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.renderType#">
				
				<cfcase value="relatedto">
					
					<cfdump var="#arguments#" expand="false" label="arguments" />
					<cfparam name="arguments.stProps.relatedto" default="" />
					
					<ft:object objectID="stObject.objectid" typename="#arguments.filterTypename#" lFields="#arguments.filterProperty#">
					<cfoutput>
					<input type="string" name="#arguments.fieldname#relatedto" value="#arguments.stProps.relatedto#" />
					</cfoutput>
				</cfcase>
							
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
		
		 --->
		
		
		
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />		
		<cfset var qArrayField = "" />
		<cfset var stArrayPropMetadata = application.fapi.getPropertyMetadata(arguments.filterTypename, arguments.filterProperty) />
		
		<!--- IMPORT TAG LIBRARIES --->
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
		
		
		<cfparam name="stArrayPropMetadata.ftAllowAttach" default="true" />
		<cfparam name="stArrayPropMetadata.ftAllowAdd" default="false" />
		<cfparam name="stArrayPropMetadata.ftAllowEdit" default="false" />
		<cfparam name="stArrayPropMetadata.ftRemoveType" default="detach" />
		
		<cfsavecontent variable="returnHTML">	
			<cfif stArrayPropMetadata.type EQ "array">
				<cfparam name="arguments.stProps.relatedto" default="#arrayNew(1)#" />
				<cfset joinItems = arrayToList(arguments.stProps.relatedto) />
			<cfelse>
				<cfparam name="arguments.stProps.relatedto" default="" />
				<cfset joinItems = arguments.stProps.relatedto />
			</cfif>
						
			
			
			
			<cfif listLen(joinItems)>
				<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
					<cfset counter = 0 />
					<cfloop list="#joinItems#" index="i">
						<cfset counter = counter + 1 />
						<skin:view objectid="#i#" webskin="librarySelected" r_html="htmlLabel" />
						<cfoutput>
						<li id="join-item-#i#" class="sort #iif(counter mod 2,de('oddrow'),de('evenrow'))#" serialize="#i#" style="clear:both;">
							<div class="buttonGripper"><p></p></div>
							<div class="arrayDetail" style="margin-right:100px;float:left;">#htmlLabel#</div>
							<div class="join-remove" style="float:right;width:95px;">
								
								
								<ft:button
									Type="button" 
									renderType="button"
									class="ui-state-default ui-corner-all"
									value="Detach" 
									text="detach" 
									confirmText="Are you sure you want to detach this item" 
									onClick="fcForm.detachLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
						
								
							</div>
							<br style="clear:both;" />
						</li>
						</cfoutput>	
					</cfloop>
				<cfoutput></ul></cfoutput>
			</cfif>
			
			<cfoutput>
				<div style="background-color:##E1E1E1; border:1px solid ##ebebeb; border-width:0px 1px 1px 1px;padding:5px;">

					<ft:button	Type="button" 
								renderType="button"
								class="ui-state-default ui-corner-all"
								value="attach" 
								onClick="fcForm.openLibrarySelect('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');" />

					
					<cfif listLen(joinItems)>
						
							<ft:button	Type="button" 
										renderType="button"
										class="ui-state-default ui-corner-all"
										value="Detach All" 
										text="detach all" 
										confirmText="Are you sure you want to detach all the attached items?"
										onClick="fcForm.detachAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />								
						
					</cfif>
				</div>
			</cfoutput>
			
			<cfif listLen(joinItems) GT 1>
				<cfoutput>
					<script type="text/javascript">
					$j(function() {
						fcForm.initSortable('#arguments.stobject.typename#','#arguments.stobject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');
					});
					</script>
				</cfoutput>
			</cfif>
		</cfsavecontent>
		
		<cfif structKeyExists(request, "hideLibraryWrapper") AND request.hideLibraryWrapper>
			<cfreturn "#returnHTML#" />
		<cfelse>
			<cfreturn "<div id='#arguments.fieldname#-library-wrapper'>#returnHTML#</div>" />
		</cfif>
				
		
		
	</cffunction>
	

	<cffunction name="getFilterSQL">
		
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="renderType" />
		<cfargument name="stProps" />
		
		<cfset var resultHTML = "" />
		<cfset var stArrayPropMetadata = application.fapi.getPropertyMetadata(arguments.filterTypename, arguments.filterProperty) />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.renderType#">
				
				<cfcase value="relatedto">
					<cfparam name="arguments.stProps.relatedto" default="" />
					<cfif stArrayPropMetadata.type EQ "array">
						<cfif isArray(arguments.stProps.relatedto) AND arrayLen(arguments.stProps.relatedto)>

							<cfoutput>
								objectid IN (
									
									SELECT parentID
									FROM #arguments.filterTypename#_#arguments.filterProperty#
									WHERE data IN (#ListQualify(arrayToList(arguments.stProps.relatedto),"'",",","ALL")#)
																						
								)
							</cfoutput>
							
						</cfif>
					<cfelse>
						<cfif len(arguments.stProps.relatedto)>
							<cfoutput>#arguments.filterProperty# = '#arguments.stProps.relatedto#'</cfoutput>
						</cfif>
					</cfif>
				</cfcase>
				
			
			</cfswitch>
			
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
			
</cfcomponent>