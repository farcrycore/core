<cfcomponent extends="join" name="UUID" displayname="UUID" hint="Used to liase with UUID type fields"> 

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var returnHTML = "" />
		<cfset var uuidTypename = "" />
		<cfset var oData = "" />
		<cfset var stobj = structNew() />
		
		
		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
			
		<!--- A UUID type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(stMetadata,"ftJoin")>
			<cfreturn returnHTML />
		</cfif>
		
		
		<cfif listLen(arguments.stMetadata.ftJoin) GT 1>
			<cfif len(arguments.stObject[arguments.stMetaData.Name])>
				<cfset uuidTypename = createObject("component", "farcry.core.packages.fourq.fourq").findType(objectid=arguments.stObject[arguments.stMetaData.Name]) />
			</cfif>
		<cfelse>
			<cfset uuidTypename = arguments.stMetadata.ftJoin />
		</cfif>
		
		<cfif len(uuidTypename)>
			<cfset oData = createObject("component",application.types[uuidTypename].typepath)>
			
			<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
				<cfset stobj = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
				<cfset returnHTML = oData.getView(stObject=stobj, template=arguments.stMetaData.ftLibrarySelectedWebskin, alternateHtml=stobj.label) />
			</cfif>
		</cfif>
		<cfreturn returnHTML>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
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
	
	<cffunction name="libraryCallback" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset var returnHTML = "" />
		<cfset var stobj = structnew() />
		<cfset var stJoinObjects = structNew() /> <!--- This will contain a structure of object components that match the ftJoin list from the metadata --->

		<cfset var oData = "" />
		<cfset var q4 = "" />
		<cfset var joinTypename = "" />
		<cfset var i = "" />
		<cfset var oPrimary = "" />
		<cfset var qLibraryList = queryNew("blah") />
		<cfset var ULID = "" />
		<cfset var HTML = "" />
		<cfset var stTemp = structNew() />
		
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
		<cfparam name="arguments.stMetadata.ftShowRemoveSelected" default="true">
		<cfparam name="arguments.stMetadata.ftAllowLibraryEdit" default="false">
		<cfparam name="arguments.stMetadata.ftLibraryEditWebskin" default="edit">


		
		<!--- An array type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(arguments.stMetadata,"ftJoin") or not len(arguments.stMetadata.ftJoin)>
			<cfreturn "">
		</cfif>
		
		
		<!--- Create each of the the Linked Table Types as an object  --->
		<cfloop list="#arguments.stMetadata.ftJoin#" index="i">			
			<cfset stJoinObjects[i] = createObject("component",application.types[i].typepath)>
		</cfloop>

		<!--- Make sure scriptaculous libraries are included. --->
		<cfset Request.InHead.ScriptaculousDragAndDrop = 1>
		<cfset Request.InHead.ScriptaculousEffects = 1>	

		
		<!--- Determine the the type we are using --->
		<cfif listLen(arguments.stMetadata.ftJoin) GT 1>
			<cfif len(arguments.stObject[arguments.stMetaData.Name])>
				<cfset uuidTypename = createObject("component", "farcry.core.packages.fourq.fourq").findType(objectid=arguments.stObject[arguments.stMetaData.Name]) />
			</cfif>
		<cfelse>
			<cfset uuidTypename = arguments.stMetadata.ftJoin />
		</cfif>
		
		<!--- Couldnt find the type so try the first type in the list. --->
		<cfif not len(uuidTypename)>
			<cfset uuidTypename = listFirst(arguments.stMetadata.ftJoin) />
		</cfif>
		
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.stcoapi[uuidTypename].packagePath)>
		
				
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
					<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="qLibraryList" />
				</cfif>
			</cfif>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfif NOT isDefined("qLibraryList")>
				<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
			</cfif>
	
			<cfsavecontent variable="returnHTML">
			<cfif qLibraryList.recordcount>
				<cfoutput>
				<select  id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" multiple="#arguments.stMetadata.ftSelectMultiple#" style="width:auto;">
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
				
					<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
										
						<cfif listLen(arguments.stMetadata.ftJoin) GT 1 >						
							<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
							<cfset joinTypename = q4.findType(objectid=arguments.stObject[arguments.stMetaData.Name])>
							<cfif len(joinTypename)>
								<cfset oData = createObject("component", application.stcoapi[joinTypename].packagePath) />
							<cfelse>
								<cfoutput><p>#arguments.stObject[arguments.stMetaData.Name]#: objectid does not exist in the database.</p></cfoutput>
								<cfabort>
							</cfif>
						<cfelse>
							<cfset oData = createObject("component", application.stcoapi[arguments.stMetadata.ftJoin].packagePath) />
						</cfif>
						
						<cfset HTML = oData.getView(objectID=arguments.stObject[arguments.stMetaData.Name], template="#arguments.stMetadata.ftLibrarySelectedWebskin#", alternateHTML="") />
						<cfif NOT len(trim(HTML))>
							<cfset stTemp = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
							<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
								<cfset HTML = stTemp.label />
							<cfelse>
								<cfset HTML = stTemp.objectid />
							</cfif>
						</cfif>

						
						<cfoutput>
						<li id="#arguments.fieldname#_#arguments.stObject[arguments.stMetaData.Name]#" class="#ULID#handle" style="<cfif len(arguments.stMetadata.ftLibraryListItemWidth)>width:#arguments.stMetadata.ftLibraryListItemWidth#;</cfif><cfif len(arguments.stMetadata.ftLibraryListItemheight)>height:#arguments.stMetadata.ftLibraryListItemHeight#;</cfif>">
							<div class="buttonGripper"><p>&nbsp;</p></div>
							
							<cfif arguments.stMetadata.ftShowRemoveSelected OR arguments.stMetadata.ftAllowLibraryEdit>
								<input type="checkbox" name="#arguments.fieldname#Selected" id="#arguments.fieldname#Selected" class="checkboxInput #arguments.fieldname#Selected" value="#arguments.stObject[arguments.stMetaData.Name]#" />
							</cfif>
							
							<div class="#arguments.stMetadata.ftLibrarySelectedListClass#">
								<p>#HTML#</p>
							</div>
								
						</li>
						</cfoutput>
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