 <cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>



<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.ObjectID" default=""><!--- ObjectID of object to render --->
	<cfparam name="attributes.stObj" default=""><!--- Object to render --->
	<cfparam name="attributes.typename" default=""><!--- Type of Object to render --->
	<cfparam name="attributes.ObjectLabel" default=""><!--- Used to group and label rendered object if required --->
	<cfparam name="attributes.lFields" default=""><!--- List of fields to render --->
	<cfparam name="attributes.lExcludeFields" default=""><!--- List of fields to exclude from render --->
	<cfparam name="attributes.class" default="farcryform"><!--- class with which to set all farcry form tags --->
	<cfparam name="attributes.style" default=""><!--- style with which to set all farcry form tags --->
	<cfparam name="attributes.format" default="edit"><!--- edit or display --->
	<cfparam name="attributes.IncludeLabel" default="1">
	<cfparam name="attributes.IncludeFieldSet" default="1">
	<cfparam name="attributes.IncludeBR" default="1">
	<cfparam name="attributes.InTable" default="1">
	<cfparam name="attributes.insidePLP" default="0"><!--- how are we rendering the form --->
	<cfparam name="attributes.r_stFields" default=""><!--- the name of the structure that is to be returned with the form field information. --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#"><!--- This is used to override the default metadata as setup in the type.cfc --->
	
	<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"label,objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated")>
	
	
	<cfif len(attributes.ObjectID)>
		<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
			<cfset q4 = createObject("component", "farcry.fourq.fourq")>
			<cfset attributes.typename = q4.findType(objectid=attributes.objectid)>
		</cfif>
		
		<cfset stType = createobject("component",application.types[attributes.typename].typepath)>
		<cfset lFields = StructKeyList(application.types[attributes.typename].stprops)>
		<cfset stFields = application.types[attributes.typename].stprops>
		<cfset typename = attributes.typename>
		<cfset ObjectID = attributes.ObjectID>
			
		<cfif attributes.insidePLP EQ "1" and isDefined("CALLER.stPLP.plp.outputObjects") AND structKeyExists(CALLER.stPLP.plp.outputObjects,attributes.ObjectID)>		
			<cfset stObj = CALLER.stPLP.plp.outputObjects[attributes.ObjectID]>
		<cfelse>			
			<cfset stObj = stType.getData(attributes.objectID)>
		</cfif>
	
	<cfelseif isStruct(attributes.stObj)>
	
		<cfset stType = createobject("component",application.types[stObj.typename].typepath)>
		<cfset stObj = attributes.stObj>
		<cfset lFields = StructKeyList(application.types[stObj.typename].stprops)>
		<cfset stFields = application.types[stObj.typename].stprops>
		<cfset typename = stObj.typename>
		<cfset ObjectID = attributes.stObj.ObjectID>
		
	<cfelseif len(attributes.typename)>
	
		<cfset stType = createobject("component",application.types[attributes.typename].typepath)>
		<cfset lFields = StructKeyList(application.types[attributes.typename].stprops)>
		<cfset stFields = application.types[attributes.typename].stprops>
		<cfset typename = attributes.typename>
		<cfset stObj = stType.getData(objectID="#CreateUUID()#")>
		<cfset ObjectID = stObj.objectID>
	</cfif>

	
	<cfif isDefined("stObj") and not structIsEmpty(stObj)>
		<cfset stType.setlock(stObj=stObj,locked="true",lockedby="")>
	</cfif>
	

	<cfset lFieldsToRender =  "">
	
	<cfif not len(attributes.lFields)>
		<cfset attributes.lFields = variables.lFields>
	</cfif>	
	
	<!--- Determine fields to render --->
		<cfloop list="#attributes.lFields#" index="i">
			<cfif ListFindNoCase(variables.lFields,i)>
				<cfset lFieldsToRender =  listappend(lFieldsToRender,i)>
			</cfif>
		</cfloop>
	
	<!--- Determine fields to exclude from render --->
	<cfif isDefined("attributes.lExcludeFields") and len(attributes.lExcludeFields)>
		<cfloop list="#lFieldsToRender#" index="i">
			<cfif ListFindNoCase(attributes.lExcludeFields,i)>
				<cfset lFieldsToRender =  listdeleteat(lFieldsToRender,ListFindNoCase(lFieldsToRender,i))>
			</cfif>
		</cfloop>
	</cfif>
	
	
	<!--- CHECK TO SEE IF OBJECTED HAS ALREADY BEEN RENDERED. IF SO, USE SAME PREFIX --->
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
	
		<cfif not isDefined("Request.farcryForm.stObjects")>
			<!--- If the call to this tag is not made within the confines of a <ft:form> tag, then we need to create a temp one and then delete it at the end of the tag. --->
			<cfset Request.farcryForm.stObjects = StructNew()>
			<cfset Request.tmpDeleteFarcryForm = attributes.ObjectID>		
		</cfif>
		
		<cfloop list="#StructKeyList(Request.farcryForm.stObjects)#" index="key">
			<cfif isDefined("request.farcryForm.stObjects.#key#.farcryformobjectinfo.ObjectID") AND request.farcryForm.stObjects[key].farcryformobjectinfo.ObjectID EQ stObj.ObjectID>
				<cfset variables.prefix = key>
			</cfif>			
			
		</cfloop>

	</cfif>
	

	<cfset Variables.CurrentCount = StructCount(request.farcryForm.stObjects) + 1>
	<cfparam  name="variables.prefix" default="FFO#RepeatString('0', 3 - Len(Variables.CurrentCount))##Variables.CurrentCount#">			
	<cfset Request.farcryForm.stObjects[variables.prefix] = StructNew()>
		
	
	<!--- IF WE ARE RENDERING AN EXISTING OBJECT, ADD THE OBJECTID TO stObjects --->	
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
		<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID = stObj.ObjectID>
	</cfif>
	
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.typename = typename>
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectLabel = attributes.ObjectLabel>

		

	<cfif NOT len(Attributes.r_stFields)>
		<cfif attributes.IncludeFieldSet>
			<cfoutput><fieldset class="#attributes.class#"></cfoutput>
		</cfif>
		
		<cfif isDefined("attributes.legend") and len(attributes.legend)>
			<cfoutput><legend class="#attributes.class#">#attributes.legend#</legend></cfoutput>
		</cfif>	
		
		<cfif Attributes.InTable EQ 1>
			<cfoutput>
				<table>
			</cfoutput>
		</cfif>
	</cfif>
	
	<cfloop list="#lFieldsToRender#" index="i">
		
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i] = StructNew()>

		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i] = Duplicate(stFields[i].MetaData)>
		
		
		<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
					
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = variables.stObj[i]>
		<cfelseif isDefined("stFields.#i#.MetaData.Default")>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = stFields[i].MetaData.Default>
		<cfelse>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = "">
		</cfif>
		
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].formFieldName = "#variables.prefix##stFields[i].MetaData.Name#">
			
		
		<!--- CAPTURE THE HTML FOR THE FIELD --->
		
		<cfset ftFieldMetadata = request.farcryForm.stObjects[variables.prefix].MetaData[i]>
		
		
		<!--- If we have been sent stPropMetadata for this field then we need to append it to the default metatdata setup in the type.cfc  --->
		<cfif structKeyExists(attributes.stPropMetadata,ftFieldMetadata.Name)>
			<cfset StructAppend(ftFieldMetadata, attributes.stPropMetadata[ftFieldMetadata.Name])>
		</cfif>
	
		<!--- SETUP REQUIRED PARAMETERS --->
		<cfif not isDefined("ftFieldMetadata.ftType")>

			<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>

		</cfif>
		
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>

		
		<cfif not isDefined("ftFieldMetadata.ftlabel")>

			<cfset ftFieldMetadata.ftlabel = ftFieldMetadata.Name>

		</cfif>
		
		<cfif ftFieldMetadata.Type EQ "array">
			<cfsavecontent variable="ArrayLink">
				<cfoutput>
					<cfset stURLParams = structNew()>
					<cfset stURLParams.primaryObjectID = "#stObj.ObjectID#">
					<cfset stURLParams.primaryTypename = "#typename#">
					<cfset stURLParams.primaryFieldName = "#ftFieldMetadata.Name#">
					<cfset stURLParams.primaryFormFieldName = "#variables.prefix##ftFieldMetadata.Name#">
					<cfset stURLParams.ftLink = "#ftFieldMetadata.ftLink#">
					
					<cfif structKeyExists(ftFieldMetadata,'ftLibraryFieldList')>
						<cfset stURLParams.ftLibraryFieldList = "#ftFieldMetadata.ftLibraryFieldList#">
					</cfif>
					<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickerMethod')>
						<cfset stURLParams.ftLibraryPickerMethod = "#ftFieldMetadata.ftLibraryPickerMethod#">
					</cfif>
					<cfif structKeyExists(ftFieldMetadata,'ftLibraryAddMethod')>
						<cfset stURLParams.ftLibraryAddMethod = "#ftFieldMetadata.ftLibraryAddMethod#">
					</cfif>
					
					<ws:buildLink href="#application.url.farcry#/facade/library.cfm" target="library" bShowTarget="true" stParameters="#stURLParams#">[attach]</ws:buildLink>
				</cfoutput>
			</cfsavecontent>	
		</cfif>
		
		
				
		<cfsavecontent variable="FieldLabelStart">
				
			<cfoutput>
				<label for="#variables.prefix##ftFieldMetadata.Name#" class="#attributes.class#">
				<b>#ftFieldMetadata.ftlabel#</b>
				<cfif ftFieldMetadata.Type EQ "array">
					<br />#ArrayLink#
				</cfif>
			</cfoutput>
			
		</cfsavecontent>
		
		<cfsavecontent variable="FieldLabelEnd">
				
			<cfoutput></label></cfoutput>
			
		</cfsavecontent>
		
		
		<!--- Default to using the FormTools Field CFC --->
		<cfset tFieldType = application.formtools[ftFieldMetadata.ftType]>
		
		<!--- Need to determine which method to run on the field --->		
		<cfif structKeyExists(ftFieldMetadata,"Method")><!--- Have we been requested to run a specific method on the field. This can enable the user to run a display method inside an edit form for instance --->
			<cfset FieldMethod = ftFieldMetadata.method>
		<cfelse>
			<cfif attributes.Format EQ "Edit">
				<cfif structKeyExists(ftFieldMetadata,"ftEditMethod")>
					<cfset FieldMethod = ftFieldMetadata.ftEditMethod>
					
					<!--- Check to see if this method exists in the current stType CFC. if so. Change tFieldType the Current stType --->
					<cfif structKeyExists(stType,ftFieldMetadata.ftEditMethod)>
						<cfset tFieldType = stType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(stType,"ftEdit#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftEdit#ftFieldMetadata.Name#">						
						<cfset tFieldType = stType>
					<cfelse>
						<cfset FieldMethod = "Edit">
					</cfif>
					
				</cfif>
			<cfelse>
					
				<cfif structKeyExists(ftFieldMetadata,"ftDisplayMethod")>
					<cfset FieldMethod = ftFieldMetadata.ftDisplayMethod>
					<!--- Check to see if this method exists in the current stType CFC. if so. Change tFieldType the Current stType --->
					
					<cfif structKeyExists(stType,ftFieldMetadata.ftDisplayMethod)>
						<cfset tFieldType = stType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(stType,"ftDisplay#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftDisplay#ftFieldMetadata.Name#">						
						<cfset tFieldType = stType>
					<cfelse>
						<cfset FieldMethod = "display">
					</cfif>
					
				</cfif>
			</cfif>
		</cfif>	
		
		<cftry>
			<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="returnHTML">
				<cfinvokeargument name="typename" value="#typename#">
				<cfinvokeargument name="stobj" value="#stObj#">
				<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
				<cfinvokeargument name="fieldname" value="#variables.prefix##ftFieldMetadata.Name#">
			</cfinvoke>
			<cfcatch><cfdump var="#cfcatch#"></cfcatch>
		</cftry>
			
					
		<cfif NOT len(Attributes.r_stFields)>
			

					
			<cfif Attributes.InTable EQ 1>
				<cfoutput><tr></cfoutput>
			</cfif>
			
			
			<cfif isDefined("Attributes.IncludeLabel") AND attributes.IncludeLabel EQ 1>
				<cfif Attributes.InTable EQ 1>
					<cfoutput>
						<th>
							#FieldLabelStart##FieldLabelEnd#
						</th>
					</cfoutput>
				<cfelse>
					<cfoutput>#FieldLabelStart#</cfoutput>
				</cfif>
			</cfif>
			
			
			<cfif Attributes.InTable EQ 1>
				<cfoutput><td></cfoutput>
			</cfif>
			<cfoutput>#returnHTML#</cfoutput>
			<cfif Attributes.InTable EQ 1>
				<cfoutput></td></cfoutput>
			<cfelse>
				<cfif isDefined("Attributes.IncludeBR") AND attributes.IncludeBR EQ 1>
					<cfoutput><br class="#attributes.class#" /></cfoutput>	
				</cfif>
			</cfif>
			
			<cfif Attributes.InTable EQ 1>
				<cfoutput></tr></cfoutput>
			<cfelse>
				<cfoutput>#FieldLabelEnd#</cfoutput>
			</cfif>
		<cfelse>
			<cftry>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].HTML = returnHTML>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].Label = "#FieldLabelStart##FieldLabelEnd#">
			<cfif ftFieldMetadata.Type EQ "array">
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].ArrayLink = "#ArrayLink#">
			</cfif>
				<cfcatch type="any">
					<cfif attributes.ObjectID EQ '4B50EEAF-C3E9-E712-1E6502034F92EFC9'>
						<cfdump var="#i#"><cfabort>
					</cfif>
				</cfcatch>
			</cftry>
		</cfif>
		
	</cfloop>
	
	<cfif NOT len(Attributes.r_stFields)>
		<cfif Attributes.InTable EQ 1>
			<cfoutput></table></cfoutput>
		</cfif>
	</cfif>
	
	<cfparam name="Request.lFarcryObjectsRendered" default="">

	<cfif StructKeyExists(Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo,"ObjectID")
		AND  NOT ListContains(Request.lFarcryObjectsRendered, Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
			
		<cfoutput>
			<input type="hidden" name="#variables.prefix#ObjectID" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID#">
			<input type="hidden" name="#variables.prefix#Typename" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.Typename#">
		</cfoutput>
		
		<cfset Request.lFarcryObjectsRendered = ListAppend(Request.lFarcryObjectsRendered,Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
	</cfif>

	
	

	
	<cfif len(Attributes.r_stFields)>
		<cfloop list="#attributes.r_stFields#" index="i">

				<cfset "CALLER.#i#" = Request.farcryForm.stObjects[variables.prefix]['MetaData']>

		</cfloop>
	</cfif>
	
</cfif>



<cfif thistag.ExecutionMode EQ "End">
		<cfif NOT len(Attributes.r_stFields)>
			<cfif attributes.IncludeFieldSet>
				<cfoutput></fieldset></cfoutput>
			</cfif>
		</cfif>
		
		<cfif isDefined("Request.tmpDeleteFarcryForm") AND Request.tmpDeleteFarcryForm EQ attributes.ObjectID AND  isDefined("Request.farcryForm")>
			<!--- If the call to this tag is not made within the confines of a <ft:form> tag and this is the object that created it, then we need to delete the temp one we created. --->
			<cfset dummy = structDelete(Request,"farcryForm")>
			<cfset dummy = structDelete(Request,"tmpDeleteFarcryForm")>
		</cfif>
</cfif>