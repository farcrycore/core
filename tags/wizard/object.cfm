 <cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/core/tags/webskin/" prefix="ws" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfset ParentTag = GetBaseTagList()>
<cfif NOT ListFindNoCase(ParentTag, "cf_wizard")>
	<cfabort showerror="You cant use the the wiz:object outside of a wizard...">
</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.ObjectID" default=""><!--- ObjectID of object to render --->
	<cfparam name="attributes.stObject" default="#structNew()#"><!--- Object to render --->
	<cfparam name="attributes.typename" default=""><!--- Type of Object to render --->
	<cfparam name="attributes.ObjectLabel" default=""><!--- Used to group and label rendered object if required --->
	<cfparam name="attributes.lFields" default=""><!--- List of fields to render --->
	<cfparam name="attributes.lExcludeFields" default="label"><!--- List of fields to exclude from render --->
	<cfparam name="attributes.class" default=""><!--- class with which to set all farcry form tags --->
	<cfparam name="attributes.style" default=""><!--- style with which to set all farcry form tags --->
	<cfparam name="attributes.format" default="edit"><!--- edit or display --->
	<cfparam name="attributes.IncludeLabel" default="1">
	<cfparam name="attributes.IncludeFieldSet" default="1">
	<cfparam name="attributes.IncludeBR" default="1">
	<cfparam name="attributes.InTable" default="0">
	<cfparam name="attributes.insidePLP" default="0"><!--- how are we rendering the form --->
	<cfparam name="attributes.r_stFields" default=""><!--- the name of the structure that is to be returned with the form field information. --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#"><!--- This is used to override the default metadata as setup in the type.cfc --->
	<cfparam name="attributes.wizardID" default=""><!--- If this object call is part of a wizard, the object will be retrieved from the wizard storage --->
	<cfparam name="attributes.IncludeLibraryWrapper" default="true"><!--- If this is set to false, the library wrapper is not displayed. This is so that the library can change the inner html of the wrapper without duplicating the wrapping div. --->
	<cfparam name="attributes.bValidation" default="true"><!--- Flag to determine if client side validation classes are added to this section of the form. --->
	<cfparam name="attributes.lHiddenFields" default=""><!--- List of fields to render as hidden fields that can be use to inject a value into the form post. --->
	<cfparam name="attributes.stPropValues" default="#structNew()#">
	<cfparam name="attributes.r_stwizard" default="stwizard"><!--- The name of the CALLER variable that contains the stwizard structure --->
	<cfparam name="attributes.bShowLibraryLink" default="true" type="boolean"><!--- Flag to determine if the libraryLink is to be displayed. --->
	
	<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated,versionID,status")>
	
	<!--- Add Form Tools Specific CSS --->
	<cfparam name="Request.InHead.FormsCSS" default="true" />
	
	<cfif NOT structIsEmpty(attributes.stObject)>
		<cfset attributes.ObjectID = attributes.stObject.ObjectID>
		<cfset attributes.typename = attributes.stObject.typename>
	</cfif>
	
	<cfif len(attributes.ObjectID)>		
			<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
				<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
				<cfset attributes.typename = q4.findType(objectid=attributes.objectid)>
			</cfif>
			
			<cfset stPackage = application.stcoapi[attributes.typename]>
			<cfset packagePath = application.stcoapi[attributes.typename].packagepath>
			
			<!--- populate the primary values --->
			<cfset typename = attributes.typename>
			<cfset oType = createobject("component",application.stcoapi[attributes.typename].packagepath)>
			
			<cfset qMetadata = application.stcoapi[attributes.typename].qMetadata />
			<cfset lFields = ValueList(qMetadata.propertyname)>
			
			<cfset stFields = application.stcoapi[attributes.typename].stprops>
			<cfset ObjectID = attributes.ObjectID>
			
			<!--- Retrieve the Wizard structure from the calling page --->
			<cfset stwizard = CALLER[attributes.r_stwizard] />
			
			<cfif structIsEmpty(attributes.stObject) AND  structKeyExists(stwizard.data,attributes.objectid)>
				<cfset stObj = stwizard.data[attributes.objectID]>
			<cfelse>
				<cfif structIsEmpty(attributes.stObject)>
					<!--- Get the object from the DB --->
					<cfset stObj = oType.getData(attributes.objectID)>
				<cfelse>
					<cfset stObj = attributes.stObject />
				</cfif>
				
				<!--- Add it to the wizard structure --->
				<cfset stwizard.Data[attributes.objectid] = stObj>
				
				<!--- Write the Wizard structure back to the DB --->
				<cfset stwizard = createObject("component",application.stcoapi['dmWizard'].packagepath).Write(ObjectID=stwizard.ObjectID,Data="#stwizard.Data#")>

				
				<cfset CALLER[attributes.r_stwizard] = stwizard />
			</cfif>		

	
	<cfelse>
	
		<cfset oType = createobject("component",application.stcoapi[attributes.typename].packagepath)>
			

	
		<cfset stPackage = application.stcoapi[attributes.typename]>
		<cfset packagePath = application.stcoapi[attributes.typename].packagepath>
					
		<cfset qMetadata = application.stcoapi[attributes.typename].qMetadata />
		<cfset lFields = ValueList(qMetadata.propertyname)>
		<cfset stFields = application.stcoapi[attributes.typename].stprops>
		<cfset typename = attributes.typename>
		
		<cfset stObj = oType.getData(objectID="#CreateUUID()#")>
		
		<cfset ObjectID = stObj.objectID>
	</cfif>

	<cfset lFieldsToRender =  "">
	


	<!--- allow for whitespace in field list attributes by trimming --->
	<cfset attributes.lFields = replacenocase(attributes.lFields, " ", "", "ALL") />
	<cfset attributes.lHiddenFields = replacenocase(attributes.lHiddenFields, " ", "", "ALL") />
	<cfset attributes.lExcludeFields = replacenocase(attributes.lExcludeFields, " ", "", "ALL") />

	<!--- Determine fields to render --->
	<cfloop list="#attributes.lFields#" index="i">
		<cfif ListFindNoCase(variables.lFields,i)>
			<cfset lFieldsToRender =  listappend(lFieldsToRender,i)>
			<!--- 
			<!--- If the user explicitly wants a field to appear, remove it from the exclusion list. --->
			<cfif ListFindNoCase(attributes.lExcludeFields,i)>
				<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
			</cfif> --->
		</cfif>
		
		<!--- If the user explicitly wants a field to appear, remove it from the exclusion list. --->
		<cfif ListFindNoCase(attributes.lExcludeFields,i)>
			<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
		</cfif>
	</cfloop>

	<!--- Determine fields to render but as hidden fields --->
	<cfloop list="#attributes.lHiddenFields#" index="i">
		<cfif ListFindNoCase(variables.lFields,i)>
			<cfset lFieldsToRender =  listappend(lFieldsToRender,i)>
		</cfif>
		
		<!--- If the user explicitly wants a field to appear as a hidden form field, remove it from the exclusion list. --->
		<cfif ListFindNoCase(attributes.lExcludeFields,i)>
			<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
		</cfif>
	</cfloop>	
	
	<!--- If still no fields, just default to all the fields in the type --->
	<cfif not len(lFieldsToRender)>
		<cfset lFieldsToRender = variables.lFields>
	</cfif>	
	
	
	<!--- Determine fields to exclude from render --->
	<cfif isDefined("attributes.lExcludeFields") and len(attributes.lExcludeFields)>
		<cfloop list="#lFieldsToRender#" index="i">
			<cfif ListFindNoCase(attributes.lExcludeFields,i)>
				<cfset lFieldsToRender =  listdeleteat(lFieldsToRender,ListFindNoCase(lFieldsToRender,i))>
			</cfif>
		</cfloop>
	</cfif>
	

	<!--- REMOVE any arrayList fields from the render. --->
	<cfloop list="#lFieldsToRender#" index="i">
		<cfif structKeyExists(stFields[i].metadata, "ftType") AND stFields[i].metadata.ftType EQ "arrayList">
			<cfset lFieldsToRender =  listdeleteat(lFieldsToRender,ListFindNoCase(lFieldsToRender,i))>
		</cfif>
	</cfloop>
	
	
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
					<cfset variables.prefix = "#key#">
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


	<!--- determine if we need to hide any legend specific css. --->
	<cfset LegendClass = "" />
	<cfif not isDefined("attributes.legend") or not len(attributes.legend)>
		<cfset LegendClass = "noLegend" />
	</cfif>

	<cfif attributes.IncludeFieldSet>
		<cfoutput><fieldset class="formSection #attributes.class# #LegendClass#"></cfoutput>
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

		
		<!--- If we have been sent stPropValues for this field then we need to set it to this value  --->
		<cfif structKeyExists(attributes.stPropValues,i)>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = attributes.stPropValues[i]>
			<cfset variables.stObj[i] = attributes.stPropValues[i]>
		<cfelse>
			<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>					
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = variables.stObj[i]>
			<cfelseif structKeyExists(stFields[i].MetaData, "ftDefault")>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = stFields[i].MetaData.ftDefault>
			<cfelseif structKeyExists(stFields[i].MetaData, "Default")>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = stFields[i].MetaData.Default>
			<cfelse>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = "">
			</cfif>
								
		</cfif>
		
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].formFieldName = "#variables.prefix##stFields[i].MetaData.Name#">
			
		
		<!--- CAPTURE THE HTML FOR THE FIELD --->		
		<cfset ftFieldMetadata = request.farcryForm.stObjects[variables.prefix].MetaData[i]>
		
		<!--- If we have been sent stPropMetadata for this field then we need to append it to the default metatdata setup in the type.cfc  --->
		<cfif structKeyExists(attributes.stPropMetadata,ftFieldMetadata.Name)>
			<cfset StructAppend(ftFieldMetadata, attributes.stPropMetadata[ftFieldMetadata.Name])>
		</cfif>
		
		
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
			<cfif len(ftFieldMetadata.ftValidation)>
				<cfloop list="#ftFieldMetadata.ftValidation#" index="i">
					<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# #lcase(i)#">
				</cfloop>
			</cfif>
		</cfif>
		<cfset ftFieldMetadata.ftClass = Trim(ftFieldMetadata.ftClass)>
		
		
	
		<!--- CHECK TO ENSURE THE FORMTOOL TYPE EXISTS. OTHERWISE USE THE DEFAULT [FIELD] --->
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>		
				
				
				
		
		<cfset tFieldType = application.formtools[ftFieldMetadata.ftType].oFactory.init() />

		<!--- Need to determine which method to run on the field --->		
		<cfif structKeyExists(ftFieldMetadata, "ftDisplayOnly") AND ftFieldMetadata.ftDisplayOnly OR ftFieldMetadata.ftType EQ "arrayList">
			<cfset FieldMethod = "display" />
		<cfelseif structKeyExists(ftFieldMetadata,"Method")><!--- Have we been requested to run a specific method on the field. This can enable the user to run a display method inside an edit form for instance --->
			<cfset FieldMethod = ftFieldMetadata.method>
		<cfelse>
			<cfif attributes.Format EQ "Edit">
				<cfif structKeyExists(ftFieldMetadata,"ftEditMethod")>
					<cfset FieldMethod = ftFieldMetadata.ftEditMethod>
					
					<!--- Check to see if this method exists in the current oType CFC. if so. Change tFieldType the Current oType --->
					<cfif structKeyExists(oType,ftFieldMetadata.ftEditMethod)>
						<cfset tFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftEdit#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftEdit#ftFieldMetadata.Name#">						
						<cfset tFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "Edit">
					</cfif>
					
				</cfif>
			<cfelse>
					
				<cfif structKeyExists(ftFieldMetadata,"ftDisplayMethod")>
					<cfset FieldMethod = ftFieldMetadata.ftDisplayMethod>
					<!--- Check to see if this method exists in the current oType CFC. if so. Change tFieldType the Current oType --->
					
					<cfif structKeyExists(oType,ftFieldMetadata.ftDisplayMethod)>
						<cfset tFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftDisplay#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftDisplay#ftFieldMetadata.Name#">						
						<cfset tFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "display">
					</cfif>
					
				</cfif>
			</cfif>
		</cfif>	

	
		
		
		<!---If the field is supposed to be hidden --->
		<cfif ListContainsNoCase(attributes.lHiddenFields,i)>
			<cfoutput><input type="hidden" id="#variables.prefix##ftFieldMetadata.Name#" name="#variables.prefix##ftFieldMetadata.Name#" value="#variables.stObj[i]#" /></cfoutput>
		
		<cfelse>
			
			<cfset variables.returnHTML = "">
		
			
			<cfif structKeyExists(tFieldType,FieldMethod)>
			
				
					<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="variables.returnHTML">
						<cfinvokeargument name="typename" value="#typename#">
						<cfinvokeargument name="stObject" value="#stObj#">
						<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
						<cfinvokeargument name="fieldname" value="#variables.prefix##ftFieldMetadata.Name#">
						<cfinvokeargument name="stPackage" value="#stPackage#">
					</cfinvoke>
				
				
			</cfif>
				
			<!-------------------------------------------------------------
			Library Link
				- add library link for library properties, if required
			-------------------------------------------------------------->	
			<cfif 
				attributes.bShowLibraryLink
				AND attributes.Format EQ "Edit" 
				AND (ftFieldMetadata.Type EQ "array" 
				OR ftFieldMetadata.Type EQ "UUID") 
				AND isDefined("ftFieldMetadata.ftJoin")>
				<!--- AND (structKeyExists(ftfieldmetadata, "ftrendertype") AND ftfieldmetadata.rendertype neq "list")> --->
				
				<cfif NOT structKeyExists(ftFieldMetadata, "ftShowLibraryLink") OR ftFieldMetadata.ftShowLibraryLink>
					<cfsavecontent variable="LibraryLink">
	
						<cfset stURLParams = structNew()>
						<cfset stURLParams.primaryObjectID = "#stObj.ObjectID#">
						<cfset stURLParams.primaryTypename = "#typename#">
						<cfset stURLParams.primaryFieldName = "#ftFieldMetadata.Name#">
						<cfset stURLParams.primaryFormFieldName = "#variables.prefix##ftFieldMetadata.Name#">
						<cfset stURLParams.LibraryType = "#ftFieldMetadata.Type#">
						
						<!--- If the field is contained in a wizard, we need to let the library know which wizard. --->
						<cfif len(attributes.wizardID)>
							<cfset stURLParams.wizardID = "#attributes.wizardID#">
						</cfif>
						
						<cfif structKeyExists(ftFieldMetadata,'ftLibraryAddNewWebskin')>
							<cfset stURLParams.ftLibraryAddNewWebskin = "#ftFieldMetadata.ftLibraryAddNewWebskin#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickWebskin')>
							<cfset stURLParams.ftLibraryPickWebskin = "#ftFieldMetadata.ftLibraryPickWebskin#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickListClass')>
							<cfset stURLParams.ftLibraryPickListClass = "#ftFieldMetadata.ftLibraryPickListClass#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftLibraryPickListStyle')>
							<cfset stURLParams.ftLibraryPickListStyle = "#ftFieldMetadata.ftLibraryPickListStyle#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftLibrarySelectedWebskin')>
							<cfset stURLParams.ftLibrarySelectedWebskin = "#ftFieldMetadata.ftLibrarySelectedWebskin#">
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
						<cfif structKeyExists(ftFieldMetadata,'ftLibraryDataTypename')>
							<cfset stURLParams.ftLibraryDataTypename = "#ftFieldMetadata.ftLibraryDataTypename#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftAllowLibraryAddNew')>
							<cfset stURLParams.ftAllowLibraryAddNew = "#ftFieldMetadata.ftAllowLibraryAddNew#">
						<cfelse>
							<cfset stURLParams.ftAllowLibraryAddNew = "#ftFieldMetadata.ftJoin#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftAllowLibraryEdit')>
							<cfset stURLParams.ftAllowLibraryEdit = "#ftFieldMetadata.ftAllowLibraryEdit#">
						<cfelse>
							<cfset stURLParams.ftAllowLibraryEdit = "#ftFieldMetadata.ftJoin#">
						</cfif>
						<cfif structKeyExists(ftFieldMetadata,'ftShowRemoveSelected')>
							<cfset stURLParams.ftShowRemoveSelected = "#ftFieldMetadata.ftShowRemoveSelected#">
						</cfif>
								
						<cfset request.inHead.libraryPopup = true />
						
						<ws:buildLink href="#application.url.farcry#/facade/library.cfm" stParameters="#stURLParams#" r_url="libraryPopupJS" />
	
						<cfoutput>
							<input type="button" name="libraryOpen" value="Open Library" class="formButton" onClick="openLibrary('#Replace(stObj.ObjectID,"-", "", "ALL")#', $('#variables.prefix##ftFieldMetadata.Name#Join').value,'#libraryPopupJS#')" />
	
							<cfif listLen(ftFieldMetadata.ftJoin) GT 1>
								<select id="#variables.prefix##ftFieldMetadata.Name#Join" name="#variables.prefix##ftFieldMetadata.Name#Join" >
									<cfloop list="#ftFieldMetadata.ftJoin#" index="i">
										<option value="#i#">#application.stcoapi[i].displayname#</option>
									</cfloop>
								</select>
							<cfelse>
								<input type="hidden" id="#variables.prefix##ftFieldMetadata.Name#Join" name="#variables.prefix##ftFieldMetadata.Name#Join" value="#ftFieldMetadata.ftJoin#" >
							</cfif>
						</cfoutput>
							
						
					</cfsavecontent>
				<cfelse>
					<cfset libraryLink = "">	
				</cfif>
			<cfelse>
				<cfset libraryLink = "">	
			</cfif>
			
					
			<cfsavecontent variable="FieldLabelStart">
					
				<cfoutput>
					<label for="#variables.prefix##ftFieldMetadata.Name#" class="fieldsectionlabel #attributes.class#">
					#ftFieldMetadata.ftlabel# :
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
								
					<cfoutput><div class="fieldSection #lcase(ftFieldMetadata.ftType)# #ftFieldMetadata.ftClass# #helpSectionClass#"></cfoutput>
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
	
				
				<cfoutput>
				<div class="fieldAlign">						
					<cfif len(LibraryLink)>
						#LibraryLink#					
					</cfif>
					
					#variables.returnHTML#
				</div>
				</cfoutput>
				
				<cfif structKeyExists(ftFieldMetadata,"ftHint") and len(ftFieldMetadata.ftHint)>
					<cfoutput><small>#ftFieldMetadata.ftHint#</small></cfoutput>
				</cfif>
				
				<cfif Attributes.InTable EQ 1>
					<cfoutput></td></tr></cfoutput>
				<cfelse>
					<cfoutput>
						<br class="clearer" />
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
		
	</cfif>
	
	<cfif isDefined("Request.tmpDeleteFarcryForm") AND Request.tmpDeleteFarcryForm EQ attributes.ObjectID AND  isDefined("Request.farcryForm")>
		<!--- If the call to this tag is not made within the confines of a <ft:form> tag and this is the object that created it, then we need to delete the temp one we created. --->
		<cfset dummy = structDelete(Request,"farcryForm")>
		<cfset dummy = structDelete(Request,"tmpDeleteFarcryForm")>
	</cfif>
</cfif>