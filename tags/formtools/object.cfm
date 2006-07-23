 <cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<!---<cfset ParentTag = GetBaseTagList()>
<cfif ListFindNoCase(ParentTag, "cf_wizzard")>
	<cfabort showerror="You must use the wiz:object inside of a wizzard...">
</cfif> --->
		


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
	<cfparam name="attributes.bValidation" default="true"><!--- Flag to determine if client side validation classes are added to this section of the form. --->
	<cfparam name="attributes.lHiddenFields" default=""><!--- List of fields to render as hidden fields that can be use to inject a value into the form post. --->
	<cfparam name="attributes.stPropValues" default="#structNew()#">
	<cfparam name="attributes.PackageType" default="types"><!--- Could be types or rules.. --->
	
	
	
	<!--- Add Form Tools Specific CSS --->
	<cfset Request.InHead.FormsCSS = 1>
	
	
		
	<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"label,objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated,versionID,status")>

	

	
	<cfif len(attributes.ObjectID)>
	

		<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
			<cfset q4 = createObject("component", "farcry.fourq.fourq")>
			<cfset attributes.typename = q4.findType(objectid=attributes.objectid)>
		</cfif>		
	
	
		<cfif attributes.PackageType EQ "types">
			<cfset stPackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].typepath>
		<cfelse>
			<cfset stPackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].rulepath>
		</cfif>
		
		
		<cfset stType = createobject("component",packagePath)>
		<cfset lFields = StructKeyList(stPackage.stprops)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		<cfset ObjectID = attributes.ObjectID>
		
		<cfset stObj = stType.getData(attributes.objectID)>
	
	<cfelseif isStruct(attributes.stObject)>
	
		
		<cfset stObj = attributes.stObject>		
		<cfset attributes.typename = stObj.typename>	
		
	
		<cfif attributes.PackageType EQ "types">
			<cfset stpackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].typepath>
		<cfelse>
			<cfset stpackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].rulepath>
		</cfif>
				
		
		<cfset stType = createobject("component",packagePath)>
		<cfset lFields = StructKeyList(stPackage.stprops)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		<cfset ObjectID = attributes.stObject.ObjectID>
		
	<cfelseif len(attributes.typename)>
	
	
		<cfif attributes.PackageType EQ "types">
			<cfset stpackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].typepath>
		<cfelse>
			<cfset stpackage = application[attributes.PackageType][attributes.typename]>
			<cfset packagePath = application[attributes.PackageType][attributes.typename].rulepath>
		</cfif>
			
	
		<cfset stType = createobject("component",packagePath)>
		<cfset lFields = StructKeyList(stPackage.stprops)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		
		<cfset stObj = stType.getData(objectID="#CreateUUID()#")>
		
		<cfset ObjectID = stObj.objectID>
	</cfif>

	
	<cfif isDefined("stObj") and not structIsEmpty(stObj)>
		<cftry>
			<cfset stType.setlock(stObj=stObj,locked="true",lockedby="")>
			<cfcatch >
				<!--- TODO: Rules do not currently have the ability to be locked. --->
				
			</cfcatch>
		</cftry>
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

	<!--- Determine fields to render but as hidden fields --->
	<cfloop list="#attributes.lHiddenFields#" index="i">
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
	<cfparam  name="variables.prefix" default="#ReplaceNoCase(variables.ObjectID,'-', '', 'all')#">			
	<cfset Request.farcryForm.stObjects[variables.prefix] = StructNew()>
		
	
	<!--- IF WE ARE RENDERING AN EXISTING OBJECT, ADD THE OBJECTID TO stObjects --->	
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
		<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID = stObj.ObjectID>
	</cfif>
	
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.typename = typename>
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectLabel = attributes.ObjectLabel>



	

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
	
	<cfif NOT len(Attributes.r_stFields)>
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
		
		<!--- If we have been sent stPropValues for this field then we need to set it to this value  --->
		<cfif structKeyExists(attributes.stPropValues,i)>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = attributes.stPropValues[i]>
			<cfset variables.stObj[i] = attributes.stPropValues[i]>
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
		 
		<cfif attributes.bValidation>
			<cfif structKeyExists(ftFieldMetadata, "ftValidation")>
				<cfloop list="#ftFieldMetadata.ftValidation#" index="i">
					<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# #lcase(i)#">
				</cfloop>
			</cfif>
		</cfif>
		<cfset ftFieldMetadata.ftClass = Trim(ftFieldMetadata.ftClass)>
		
		
			<!--- If the field is supposed to be hidden --->
		<cfif ListContainsNoCase(attributes.lHiddenFields,i)>
			<cfoutput><input type="hidden" id="#variables.prefix##ftFieldMetadata.Name#" name="#variables.prefix##ftFieldMetadata.Name#" value="#variables.stObj[i]#" /></cfoutput>
		<cfelse>	
			
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
				<cfif structKeyExists(ftFieldMetadata,'ftLibraryData')>
					<cfset stURLParams.ftLibraryData = "#ftFieldMetadata.ftLibraryData#">
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
								
					<cfoutput><div class="fieldsection #lcase(ftFieldMetadata.ftType)# #ftFieldMetadata.ftClass# #helpSectionClass#"></cfoutput>
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
				
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].HTML = returnHTML>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].Label = "#FieldLabelStart#">
				<cfif ftFieldMetadata.Type EQ "array">
					<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].LibraryLink = "#LibraryLink#">
				</cfif>
				
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
	</cfif>
	
		<cfif attributes.IncludeFieldSet>
			<cfoutput></fieldset></cfoutput>
		</cfif>
	
	
	<cfparam name="Request.lFarcryObjectsRendered" default="">

	<cfif attributes.format EQ "edit"
		AND StructKeyExists(Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo,"ObjectID")
		AND  NOT ListContains(Request.lFarcryObjectsRendered, Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
			
		<cfoutput>
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