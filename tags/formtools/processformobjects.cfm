<cfif isDefined("session.dmSec.authentication.userlogin")>
	<cfset Variables.LockedBy = session.dmSec.authentication.userlogin>
<cfelse>
	<cfset Variables.LockedBy = "anonymous">
</cfif>


<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<!--- Object to render --->
	<cfparam name="attributes.stObj" default="#structNew()#" >
	
	<!--- ObjectID of object to render --->
	<cfparam name="attributes.ObjectID" default="" >
	
	<!--- Type of Object to render --->
	<cfparam name="attributes.typename" default="" >
	
	<!--- This is used to override the default metadata as setup in the type.cfc. Can be usefull if wanting to specify a different validation method (ftValidationMethod) --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#">
	
	
	<cfparam name="typename" default="" >
	
	<!--- The structure to return the form variables into to process before creating/saving --->
	<cfparam name="attributes.r_stProperties" default="stProperties" >


	<!--- This structure contains the methods to be used to save the field --->
	<cfparam name="attributes.stPropMethods" default="#structNew()#" >
	
	
	<!--- Could be types or rules.. --->
	<cfparam name="attributes.PackageType" default="types">
	
	<!--- Flag to process image autogenerate routine.. --->
	<cfparam name="attributes.bimageautogenerate" default="false" />
	
	<!--- list of arrayList fields to process on AfterSave.. --->
	<cfparam name="attributes.lArrayListGenerate" default="" />
	
	<!--- Allow processing to session only. --->
	<cfparam name="attributes.bSessionOnly" default="false" />
	
	
	<cfset Caller[attributes.r_stProperties] = structNew()>
	<cfset Caller.lSavedObjectIDs = "">

	<cfparam name="FORM.farcryFormPrefixes" default="" >
	<cfparam name="variables.farcryFormPrefixesToProcess" default="" >


	<!--- ------------------------------------------------- --->
	<!--- Setup the main parameters used by this custom tag --->
	<!--- ------------------------------------------------- --->
	<cfset stSetup = init(stObj=attributes.stObj,ObjectID=attributes.ObjectID,Typename=attributes.Typename)>
	<cfset stType = stSetup.stType>
	<cfset stObj = stSetup.stObj>
	<cfset lFields = stSetup.lFields>
	<cfset stFields = stSetup.stFields>
	<cfset typename = stSetup.typename>

	<!--- --------------------------------------------------------------------- --->
	<!--- Loop through all the prefixes and determine which prefixes to process --->
	<!--- --------------------------------------------------------------------- --->
	<cfloop list="#form.farcryFormPrefixes#" index="variables.Prefix" >
		
		<!--- Clean up Form[ObjectIDs] and FORM[Typenames] incase of duplications caused by Dynamic Array Library Pickers. --->
		<cfif structKeyExists(form,"#variables.Prefix#ObjectID") AND ListLen(FORM["#variables.Prefix#ObjectID"]) GT 1>			
			<cfset FORM["#variables.Prefix#ObjectID"] = ListGetAt(FORM["#variables.Prefix#ObjectID"],1)>			
		</cfif>
		<cfif structKeyExists(form,"#variables.Prefix#typename") AND ListLen(FORM["#variables.Prefix#typename"]) GT 1>
			<cfset FORM["#variables.Prefix#typename"] = ListGetAt(FORM["#variables.Prefix#typename"],1)>
		</cfif>
		
			
		
		<cfif NOT listFindNoCase(variables.farcryFormPrefixesToProcess,variables.Prefix)><!--- Eliminates Duplicates --->
			
			<!--- Processing an Object --->
			<cfif isDefined("stObj.ObjectID") AND len(stObj.ObjectID)>	
				
				<cfif structKeyExists(form,"#Prefix#ObjectID") AND FORM["#Prefix#ObjectID"] EQ stObj.ObjectID>
					
					<cfset variables.farcryFormPrefixesToProcess = ListAppend(variables.farcryFormPrefixesToProcess,Prefix )>
	
				</cfif>
	
				
				<cfif NOT isDefined("CALLER.stPLP.plp.inputObjects") or NOT structKeyExists(CALLER.stPLP.plp.inputObjects,stObj.ObjectID)>
					<cfset CALLER.stPLP.plp.inputObjects[stObj.ObjectID] = Duplicate(stObj)>	
					<cfset CALLER.stPLP.plp.outputObjects[stObj.ObjectID] = Duplicate(stObj)>	
				</cfif>
			
			
			<!--- Processing a Type --->
			<cfelse>
	
				<cfif structKeyExists(FORM,"#Prefix#typename") AND FORM["#Prefix#typename"] EQ attributes.typename>
	
					<cfset variables.farcryFormPrefixesToProcess = ListAppend(variables.farcryFormPrefixesToProcess,Prefix )>
	
				</cfif>
	
	
			</cfif>
		</cfif>

	</cfloop>
	
	<cfif NOT len(variables.farcryFormPrefixesToProcess)>
		<cfexit method="exittag">
	</cfif>
	
	
	<cfset ProcessingFormObjectPosition = 1>
	
	
	<!--- DO THIS THE FIRST TIME THROUGH (AND THEN AGAIN IN THE END for each loop --->
	<cfset SetupProcessObject(Position=ProcessingFormObjectPosition)>
			
	

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	

	<cfif (isDefined("Request.BreakProcessingCurrentFormObject") AND Request.BreakProcessingCurrentFormObject EQ 1)>
		
		<!--- DO NOT PROCESS THIS LOOP --->
		<cfset Request.BreakProcessingCurrentFormObject = 0>

	<cfelse>
		
					
		<cfif structKeyExists(application.types, typename)>
			<cfset stPackage = application.types[typename]>
			<cfset packagePath = application.types[typename].typepath>
		<cfelse>
			<cfset stPackage = application.rules[typename]>
			<cfset packagePath = application.rules[typename].rulepath>
		</cfif>
		


		<cfset stType = createobject("component",packagePath)>
		<cfif isDefined("session.dmSec.authentication.userlogin")>
			<cfset "CALLER.stProperties.lastupdatedby" = session.dmSec.authentication.userlogin>
		<cfelse>
			<cfset CALLER.stProperties.lastupdatedby = "anonymous">
		</cfif>
		
		
		<cfset stObj = stType.getData(Caller[attributes.r_stProperties].ObjectID) />
		<cfset bResult = structAppend(Caller[attributes.r_stProperties], stObj, false )  />
		
		
		
		<cfif attributes.bimageautogenerate>
			<cfset oFormTools = createObject("component", "farcry.core.packages.farcry.formtools") />
			<cfset Caller[attributes.r_stProperties] = oFormTools.ImageAutoGenerateBeforeSave(stProperties=Caller[attributes.r_stProperties],stFields=stFields, stFormPost=Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']) />
		</cfif>
		
		<cfif structKeyExists(stType,"BeforeSave")>
			<cfset Caller[attributes.r_stProperties] = stType.BeforeSave(stProperties=Caller[attributes.r_stProperties],stFields=stFields, stFormPost=Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']) />	
		</cfif>
		
		
		<cfif isDefined("ParentTag") AND ListFindNoCase(ParentTag, "cf_wizzard")>
		
			<cfset stBaseTag = GetBaseTagData("cf_wizzard")>
			<cfset stWizzard = stBaseTag.stWizzard>
			<!--- Not in the wizzard and therefore a new object. Need to save to db and then put in the wizzard --->
			<cfif NOT structKeyExists(stWizzard.data,Caller[attributes.r_stProperties].objectid)>
				<cfset stObj = stType.setData(stProperties=Caller[attributes.r_stProperties],user=Variables.LockedBy)>
				<cfset stWizzard.data[Caller[attributes.r_stProperties].objectid] =  Duplicate(stObj)>
			</cfif>
			
			<!--- TO DO. NEED TO ADD ALL PROPERTIES TO DATA AND NOT JUST THE ONES SUBMITTED. --->
			<cfloop list="#structKeyList(Caller[attributes.r_stProperties])#" index="i">
				<cfset stWizzard.data[attributes.objectID][i] = Caller[attributes.r_stProperties][i]>
			</cfloop>
			
	
		<cfelseif isDefined("attributes.insidePLP") AND attributes.insidePLP EQ 1>

	
				
			<cfif not isDefined("CALLER.inputObjects") OR not structKeyExists(CALLER.inputObjects,"#Caller.stProperties.ObjectID#")>	
				
				<cfif not isDefined("Caller.stProperties.typename") or not len(Caller.stProperties.typename)>
		
					<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
					<cfset Caller.stProperties.typename = q4.findType(objectid=Caller.stProperties.ObjectID)>
		
				</cfif>
													
				<cfset stType = createobject("component",application.types[Caller.stProperties.typename].typepath)>	
				<cfset stObj = stType.getData(Caller.stProperties.ObjectID)>	
				<cfset CALLER.inputObjects[Caller.stProperties.ObjectID] = Duplicate(stObj)>	
				<cfset CALLER.outputObjects[Caller.stProperties.ObjectID] = Duplicate(stObj)>	
			</cfif>
			
			


			
			<cfloop list="#lFields#" index="i" >

				<cfif isDefined("Caller.#attributes.r_stProperties#.#i#")>	
					<!--- PLP outputObjects is used to store multiple objects in the plp. --->					
					<cfset CALLER.outputObjects[#Caller.stProperties.ObjectID#][#i#] = Caller[attributes.r_stProperties][i]>	
					
					<!--- PLP object is used to store the base object of the PLP --->
					<cfif isDefined("CALLER.output.objectid") AND CALLER.output.objectID EQ Caller.stProperties.ObjectID>						
						<cfset CALLER.output[#i#] = Caller[attributes.r_stProperties][i]>	
					</cfif>
				</cfif>
	
	
			</cfloop>	
			
		<cfelse>		
			

			
			<!--- Save the object with new properties --->
			<cfset stObj = stType.setData(stProperties=Caller[attributes.r_stProperties],user=Variables.LockedBy, bSessionONly="#attributes.bSessionOnly#")>		
			
			<!--- We need to return the new structure if requested. --->
			<cfif isDefined("attributes.r_stObject") AND len(attributes.r_stObject)>
				<cfset caller[attributes.r_stObject] = stType.getData(objectid=Caller[attributes.r_stProperties].objectid) />
			</cfif>
			
			
			<cftry>
				<cfset stType.setlock(stObj=Caller[attributes.r_stProperties],locked="false",lockedby=Variables.LockedBy)>
				<cfcatch >
					<!--- TODO: Rules do not currently have the ability to be locked. --->					
				</cfcatch>
			</cftry>
		
			
			
		</cfif>	
		
		<cfif len(attributes.lArrayListGenerate)>
			
			<cfset stObj = stType.getData(objectid=Caller[attributes.r_stProperties].ObjectID, bUseInstanceCache=false, bArraysAsStructs=true)>
			<cfset oFormTools = createObject("component", "farcry.core.packages.farcry.formtools") />
			<cfloop list="#attributes.lArrayListGenerate#" index="i">
				<cfset arrayField = stFields[i].metadata.ftArrayField />
				<cfif structKeyExists(stFields[i].metadata, "ftListType")>
					<cfset ListType = stFields[i].metadata.ftListType />
				<cfelse>
					<cfset ListType = "none" />
				</cfif>
				<cfif structKeyExists(stFields[i].metadata, "ftWebskin")>
					<cfset Webskin = stFields[i].metadata.ftWebskin />
				<cfelse>
					<cfset Webskin = "" />
				</cfif>
				<cfif structKeyExists(stFields[i].metadata, "ftIncludeLink")>
					<cfset bIncludeLink = stFields[i].metadata.ftIncludeLink />
				<cfelse>
					<cfset bIncludeLink = "false" />
				</cfif>
				<cfset stObj[i] = oFormTools.ArrayListGenerate(aField=stObj[arrayField], ListType=ListType, Webskin=Webskin, bIncludeLink=bIncludeLink) />
			</cfloop>
			<cfset stResult = stType.setData(stProperties=stObj,user=Variables.LockedBy)>		
		</cfif>
		

		
		<cfif structKeyExists(stType,"AfterSave")>
			<cfset stResult = stType.AfterSave(stProperties=Caller[attributes.r_stProperties])>		
		</cfif>
		<cfset caller.lSavedObjectIDs = listappend(caller.lSavedObjectIDs,Caller[attributes.r_stProperties].ObjectID)>






			

	</cfif>


	<cfset dummy = StructDelete(Caller,"stProperties")>

	<cfset ProcessingFormObjectPosition = ProcessingFormObjectPosition  + 1>

	<cfif ProcessingFormObjectPosition LTE ListLen(variables.farcryFormPrefixesToProcess)>

		<cfset SetupProcessObject(Position=ProcessingFormObjectPosition)>
		
		<cfexit method="loop" >

	</cfif>


</cfif>


<cffunction name="Init">
	<cfargument name="stObj" required="true" type="any">
	<cfargument name="ObjectID" required="true" type="string">
	<cfargument name="typename" required="true" type="string">
	
	<cfset stResult = StructNew()>
	
	<cfif isStruct(arguments.stObj) and NOT structIsEmpty(arguments.stObj)>


		<cfset stResult.stObj = arguments.stObj>
		<cfset stResult.typename = arguments.stObj.typename>
		
			
		<cfif structKeyExists(application.types, stResult.typename)>
			<cfset stPackage = application.types[stResult.typename]>
			<cfset packagePath = application.types[stResult.typename].typepath>
		<cfelse>
			<cfset stPackage = application.rules[stResult.typename]>
			<cfset packagePath = application.rules[stResult.typename].rulepath>
		</cfif>
		
		
		<cfset stResult.stType = createobject("component",packagePath)>
		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>


	
	<cfelseif len(arguments.ObjectID)>

		
		<cfif not isDefined("arguments.typename") or not len(arguments.typename)>

			<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
			<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>

		</cfif>
		
		
		<cfset stResult.typename = arguments.typename>
			
			
		<cfif structKeyExists(application.types, stResult.typename)>
			<cfset stPackage = application.types[stResult.typename]>
			<cfset packagePath = application.types[stResult.typename].typepath>
		<cfelse>
			<cfset stPackage = application.rules[stResult.typename]>
			<cfset packagePath = application.rules[stResult.typename].rulepath>
		</cfif>
		
		
		<cfset stResult.stType = createobject("component",packagePath)>

		<cfset stResult.stObj = stResult.stType.getData(arguments.objectID)>

		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>
		
	<cfelseif len(arguments.typename)>


		<cfset stResult.stObj = StructNew()>
		<cfset stResult.typename = arguments.typename>
			
		<cfif structKeyExists(application.types, stResult.typename)>
			<cfset stPackage = application.types[stResult.typename]>
			<cfset packagePath = application.types[stResult.typename].typepath>
		<cfelse>
			<cfset stPackage = application.rules[stResult.typename]>
			<cfset packagePath = application.rules[stResult.typename].rulepath>
		</cfif>
		
		
		
		<cfset stResult.stType = createobject("component",packagePath)>
		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>
	<cfelse>
		<!--- PROCESSING ALL SUBMITTED OBJECTS --->
		<!--- <cfabort showerror="Processing Unknown Form Objects"> --->
		<!--- <cfexit> --->
	</cfif>
		
	<cfreturn stResult> 
</cffunction>

<cffunction name="SetupProcessObject" access="private" output="true" returntype="void">
	<cfargument name="Position" required="yes" type="numeric">
	


	<cfset ProcessingFormObjectPrefix = ListGetAt(variables.farcryFormPrefixesToProcess,arguments.Position)>

	<cfset Caller[attributes.r_stProperties] = structNew() />

	<cfloop list="#lFields#" index="i" >

		<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix##i#")>
			
		
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['MetaData'][i] = StructNew()>

			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['MetaData'][i] = Duplicate(stFields[i].MetaData)>
	
			<cfset ftFieldMetadata = request.farcryForm.stObjects[ProcessingFormObjectPrefix].MetaData[i]>
			<cfset ftFieldMetadata.FormFieldPrefix = ProcessingFormObjectPrefix>
	
			
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
		
		
				
			<!--- Need to put all the form fields relevent to this field into a struct. This will include any fields that begin with the name of the field. ie. OrderDate field will also put OrderDateDay, OrderDateMonth and OrderDateYear into the struct --->
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i] = StructNew()>
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value = "">
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].stSupporting = StructNew()>

			<cfloop list="#StructKeyList(FORM)#" index="j">
				<cfif FindNoCase("#ProcessingFormObjectPrefix##i#",j)>
				
					<!--- This will strip out the prefix from the FormFields and enable us to send a clean formpost structure to validate with only the current object formfields by their original name. --->
					<cfif "#ProcessingFormObjectPrefix##i#" EQ j>
						<!--- This is the actual field value --->
						<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value = FORM[j]>
					<cfelse>
						<!--- These are supporting fields --->
						<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].stSupporting[ReplaceNoCase(j,'#ProcessingFormObjectPrefix##i#','')] = FORM[j]>
					</cfif>
					
				</cfif>
			</cfloop>

	
			
			
			
			<!--- Need to determine which method to run on the field --->		

			<cfif structKeyExists(ftFieldMetadata,"ftValidationMethod")>
				<cfset FieldMethod = ftFieldMetadata.ftValidationMethod>
			<cfelse>
				<cfset FieldMethod = "validate">
			</cfif>	

			<cfif i EQ "ObjectID" or i EQ "typename">
				<cfset "Caller.#attributes.r_stProperties#.#i#" = Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value>
			<cfelse>
				<cfset o = application.formtools[ftFieldMetadata.ftType].oFactory.init() />
				<cfinvoke component="#o#" method="#FieldMethod#" returnvariable="stResult">
					<cfinvokeargument name="ObjectID" value="#FORM['#ProcessingFormObjectPrefix#objectid']#">
					<cfinvokeargument name="Typename" value="#FORM['#ProcessingFormObjectPrefix#typename']#">			
					<cfinvokeargument name="stFieldPost" value="#Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i]#">
					<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
				</cfinvoke>
							
				<cfset Caller[attributes.r_stProperties][i] = stResult.Value />
				<cfif ftFieldMetadata.ftType eq "image">
					<cfset attributes.bimageautogenerate ="true" />
				</cfif>
				
				<cfif ftFieldMetadata.ftType eq "array">
					<cfloop list="#structKeyList(stFields)#" index="j">
						<cfif structKeyExists(stFields[j].metadata, "ftType") AND structKeyExists(stFields[j].metadata, "ftArrayField") AND stFields[j].metadata.ftType EQ "arrayList" AND stFields[j].metadata.ftArrayField EQ i>
						
							<cfset attributes.lArrayListGenerate = listAppend(attributes.lArrayListGenerate, j) />
							
						</cfif>
						
					</cfloop>
				</cfif>
				
				
				
			</cfif>
		
		
		
		</cfif>
	</cfloop>
	
	<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix#typename")>
		<cfset "Caller.#attributes.r_stProperties#.typename" = Evaluate("FORM['#ProcessingFormObjectPrefix#typename']")>
	</cfif>
</cffunction>
