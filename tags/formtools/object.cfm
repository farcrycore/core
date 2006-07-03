 <cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>



<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.ObjectID" default=""><!--- ObjectID of object to render --->
	<cfparam name="attributes.stObject" default=""><!--- Object to render --->
	<cfparam name="attributes.typename" default=""><!--- Type of Object to render --->
	<cfparam name="attributes.ObjectLabel" default=""><!--- Used to group and label rendered object if required --->
	<cfparam name="attributes.lFields" default=""><!--- List of fields to render --->
	<cfparam name="attributes.lExcludeFields" default=""><!--- List of fields to exclude from render --->
	<cfparam name="attributes.class" default=""><!--- class with which to set all farcry form tags --->
	<cfparam name="attributes.style" default=""><!--- style with which to set all farcry form tags --->
	<cfparam name="attributes.format" default="edit"><!--- edit or display --->
	<cfparam name="attributes.IncludeLabel" default="1">
	<cfparam name="attributes.IncludeFieldSet" default="1">
	<cfparam name="attributes.IncludeBR" default="1">
	<cfparam name="attributes.InTable" default="1">
	<cfparam name="attributes.insidePLP" default="0"><!--- how are we rendering the form --->
	<cfparam name="attributes.r_stFields" default=""><!--- the name of the structure that is to be returned with the form field information. --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#"><!--- This is used to override the default metadata as setup in the type.cfc --->
	<cfparam name="attributes.WizzardID" default=""><!--- If this object call is part of a wizzard, the object will be retrieved from the wizzard storage --->
	<cfparam name="attributes.IncludeLibraryWrapper" default="true"><!--- If this is set to false, the library wrapper is not displayed. This is so that the library can change the inner html of the wrapper without duplicating the wrapping div. --->
	
	
	
	<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"label,objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated,versionID,status")>
	
	<!--- Add Form Tools Specific CSS --->
	<cfset Request.InHead.FormsCSS = 1>
	
	<cfif len(attributes.ObjectID)>
	
		<cfset ParentTag = GetBaseTagList()>
		
		<cfif len(attributes.WizzardID)>
		
			<cfset oWizzard = createobject("component",application.types.dmWizzard..typepath)>
			<cfset stWizzard = oWizzard.getData(objectID=attributes.WizzardID)>
			
			<cfwddx action="wddx2cfml" input="#stWizzard.Data#" output="stWizzardData">

			<cfset typename = stWizzardData[attributes.ObjectID].typename>
			<cfset stType = createobject("component",application.types[variables.typename].typepath)>
			<cfset lFields = StructKeyList(application.types[variables.typename].stprops)>
			<cfset stFields = application.types[variables.typename].stprops>
			<cfset ObjectID = attributes.ObjectID>
			
			<cfset stObj = stWizzardData[attributes.objectID]>

		<cfelseif ListFindNoCase(ParentTag, "cf_wizzard")>
			<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
				<cfset q4 = createObject("component", "farcry.fourq.fourq")>
				<cfset attributes.typename = q4.findType(objectid=attributes.objectid)>
			</cfif>
			
			<cfset stType = createobject("component",application.types[attributes.typename].typepath)>
			<cfset lFields = StructKeyList(application.types[attributes.typename].stprops)>
			<cfset stFields = application.types[attributes.typename].stprops>
			<cfset typename = attributes.typename>
			<cfset ObjectID = attributes.ObjectID>
			
			<cfset stBaseTag = GetBaseTagData("cf_step")>
			<cfset stWizzard = stBaseTag.stWizzard>
			<cfset stObj = stWizzard.data[attributes.objectID]>
	
		<cfelse>
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
		</cfif>

	
	<cfelseif isStruct(attributes.stObject)>
	
		<cfset stType = createobject("component",application.types[attributes.stObject.typename].typepath)>
		<cfset stObj = attributes.stObject>
		<cfset lFields = StructKeyList(application.types[stObj.typename].stprops)>
		<cfset stFields = application.types[stObj.typename].stprops>
		<cfset typename = stObj.typename>
		<cfset ObjectID = attributes.stObject.ObjectID>
		
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
			<cfif structKeyExists(request.farcryForm.stObjects,'#key#') AND structKeyExists(request.farcryForm.stObjects[key],'farcryformobjectinfo')
				AND structKeyExists(request.farcryForm.stObjects[key].farcryformobjectinfo,'ObjectID')
				AND request.farcryForm.stObjects[key].farcryformobjectinfo.ObjectID EQ stObj.ObjectID>
					<cfset variables.prefix = key>
			</cfif>			
			
		</cfloop>

	</cfif>
	

	<cfset Variables.CurrentCount = StructCount(request.farcryForm.stObjects) + 1>
	<!--- <cfparam  name="variables.prefix" default="FFO#RepeatString('0', 3 - Len(Variables.CurrentCount))##Variables.CurrentCount#">	 --->
	<cfparam  name="variables.prefix" default="#ReplaceNoCase(variables.ObjectID,'-','','All')#">			
	<cfset Request.farcryForm.stObjects[variables.prefix] = StructNew()>
		
	
	<!--- IF WE ARE RENDERING AN EXISTING OBJECT, ADD THE OBJECTID TO stObjects --->	
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
		<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID = stObj.ObjectID>
	</cfif>
	
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.typename = typename>
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectLabel = attributes.ObjectLabel>



	<cfif NOT len(Attributes.r_stFields)>

		<cfif attributes.IncludeFieldSet>
			<cfoutput><fieldset class="formsection #attributes.class#"></cfoutput>
		</cfif>
		
		<cfif isDefined("attributes.legend") and len(attributes.legend)>
			<cfoutput><legend class="#attributes.class#">#attributes.legend#</legend></cfoutput>
		</cfif>	
		
		<cfif structKeyExists(attributes,"HelpSection") and len(attributes.HelpSection)>
			<cfoutput>
				<div class="helpsection">
					<cfif structKeyExists(attributes,"HelpTitle") and len(attributes.HelpTitle)>
						<h4>#attributes.HelpTitle#</h4>
					</cfif>
					<p>#attributes.HelpSection#</p>
				</div>
			</cfoutput>
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

		<!--- Make sure ftStyle and ftClass exist --->
		<cfparam name="ftFieldMetadata.ftStyle" default="">
		<cfparam name="ftFieldMetadata.ftClass" default="">

		<!--- Prepare Form Validation (from Andrew Tetlaw http://tetlaw.id.au/view/home/) --->
		<!--- 
		Here's the list of classes available to add to your field elements:
	
	    * required (not blank)
	    * validate-number (a valid number)
	    * validate-digits (digits only)
	    * validate-alpha (letters only)
	    * validate-alphanum (only letters and numbers)
	    * validate-date (a valid date value)
	    * validate-email (a valid email address)
	    * validate-date-au (a date formatted as; dd/mm/yyyy)
	    * validate-currency-dollar (a valid dollar value)

		 --->
		 
		<cfif structKeyExists(ftFieldMetadata, "ftValidation")>
			<cfloop list="#ftFieldMetadata.ftValidation#" index="i">
				<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# #lcase(i)#">
			</cfloop>
		</cfif>
		<cfset ftFieldMetadata.ftClass = Trim(ftFieldMetadata.ftClass)>
		
		
		
		<cfset variables.returnHTML = "">
		
		<cfif structKeyExists(tFieldType,FieldMethod)>
			
			<cftry>
				
				
				
				<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="variables.returnHTML">
					<cfinvokeargument name="typename" value="#typename#">
					<cfinvokeargument name="stObject" value="#stObj#">
					<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
					<cfinvokeargument name="fieldname" value="#variables.prefix##ftFieldMetadata.Name#">
				</cfinvoke>
				<cfcatch><cfdump var="#cfcatch#"><cfabort></cfcatch>
			</cftry>
		</cfif>
			

		<cfif attributes.Format EQ "Edit" AND (ftFieldMetadata.Type EQ "array" OR ftFieldMetadata.Type EQ "UUID") AND isDefined("ftFieldMetadata.ftJoin")>
	
			<cfset stURLParams = structNew()>
			<cfset stURLParams.primaryObjectID = "#stObj.ObjectID#">
			<cfset stURLParams.primaryTypename = "#typename#">
			<cfset stURLParams.primaryFieldName = "#ftFieldMetadata.Name#">
			<cfset stURLParams.primaryFormFieldName = "#variables.prefix##ftFieldMetadata.Name#">
			<cfset stURLParams.ftJoin = "#ftFieldMetadata.ftJoin#">
			<cfset stURLParams.LibraryType = "#ftFieldMetadata.Type#">
			
			<!--- If the field is contained in a wizzard, we need to let the library know which wizzard. --->
			<cfif len(attributes.WizzardID)>
				<cfset stURLParams.WizzardID = "#attributes.WizzardID#">
			</cfif>
			
			<cfif structKeyExists(ftFieldMetadata,'ftLibraryAddNewMethod')>
				<cfset stURLParams.ftLibraryAddNewMethod = "#ftFieldMetadata.ftLibraryAddNewMethod#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickMethod')>
				<cfset stURLParams.ftLibraryPickMethod = "#ftFieldMetadata.ftLibraryPickMethod#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickListClass')>
				<cfset stURLParams.ftLibraryPickListClass = "#ftFieldMetadata.ftLibraryPickListClass#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickListStyle')>
				<cfset stURLParams.ftLibraryPickListStyle = "#ftFieldMetadata.ftLibraryPickListStyle#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibrarySelectedMethod')>
				<cfset stURLParams.ftLibrarySelectedMethod = "#ftFieldMetadata.ftLibrarySelectedMethod#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibrarySelectedListClass')>
				<cfset stURLParams.ftLibrarySelectedListClass = "#ftFieldMetadata.ftLibrarySelectedListClass#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftLibrarySelectedListStyle')>
				<cfset stURLParams.ftLibrarySelectedListStyle = "#ftFieldMetadata.ftLibrarySelectedListStyle#">
			</cfif>
			<cfif structKeyExists(ftFieldMetadata,'ftDataProvider')>
				<cfset stURLParams.ftDataProvider = "#ftFieldMetadata.ftDataProvider#">
			</cfif>

			<cfsavecontent variable="LibraryLink">
				<!--- <cfdump var="#ftFieldMetadata#"> --->
				<ws:buildLink href="#application.url.farcry#/facade/library.cfm" target="library" bShowTarget="true" stParameters="#stURLParams#"><cfoutput><img src="#application.url.farcry#/images/treeimages/crystalIcons/includeApproved.gif" /></cfoutput></ws:buildLink>
			</cfsavecontent>
		<cfelse>
			<cfset libraryLink = "">	
		</cfif>
		
				
		<cfsavecontent variable="FieldLabelStart">
				
			<cfoutput>
				<label for="#variables.prefix##ftFieldMetadata.Name#" class="fieldsectionlabel #attributes.class#">
				#ftFieldMetadata.ftlabel#
				<cfif len(LibraryLink)>
					#LibraryLink#					
				</cfif>
				</label>
			</cfoutput>
			
		</cfsavecontent>
		
	
					
		<cfif len(LibraryLink) and attributes.IncludeLibraryWrapper>
			<cfset variables.returnHTML = "<div id='#variables.prefix##ftFieldMetadata.Name#-wrapper' class='formfield-wrapper'>#variables.returnHTML#</div>">
		</cfif>
					
		<cfif NOT len(Attributes.r_stFields)>
			

					
			<cfif Attributes.InTable EQ 1>
				<cfoutput><tr></cfoutput>
			<cfelse>

				<!--- Need to determine if Help Section is going to be included and if so, place class that will determine margin. --->
				<cfset helpsectionClass = "">
				<cfif structKeyExists(attributes,"HelpSection") and len(attributes.HelpSection)>
					<cfset helpSectionClass = "helpsectionmargin">
				</cfif>	
							
				<cfoutput><div class="fieldsection #ftFieldMetadata.ftType# #ftFieldMetadata.ftClass# #helpSectionClass#"></cfoutput>
			</cfif>
			
			
			<cfif isDefined("Attributes.IncludeLabel") AND attributes.IncludeLabel EQ 1>
				<cfif Attributes.InTable EQ 1>
					<cfoutput>
						<th>
							#FieldLabelStart#
						</th>
					</cfoutput>
				<cfelse>
					<cfoutput>#FieldLabelStart#</cfoutput>
				</cfif>
			</cfif>
			
			
			<cfif Attributes.InTable EQ 1>
				<cfoutput><td></cfoutput>
			</cfif>

			
			<cfoutput><div class="fieldwrap">#variables.returnHTML#</div></cfoutput>
			
			<cfif structKeyExists(ftFieldMetadata,"ftHint") and len(ftFieldMetadata.ftHint)>
				<cfoutput><small>#ftFieldMetadata.ftHint#</small></cfoutput>
			</cfif>
			
			<cfif Attributes.InTable EQ 1>
				<cfoutput></td></tr></cfoutput>
			<cfelse>
				<cfoutput>
					<br class="fieldsectionbreak" />
					</div>
				</cfoutput>
			</cfif>
		<cfelse>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].HTML = returnHTML>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].Label = "#FieldLabelStart#">
			<cfif ftFieldMetadata.Type EQ "array">
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].LibraryLink = "#LibraryLink#">
			</cfif>
		</cfif>
		
	</cfloop>
	

	
	

	
	<cfif len(Attributes.r_stFields)>
		<cfloop list="#attributes.r_stFields#" index="i">
			<cfif structKeyExists(Request.farcryForm.stObjects[variables.prefix],'MetaData')>
				<cfset CALLER[i] = Request.farcryForm.stObjects[variables.prefix]['MetaData']>
			<cfelse>
				<cfset CALLER[i] = StructNew()>
			</cfif>
		</cfloop>
	</cfif>
	
</cfif>



<cfif thistag.ExecutionMode EQ "End">


	<cfif NOT len(Attributes.r_stFields)>
		<cfif Attributes.InTable EQ 1>
			<cfoutput></table></cfoutput>
		<cfelse>
			
		</cfif>
		<cfif attributes.IncludeFieldSet>
			<cfoutput></fieldset></cfoutput>
		</cfif>
	</cfif>
	
	<cfparam name="Request.lFarcryObjectsRendered" default="">

	<cfif attributes.format EQ "edit"
		AND StructKeyExists(Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo,"ObjectID")
		AND  NOT ListContains(Request.lFarcryObjectsRendered, Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
			
		<cfoutput>
			<input type="hidden" name="FarcryFormPrefixes" id="FarcryFormPrefixes" value="#StructKeyList(request.farcryForm.stObjects)#" />
			<input type="hidden" name="#variables.prefix#ObjectID" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID#">
			<input type="hidden" name="#variables.prefix#Typename" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.Typename#">
		</cfoutput>
		
		<cfset Request.lFarcryObjectsRendered = ListAppend(Request.lFarcryObjectsRendered,Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
	</cfif>
	
	<cfif isDefined("Request.tmpDeleteFarcryForm") AND Request.tmpDeleteFarcryForm EQ attributes.ObjectID AND  isDefined("Request.farcryForm")>
		<!--- If the call to this tag is not made within the confines of a <ft:form> tag and this is the object that created it, then we need to delete the temp one we created. --->
		<cfset dummy = structDelete(Request,"farcryForm")>
		<cfset dummy = structDelete(Request,"tmpDeleteFarcryForm")>
	</cfif>
</cfif>