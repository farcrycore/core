<!--- @@description:
	<p>Provides an interface for linking types together</p> --->
	
<!--- @@examples:
	<p>Basic</p>
	<code>
		<cfproperty name="playjoin" type="array" 
				ftType="array"  
				ftJoin="dmNews">
	</code> 
	<p>Dont allow user to create new record</p>
	<code>
		<cfproperty name="playjoin" type="array"
				ftType="array"  
				ftJoin="dmNews" 
				ftAllowCreate="false">
	</code>
	<p>Dont allow user to select from existing records, only create</p>
	<code>
		<cfproperty name="playjoin" type="array"
				ftType="array"  
				ftJoin="dmNews" 
				ftAllowSelect="false">
	</code>
	<p>Allow the user to edit the record directly from the library</p>
	<code>
		<cfproperty name="playjoin"  type="array" 
				ftType="array" 
				ftJoin="dmNews" 
				ftAllowEdit="true">
	</code>
	<p>Render the record library as a list with mutliple select</p>
	<code>
		<cfproperty name="playjoin" type="array" 
				ftType="array"  
				ftJoin="dmNews" 
				ftRenderType="list">
	</code>
	<p>Render the record library as a list without multiple select</p>
	<code>
		<cfproperty name="playjoin" type="array" 
				ftType="array"  
				ftJoin="dmNews" 
				ftRenderType="list" 
				ftSelectMultiple="false">
	</code>
	<p>Custom query to populate the library picker, myCustomQuery is a method in the type this property belongs</p>
	<code>
		<cfproperty name="playjoin" type="array"
				ftType="array"  
				ftJoin="dmNews" 
				ftLibraryData="myCustomQuery">
	</code>
	<p>Custom query with method in a different type</p>
	<code>
		<cfproperty name="playjoin" type="array"
				ftType="array" 
				ftJoin="dmNews" 
				ftLibraryData="myCustomQuery" 
				ftLibraryDataTypename="dmNews">
	</code>
--->
<cfcomponent extends="join" name="array" displayname="array" hint="Used to liase with Array type fields" bDocument="true"> 

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >

	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
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

		<cfset arguments.stMetadata = prepMetadata(stObject = arguments.stObject, stMetadata = arguments.stMetadata) />

		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		<cfparam name="arguments.stMetadata.ftJoin" default="">
		
		<!--- We need to get the Array Field Items as a query --->
		<cfset o = createObject("component",application.stcoapi[arguments.typename].packagepath)>
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
			
			<cfloop list="#stFieldPost.value#" index="i">			
				
				<!--- If it is an extended array (more than the standard 4 fields), we return the array as an array of structs --->
				<cfif structkeyexists(application.stCOAPI,"#arguments.typename#_#stMetadata.name#") or (structkeyexists(arguments.stMetadata,"arrayProps") and len(arguments.stMetadata.arrayProps))>
					<cfset stArrayData = structNew() />
					<cfset stArrayData.data = i />
					<cfset stArrayData.typename = application.fapi.findType(i) />
					<cfloop list="#qCurrentArrayItem.columnList#" index="iColumn">
						<cfset stArrayData[iColumn] = "" />
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
		<cfset var dataTypename = "" />
		<cfset var oData = "" />
		<cfset var stO = structNew() />
		<cfset var libraryData = "" />
		
		<cfset arguments.stMetadata = prepMetadata(stObject = arguments.stObject, stMetadata = arguments.stMetadata) />
		
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
				<select  id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" multiple="#arguments.stMetadata.ftSelectMultiple#">
				<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#"<cfif valuelist(qArrayField.data) contains qLibraryList.objectid> selected="selected"</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
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
			
</cfcomponent>