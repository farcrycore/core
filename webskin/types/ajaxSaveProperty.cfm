
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stProperties = structNew() />
<cfset stProperties.objectID = stobj.objectid />
<cfset stProperties.typename = stobj.typename />

<cfparam name="url.propertyName" default="">
<cfparam name="url.bSessionOnly" default="false">
<cfset starttime = getTickCount() />
<cfif application.fapi.isLoggedIn()>

	<cfif  len(url.propertyName)>
		<!--- Default fieldType to the object type --->
		<cfset oValidate = application.fapi.getContentType(stobj.typename) />
		<cfset stFieldMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.propertyName#")>
		
		<cfset stFormPost = structNew()>
		<cfset stFormPost[url.propertyName] = StructNew()>
		<cfset stFormPost[url.propertyName].value = stobj[url.propertyName]><!--- Default to current value --->
		<cfset stFormPost[url.propertyName].stSupporting = StructNew()>

		<cfloop list="#StructKeyList(FORM)#" index="j">
			
				<!--- This will strip out the prefix from the FormFields and enable us to send a clean formpost structure to validate with only the current object formfields by their original name. --->
				<cfif j EQ url.propertyName>
					<!--- This is the actual field value --->
					<cfset stFormPost[url.propertyName].value = FORM[j]>
				<cfelse>
					<!--- These are supporting fields --->
					<cfset stFormPost[url.propertyName].stSupporting[ReplaceNoCase(j,url.propertyName,'')] = FORM[j]>
				</cfif>
				
		</cfloop>



		
		<!--- Make sure that the field exists in the type --->
		<cfif isStruct(stFieldMetadata)>
			<!--- Need to determine which method to run on the field --->
			<cfif len( stFieldMetadata.ftValidateMethod )>
				<!--- Check to see if this method exists in the current oType CFC. If not hange on to the formtool --->
				<cfif not structKeyExists(oValidate, stFieldMetadata.ftValidateMethod)>
					<cfset oValidate = application.fapi.getFormtool(stFieldMetadata.ftType) />
				</cfif>
			<cfelseif structKeyExists(oValidate,"ftValidate#url.propertyName#")>
				<cfset validateMethod = "ftValidate#url.propertyName#" />
			<cfelse>
				<cfset validateMethod = "validate" />
				<cfset oValidate = application.fapi.getFormtool(stFieldMetadata.ftType) />
			</cfif>
			<cfinvoke component="#oValidate#" method="#validateMethod#" returnvariable="stValidateFieldResult">
				<cfinvokeargument name="ObjectID" value="#stobj.objectid#">
				<cfinvokeargument name="Typename" value="#stobj.typename#">			
				<cfinvokeargument name="stFormPost" value="#stFormPost#">
				<cfinvokeargument name="stFieldPost" value="#stFormPost[url.propertyName]#">
				<cfinvokeargument name="stMetadata" value="#stFieldMetadata#">
			</cfinvoke>
			
			<cfif stValidateFieldResult.bSuccess>
				<cfset stProperties[url.propertyName] = stValidateFieldResult.value>
				
				<!--- 
				IF WE HAVE A NEW OBJECT, NOT YET IN THE DATABASE, THEN WE NEED TO SAVE THE CORE PROPERTIES
				 --->			
				<cfif structKeyExists(stObj, "BDEFAULTOBJECT") AND stobj.BDEFAULTOBJECT>
					<cfset bSetDefaultCoreProperties = true>
				<cfelse>
					<cfset bSetDefaultCoreProperties = false>
				</cfif>
				

				<cfif structKeyExists(this, "setData#url.propertyName#")>
					<cfinvoke component="#this#" method="setData#url.propertyName#" returnvariable="stSetDataResult">
						<cfinvokeargument name="ObjectID" value="#stobj.objectid#">
						<cfinvokeargument name="value" value="#stValidateFieldResult.value#">			
						<cfinvokeargument name="dsn" value="#application.dsn#">
						<cfinvokeargument name="bSessionOnly" value="#url.bSessionOnly#">
						<cfinvokeargument name="bSetDefaultCoreProperties" value="#bSetDefaultCoreProperties#">
						<cfinvokeargument name="bAudit" value="false">
					</cfinvoke>
				<cfelse>
					<cfif structKeyExists(stFieldMetadata, "bLabel") AND stFieldMetadata.bLabel >
						<cfset stProperties.label = trim(autoSetLabel(stProperties=stProperties)) />
					</cfif>

					<cfset stSetDataResult = application.fapi.setData(	stProperties="#stProperties#", 
																		bSessionOnly="#url.bSessionOnly#", 
																		bSetDefaultCoreProperties="#bSetDefaultCoreProperties#", 
																		bAudit="false") />
				</cfif>
				
				
				
				
				<cfif stSetDataResult.bSuccess>
					<cfset stResult = application.fapi.success(stSetDataResult.message)>
				<cfelse>
					<cfset stResult = application.fapi.fail(stSetDataResult.message)>
				</cfif>
			<cfelse>
				<cfset stResult = application.fapi.fail(stValidateFieldResult.stError.message)>
			</cfif>
			
		<cfelse>
			<cfset stResult = application.fapi.fail("property name #url.propertyName# does not exist")>
		</cfif>
		
		
	<cfelse>
		<cfset stResult = application.fapi.fail("You must send a property name")>
	</cfif>
<cfelse>
	<cfset stResult = application.fapi.fail("not logged in")>
</cfif>
<cfset stResult.duration = "#getTickCount()-starttime#">
<cfcontent 	
	reset="true"
	type="application/json"
	variable="#toBinary( toBase64( serializeJSON( stResult ) ) )#"
	/>