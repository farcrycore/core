<cfcomponent extends="farcry.fourq.fourq" name="plpUtitlities" displayname="plpUtitlities" hint="utilities to handle plp functionalitys">
	<cffunction name="fRead" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="bPLPStorage" type="string" required="false" default="yes">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.stPLP = StructNew()>
		<cfset stLocal.objectid =  arguments.objectid>
		<cfset stLocal.bPLPStorage =  arguments.bPLPStorage>

		<cfif stLocal.bPLPStorage>
			<cflock name="_plpaccess" timeout="10">
				<cffile action="read" file="#application.path.plpstorage#/#session.dmSec.authentication.userlogin#_#arguments.objectid#.plp" variable="stLocal.wddxPLP">
				<cfwddx action="wddx2cfml" input="#stLocal.wddxPLP#" output="stLocal.stPLP">
			</cflock>
		<cfelse>
			<cfset stLocal.typename = findType(stLocal.objectid)>
			<cfset stLocal.objType = CreateObject("component","#application.types[stLocal.typename].typepath#")>
			<cfset stLocal.stObj = stLocal.objType.getData(stLocal.objectid)>
			<cfset stLocal.stObj = stLocal.objType.getData(stLocal.objectid)>
			<cfset stLocal.stPLP = StructNew()>
			<cfset stLocal.stPLP.plp = StructNew()>
			<cfset stLocal.stPLP.plp.output = StructCopy(stLocal.stObj)>
			<cfset stLocal.stPLP.plp.input = StructCopy(stLocal.stObj)>
		</cfif>
		<cfoutput>reading file: #application.path.plpstorage#/#session.dmSec.authentication.userlogin#_#arguments.objectid#.plp<br /></cfoutput>
		<cfreturn stLocal.stPLP>
	</cffunction>

	<cffunction name="fWrite" access="public" output="false" returntype="struct">
		<cfargument name="stPLP" type="struct" required="true">
		<cfargument name="bPLPStorage" type="string" required="false" default="yes">
		<cfset stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
<!--- TODO: trp erroros and return a more meaningful errormessage --->		
		<cftry>
			<cfif arguments.bPLPStorage>
				<cflock name="_plpaccess" timeout="10">
					<cfwddx action="cfml2wddx" input="#arguments.stPLP#" output="stLocal.wddxPLP">
					<cffile action="write" file="#application.path.plpstorage#/#session.dmSec.authentication.userlogin#_#arguments.stPLP.plp.output.objectID#.plp" output="#stLocal.wddxPLP#" addnewline="No" charset="utf-8">
				</cflock>

			<cfelse>
				<cfset stLocal.stProps = arguments.stPLP.plp.output>
				<cfset stLocal.typename = findType(stLocal.stProps.objectid)>
				<cfset stLocal.objType = CreateObject("component","#application.types[stLocal.typename].typepath#")>
				<cfset stLocal.objType.setData(stLocal.stProps)>
			</cfif>

			<cfcatch>

			</cfcatch>
		</cftry>
		<cfreturn stLocal.returnstruct>
	</cffunction>
	
	<cffunction name="fGetArrayObjects" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true" hint="primary object id of the plp">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" required="false" default="yes">

		<cfset var stLocal = StructNew()>		
		<cfset stLocal.aObjectIDs = StructNew()>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>
		<cfset stLocal.aObjectIDs.input = stLocal.stPLP.plp.input[arguments.propertieName]>
		<cfset stLocal.aObjectIDs.output = stLocal.stPLP.plp.output[arguments.propertieName]>
		<cfreturn stLocal.aObjectIDs>
	</cffunction>

	<cffunction name="fReadPropertie" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true" hint="primary object id of the plp">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" required="false" default="yes">
		
		<cfset var stLocal = StructNew()>
		
		<cfset stLocal.propertyValue = StructNew()>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>
		<cfset stLocal.propertyValue.input = stLocal.stPLP.plp.input[arguments.propertieName]>
		<cfset stLocal.propertyValue.output = stLocal.stPLP.plp.output[arguments.propertieName]>
		<cfreturn stLocal.propertyValue>
	</cffunction>

	<cffunction name="fAppendPropertie" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true" hint="primary object id of the plp">
		<cfargument name="propertieName" type="string" required="true" hint="the name of the plp propertie you wish to update">
		<cfargument name="propertieValue" type="string" required="true" hint="the value of the plp propertie you wish to update">
		<cfargument name="bPLPStorage" type="string" required="false" default="yes">		

		<cfset var stLocal = StructNew()>
		<cfset var stReturn = StructNew()>
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "">
		
		<cfset stLocal.propertyValue = StructNew()>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>

		<cfif IsArray(stLocal.stPLP.plp.input[arguments.propertieName])>
			<cfset stLocal.lTempValue = ArrayAppend(stLocal.stPLP.plp.input[arguments.propertieName],ListToArray(arguments.propertieValue))>
		<cfelse>
			<cfset stLocal.lTempValue = ListAppend(stLocal.stPLP.plp.input[arguments.propertieName],arguments.propertieValue)>
		</cfif>

		<cfset stLocal.stPLP.plp.input[arguments.propertieName] = stLocal.lTempValue>

		<cfif IsArray(stLocal.stPLP.plp.output[arguments.propertieName])>
			<cfset stLocal.lTempValue = ArrayAppend(stLocal.stPLP.plp.output[arguments.propertieName],ListToArray(arguments.propertieValue))>
		<cfelse>
			<cfset stLocal.lTempValue = ListAppend(stLocal.stPLP.plp.output[arguments.propertieName],arguments.propertieValue)>
		</cfif>

		<cfset stLocal.stPLP.plp.output[arguments.propertieName] = stLocal.lTempValue>
		<cfset stLocal.stPLP = fWrite(stLocal.stPLP,arguments.bPLPStorage)>

		<cfreturn stReturn>
	</cffunction>

	<cffunction name="fDeleteArrayObjects" access="public" output="false">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="lDelObjectid" type="string" required="true">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" default="yes" required="false" hint="flag whether to read for plp file or object database">				

		<cfset var stLocal = StructNew()>
		<cfset stLocal.lDelObjectid = arguments.lDelObjectid>

		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>
		<cfloop index="stLocal.delObjectID" list="#stLocal.lDelObjectid#">			
			<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>

			<!--- delete the objectids from the plp array or list --->
			<cfif IsArray(stLocal.stPLP.plp.input[arguments.propertieName])>
				<cfset stLocal.lObjectids = ArrayToList(stLocal.stPLP.plp.input[arguments.propertieName])>
				<cfset stLocal.aObjects = stLocal.stPLP.plp.input[arguments.propertieName]>
			<cfelse>
				<cfset stLocal.lObjectids = stLocal.stPLP.plp.input[arguments.propertieName]>
				<cfset stLocal.aObjects = ListToArray(stLocal.stPLP.plp.input[arguments.propertieName])>
			</cfif>

			<cfset stLocal.iPosition = ListFindNoCase(stLocal.lObjectids,stLocal.delObjectID)>
			<cfif stLocal.iPosition GTE 1>
				<cfset ArrayDeleteAt(stLocal.aObjects,stLocal.iPosition)>
			</cfif>
			
			<cfif IsArray(stLocal.stPLP.plp.input[arguments.propertieName])>
				<cfset stLocal.stPLP.plp.input[arguments.propertieName] = stLocal.aObjects>
			<cfelse>
				<cfset stLocal.stPLP.plp.input[arguments.propertieName] = ArrayToList(stLocal.aObjects)>
			</cfif>

			<cfif IsArray(stLocal.stPLP.plp.output[arguments.propertieName])>
				<cfset stLocal.lObjectids = ArrayToList(stLocal.stPLP.plp.output[arguments.propertieName])>
				<cfset stLocal.aObjects = stLocal.stPLP.plp.output[arguments.propertieName]>
			<cfelse>
				<cfset stLocal.lObjectids = stLocal.stPLP.plp.output[arguments.propertieName]>
				<cfset stLocal.aObjects = ListToArray(stLocal.stPLP.plp.output[arguments.propertieName])>
			</cfif>

			<cfset stLocal.iPosition = ListFindNoCase(stLocal.lObjectids,stLocal.delObjectID)>
			<cfif stLocal.iPosition GTE 1>
				<cfset ArrayDeleteAt(stLocal.aObjects,stLocal.iPosition)>
			</cfif>
			
			<cfif IsArray(stLocal.stPLP.plp.output[arguments.propertieName])>
				<cfset stLocal.stPLP.plp.output[arguments.propertieName] = stLocal.aObjects>
			<cfelse>
				<cfset stLocal.stPLP.plp.output[arguments.propertieName] = ArrayToList(stLocal.aObjects)>
			</cfif>
		</cfloop>
		<cfset stLocal.stPLP = fWrite(stLocal.stPLP,arguments.bPLPStorage)>
	</cffunction>

	<cffunction name="fAddArrayObjects" access="public" output="false" hint="Add a list of object ids to the plp array properties">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="lAddObjectid" type="string" required="true">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" default="yes" required="false" hint="flag whether to read for plp file or object database">								

		<cfset var stLocal = StructNew()>
		<cfset stLocal.lAddObjectid = arguments.lAddObjectid>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>

		<cfset stLocal.lExcludeInput = ArrayToList(stLocal.stPLP.plp.input[arguments.propertieName])>
		<cfset stLocal.lExcludeOutput = ArrayToList(stLocal.stPLP.plp.output[arguments.propertieName])>
		
		<cfloop index="stLocal.addObjectID" list="#stLocal.lAddObjectid#">
			<cfif NOT ListFindNoCase(stLocal.lExcludeInput,stLocal.addObjectID)>
				<cfset ArrayAppend(stLocal.stPLP.plp.input[arguments.propertieName],stLocal.addObjectID)>
			</cfif>

			<cfif NOT ListFindNoCase(stLocal.lExcludeOutput,stLocal.addObjectID)>
				<cfset ArrayAppend(stLocal.stPLP.plp.output[arguments.propertieName],stLocal.addObjectID)>
			</cfif>
		</cfloop>
		<cfset stLocal.stPLP = fWrite(stLocal.stPLP,arguments.bPLPStorage)>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>
	</cffunction>
	
	<cffunction name="fRepositionArrayObjects" access="public" output="false" hint="reposition a plp properties array or list">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="lobjectid" type="string" required="true">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" default="yes" required="false" hint="flag whether to read for plp file or object database">				

		<cfset var stLocal = StructNew()>
		<cfset stLocal.objectidpos1 = ListFirst(arguments.lobjectid)>
		<cfset stLocal.objectidpos2 = Listlast(arguments.lobjectid)>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>

		<!--- update plp input // propertie can be either a list or an array .: must account for both types --->
		<cfif IsArray(stLocal.stPLP.plp.input[arguments.propertieName])>
			<cfset stLocal.lObjectIDs = ArrayToList(stLocal.stPLP.plp.input[arguments.propertieName])>
			<cfset stLocal.aObjects = stLocal.stPLP.plp.input[arguments.propertieName]>
		<cfelse>
			<cfset stLocal.lObjectIDs = stLocal.stPLP.plp.input[arguments.propertieName]>
			<cfset stLocal.aObjects = ListToArray(stLocal.stPLP.plp.input[arguments.propertieName])>
		</cfif>

		<cfset stLocal.iPosition1 = ListFindNoCase(stLocal.lObjectIDs,stLocal.objectidpos1)>
		<cfset stLocal.iPosition2 = ListFindNoCase(stLocal.lObjectIDs,stLocal.objectidpos2)>
		<cfif stLocal.iPosition1 NEQ 0 AND stLocal.iPosition2 NEQ 0>
			<cfset stLocal.aTemp = stLocal.aObjects[stLocal.iPosition1]>
			<cfset stLocal.aObjects[stLocal.iPosition1] = stLocal.aObjects[stLocal.iPosition2]>
			<cfset stLocal.aObjects[stLocal.iPosition2] = stLocal.aTemp>
		</cfif>
		<cfif IsArray(stLocal.stPLP.plp.input[arguments.propertieName])>
			<cfset stLocal.stPLP.plp.input[arguments.propertieName] = stLocal.aObjects>
		<cfelse>
			<cfset stLocal.stPLP.plp.input[arguments.propertieName] = ArrayToList(stLocal.aObjects)>
		</cfif>

		<!--- update plp output // propertie can be either a list or an array .: must account for both types --->
		<cfif IsArray(stLocal.stPLP.plp.output[arguments.propertieName])>
			<cfset stLocal.lObjectIDs = ArrayToList(stLocal.stPLP.plp.output[arguments.propertieName])>
			<cfset stLocal.aObjects = stLocal.stPLP.plp.output[arguments.propertieName]>
		<cfelse>
			<cfset stLocal.lObjectIDs = stLocal.stPLP.plp.output[arguments.propertieName]>
			<cfset stLocal.aObjects = ListToArray(stLocal.stPLP.plp.output[arguments.propertieName])>
		</cfif>
		
		<cfset stLocal.iPosition1 = ListFindNoCase(stLocal.lObjectIDs,stLocal.objectidpos1)>
		<cfset stLocal.iPosition2 = ListFindNoCase(stLocal.lObjectIDs,stLocal.objectidpos2)>

		<cfif stLocal.iPosition1 NEQ 0 AND stLocal.iPosition2 NEQ 0>
			<cfset stLocal.aTemp = stLocal.aObjects[stLocal.iPosition1]>
			<cfset stLocal.aObjects[stLocal.iPosition1] = stLocal.aObjects[stLocal.iPosition2]>
			<cfset stLocal.aObjects[stLocal.iPosition2] = stLocal.aTemp>
		</cfif>

		<cfif IsArray(stLocal.stPLP.plp.output[arguments.propertieName])>
			<cfset stLocal.stPLP.plp.output[arguments.propertieName] = stLocal.aObjects>
		<cfelse>
			<cfset stLocal.stPLP.plp.output[arguments.propertieName] = ArrayToList(stLocal.aObjects)>
		</cfif>
		
		<cfset stLocal.stPLP = fWrite(stLocal.stPLP,arguments.bPLPStorage)>

	</cffunction>

	<cffunction name="fGenerateObjectsArray" access="public" output="false" returntype="array" hint="returns ar[0].text,ar[0].value'">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="lTypename" type="string" required="true">
		<cfargument name="propertieName" type="string" default="aObjectIDs" required="false" hint="name of the array you wish to return">
		<cfargument name="bPLPStorage" type="string" default="yes" required="false" hint="flag whether to read for plp file or object database">

		<cfset var stLocal = StructNew()>
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">		

		<cfset stLocal.aObjectIDs = StructNew()>
		<cfset stLocal.stPLP = fRead(arguments.objectid,arguments.bPLPStorage)>

		<cfset stLocal.iCounter = 1>
		<cfset stLocal.arItems = ArrayNew(1)>
		<cfset stLocal.plpItems =  stLocal.stPLP.plp.output[arguments.propertieName]>
		<cfif IsArray(stLocal.plpItems)>
			<cfset stLocal.arPLPObjects = stLocal.plpItems>
		<cfelse>
			<cfset stLocal.arPLPObjects = ListToArray(stLocal.plpItems)>
		</cfif>
		<cfset stLocal.objImage = CreateObject("component","#application.types.dmImage.typepath#")>
		<cfloop index="stLocal.i" from="1" to="#ArrayLen(stLocal.arPLPObjects)#">
			<q4:contentobjectget objectid="#stLocal.arPLPObjects[stLocal.i]#" r_stobject="stLocal.stItem">

			<!--- only add to  --->
			<cfif NOT(StructIsEmpty(stLocal.stItem)) AND ListFindNoCase(arguments.lTypename,stLocal.stItem.typename)>
				<cfset stLocal.arItems[stLocal.iCounter] = StructNew()>
				<cfset stLocal.arItems[stLocal.iCounter].text = JSStringFormat(stLocal.stItem.label)>
				<cfset stLocal.arItems[stLocal.iCounter].objectid = stLocal.stItem.objectID>
				<cfswitch expression="#stLocal.stItem.typename#">
					<cfcase value="dmImage">
						<cfset stLocal.imageurl = stLocal.objImage.getURLImagePath(stLocal.stItem.objectID,"original")>
						<cfif stLocal.stItem.optimisedimage neq "">
							<cfset stLocal.imageurl_optimised = stLocal.objImage.getURLImagePath(stLocal.stItem.objectID,"optimised")>
							<cfset stLocal.arItems[stLocal.iCounter].value = JSStringFormat("#stLocal.stItem.objectID#|<a href='#stLocal.imageurl_optimised#' target='_blank'><img src='#stLocal.imageurl#' border=0 alt='#stLocal.stItem.alt#'></a>")>
						<cfelse>
							<cfset stLocal.arItems[stLocal.iCounter].value = JSStringFormat("#stLocal.stItem.objectID#|<img src='#stLocal.imageurl#' border=0 alt='#stLocal.stItem.alt#'>")>
						</cfif>
					</cfcase>
		
					<cfcase value="dmFile">
						<cfif application.config.general.fileDownloadDirectLink eq "false">
							<cfset stLocal.arItems[stLocal.iCounter].value = JSStringFormat("#stLocal.stItem.objectID#|<a href='#application.url.webroot#/download.cfm?DownloadFile=#stLocal.stItem.objectid#' target='_blank'>#stLocal.stItem.title#</a>")>
						<cfelse>
							<cfset stLocal.arItems[stLocal.iCounter].value = JSStringFormat("#stLocal.stItem.objectID#|<a href='#application.url.webroot#/files/#stLocal.stItem.filename#' target='_blank'>#stLocal.stItem.title#</a>")>
						</cfif>
					</cfcase>

					<cfdefaultcase>
						<cfset stLocal.arItems[stLocal.iCounter].value = JSStringFormat(stLocal.stItem.label)>
					</cfdefaultcase>
				</cfswitch>
				<cfset stLocal.iCounter = stLocal.iCounter + 1>
			</cfif>
		</cfloop>
		<cfreturn stLocal.arItems>
	</cffunction>
</cfcomponent>