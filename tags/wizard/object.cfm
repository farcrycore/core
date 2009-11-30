 <cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
 <cfimport taglib="/farcry/core/tags/grid/" prefix="grid" >

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
	<cfparam name="attributes.bValidation" default="true"><!--- Flag to determine if client side validation classes are added to this section of the form. --->
	<cfparam name="attributes.lHiddenFields" default=""><!--- List of fields to render as hidden fields that can be use to inject a value into the form post. --->
	<cfparam name="attributes.stPropValues" default="#structNew()#">
	<cfparam name="attributes.r_stwizard" default="stwizard"><!--- The name of the CALLER variable that contains the stwizard structure --->
	<cfparam name="attributes.bShowFieldHints" default="true" type="boolean"><!--- Flag to determine if the field hints are display. --->
	<cfparam name="attributes.prefix" default="" /><!--- Allows the developer to pass in the prefix they wish to use. Default is the objectid stripped of the dashes. --->
	
	<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated,versionID,status")>
	
	
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
			
			<cfset stFields = duplicate(application.stcoapi[attributes.typename].stprops) />
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
		<cfset stFields = duplicate(application.stcoapi[attributes.typename].stprops) />
		<cfset typename = attributes.typename>
		
		<cfset stObj = oType.getData(objectID="#application.fc.utils.createJavaUUID()#")>
		
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
	<cfparam  name="variables.prefix" default="fc#ReplaceNoCase(variables.ObjectID,'-', '', 'all')#">			
	<cfset Request.farcryForm.stObjects[variables.prefix] = StructNew()>
	<cfoutput><input type="hidden" name="FarcryFormPrefixes" value="#variables.prefix#" /></cfoutput>	
	
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

	<cfoutput><div class="#attributes.class#"></cfoutput>
	<cfif attributes.IncludeFieldSet>
		<cfoutput><fieldset class="fieldset"></cfoutput>

		<cfif isDefined("attributes.legend") and len(attributes.legend)>
			<cfoutput><h2 class="legend">#attributes.legend#</h2></cfoutput>
		</cfif>	
	</cfif>
	
	<cfif structKeyExists(attributes,"HelpSection") and len(attributes.HelpSection)>
		<cfoutput>
			<p class="helpsection">#attributes.HelpSection#</p>
		</cfoutput>
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
		
		
 		<!--- Add validation classes --->
		<cfif attributes.bValidation>
			<cfif len(ftFieldMetadata.ftValidation)>
				<cfloop list="#ftFieldMetadata.ftValidation#" index="iValidation">
					<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# #lcase(iValidation)#">
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
				
				
				
		<cftry>
		<!--- <cfset tFieldType = application.formtools[ftFieldMetadata.ftType].oFactory.init() /> --->
		<cfset tFieldType = application.fapi.getFormtool(ftFieldMetadata.ftType) />

		<!--- Need to determine which method to run on the field --->		
		<cfif structKeyExists(ftFieldMetadata, "ftDisplayOnly") AND ftFieldMetadata.ftDisplayOnly OR ftFieldMetadata.ftType EQ "arrayList">
			<cfset FieldMethod = "display" />
		<cfelseif structKeyExists(ftFieldMetadata,"Method")><!--- Have we been requested to run a specific method on the field. This can enable the user to run a display method inside an edit form for instance --->
			<cfset FieldMethod = ftFieldMetadata.method>
		<cfelse>
			<cfif attributes.Format EQ "Edit">
				<cfif len(ftFieldMetadata.ftEditMethod)>
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
					
				<cfif len(ftFieldMetadata.ftDisplayMethod)>
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
		<cfcatch type="any">
			<cfdump var="#ftFieldMetadata#" /><cfabort>
		</cfcatch>
		</cftry>
	
		
		
		<!---If the field is supposed to be hidden --->
		<cfif ListContainsNoCase(attributes.lHiddenFields,i)>
			<cfif isArray(variables.stObj[i])>
				<cfset hiddenValue = arrayToList(variables.stObj[i]) />
			<cfelse>
				<cfset hiddenValue = variables.stObj[i] />
			</cfif>
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
					<cfset variables.returnHTML = application.formtools[ftFieldMetadata.ftType].oFactory.addWatch(typename=typename,stObject=stObj,stMetadata=ftFieldMetadata,fieldname="#variables.prefix##ftFieldMetadata.Name#",html=variables.returnHTML) />
				
			</cfif>
				
						
			<cfif NOT len(Attributes.r_stFields)>
				
				<grid:div class="ctrlHolder #ftFieldMetadata.ftLabelAlignment#Labels #ftFieldMetadata.ftClass#">
					
					
		
					<cfif structKeyExists(ftFieldMetadata, "ftshowlabel")>
						<cfset bShowLabel = ftFieldMetadata.ftShowLabel />
					<cfelse>
						<cfset bShowLabel = true />
					</cfif>
		
					<cfif bShowLabel AND isDefined("Attributes.IncludeLabel") AND attributes.IncludeLabel EQ 1>
						<cfoutput><label for="#variables.prefix##ftFieldMetadata.Name#" class="label"><cfif findNoCase("required",ftFieldMetadata.ftValidation)><em>*</em> </cfif>#ftFieldMetadata.ftlabel#</label></cfoutput>
					</cfif>
					
					<cfoutput>							
						#variables.returnHTML#
					</cfoutput>
					
	
					<cfif attributes.bShowFieldHints AND structKeyExists(ftFieldMetadata,"ftHint") and len(ftFieldMetadata.ftHint)>
						<cfoutput><p class="formHint">#ftFieldMetadata.ftHint#</p></cfoutput>
					</cfif>
					
				</grid:div>	
			<cfelse>
				
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].HTML = returnHTML>
				<cfsavecontent variable="Request.farcryForm.stObjects.#variables.prefix#.MetaData.#ftFieldMetadata.Name#.Label">
					<cfoutput><label for="#variables.prefix##ftFieldMetadata.Name#" class="label"><cfif findNoCase("required",ftFieldMetadata.ftClass)><em>*</em> </cfif>#ftFieldMetadata.ftlabel#</label></cfoutput>
				</cfsavecontent>
				
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


	<cfif attributes.IncludeFieldSet>
		<cfoutput></fieldset></cfoutput>
	</cfif>
	<cfoutput></div></cfoutput>
	
	<cfparam name="Request.farcryForm.lFarcryObjectsRendered" default="">

	<cfif attributes.format EQ "edit"
		AND StructKeyExists(Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo,"ObjectID")
		AND  NOT ListContains(Request.farcryForm.lFarcryObjectsRendered, Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
			
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