<cfcomponent extends="types" name="dmWizzard" displayname="Wizzard" hint="Wizzard" bSystem="true">

<!--------type properties-------->
<cfproperty name="ReferenceID" type="string" displayname="Reference ID" hint="Reference ID of the Wizzard. A UUID for an existing object or a Typename for a new object" required="yes" >
<cfproperty name="UserLogin" type="string" displayname="User Login" hint="Login ID of the user." required="no" default="" >
<cfproperty name="Data" type="longchar" displayname="WDDX Data" hint="WDDX packet of the Wizzard Data." required="no" default="" >
<cfproperty name="PrimaryObjectID" type="UUID" displayname="Primary ObjectID" hint="Object ID of the Primary Object." required="no" default="" >
<cfproperty name="Steps" type="longchar" displayname="Steps" hint="List of steps in the Wizzard Process" required="no" default="" >
<cfproperty name="CurrentStep" type="numeric" displayname="Current Step" hint="Current Step in the Wizzard Process" required="no" default="1" >


<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >



<cfscript>
/**
* Returns TRUE if the string is a valid CF UUID.
*
* @param str String to be checked. (Required)
* @return Returns a boolean.
**/

function IsUUID(str) {
return REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str);
}
</cfscript>


<cffunction name="Read" access="public" output="true" returntype="struct" hint="Returns the Wizzard Object with the WDDX Data field converted to a CF Structure">
	<cfargument name="WizzardID" required="no" type="UUID">
	<cfargument name="UserLogin" required="no" type="String">
	<cfargument name="ReferenceID" required="no" type="String">
	
	<cfif isDefined("arguments.WizzardID") and len(arguments.WizzardID)>
		<cfset stWizzard = getData(objectID=arguments.WizzardID) />
	<cfelseif isDefined("arguments.UserLogin") and len(arguments.UserLogin) AND isDefined("arguments.ReferenceID") and len(arguments.ReferenceID)>
		<cfquery datasource="#application.dsn#" name="qWizzard">
		SELECT *
		FROM dmWizzard
		WHERE ReferenceID = '#arguments.ReferenceID#'
		AND UserLogin = '#arguments.UserLogin#'
		</cfquery>
		
		<!--- If the wizzard exists, create the CF struct to return --->
		<cfif qWizzard.RecordCount>
			<cfset stWizzard = getData(objectID=qWizzard.objectid) />
		<cfelseif isDefined("arguments.UserLogin") and len(arguments.UserLogin) AND isDefined("arguments.ReferenceID") and len(arguments.ReferenceID)>
			<cfset stWizzard = Create(ReferenceID=arguments.ReferenceID,UserLogin=arguments.UserLogin)>
		</cfif>
		
	</cfif>
	
	<cfif isDefined("stWizzard.Data")>
		<!--- only run this if the wddx packet has not already been extracted into a struct --->
		<cfif  not isStruct(stWizzard.Data)>
			<cfwddx action="WDDX2CFML" input="#stWizzard.Data#" output="stWizzardData">
			<cfset stWizzard.Data = duplicate(stWizzardData) />
		</cfif>
	<cfelse>
		<cfabort showerror="Farcy could not find or create the wizzard requested." />
	</cfif>
	
	<!--- return the struct --->
	<cfreturn stWizzard>
	
		
</cffunction>

<cffunction name="create" access="public" output="false" returntype="struct">
<cfargument name="ReferenceID" required="yes" type="String">
<cfargument name="UserLogin" required="yes" type="String">

<cfset stProperties = StructNew()>
<cfset stProperties.UserLogin = arguments.UserLogin>
<cfset stProperties.ReferenceID = arguments.ReferenceID>

<cfif isUUID(arguments.ReferenceID)>
<cfset typename = findType(ObjectID=arguments.ReferenceID) />
<cfset o = createObject("component",application.types["#variables.typename#"].typepath) />
<cfset st = o.getData(objectid=arguments.ReferenceID) />
<cfelse>
<cfif structKeyExists(application.types,arguments.ReferenceID)>
<cfset o = createObject("component",application.types["#arguments.ReferenceID#"].typepath) />
<cfset st = o.getData(objectid=CreateUUID()) />
</cfif>
</cfif>

<cfset stProperties.PrimaryObjectID = st.ObjectID>
<cfset stProperties.CurrentStep = 1>
<cfset stProperties.OwnedBy = 'help'>

<cfset variables.data = StructNew() />
<cfset variables.data[st.ObjectID] = st />

<cfwddx action="CFML2wddx" input="#variables.data#" output="stProperties.Data">

<cfset stResult = createData(stProperties=stProperties,user=stProperties.UserLogin) />
<cfset stWizzard = getData(objectID=stresult.objectid) />

<cfreturn stWizzard>

</cffunction>


<cffunction name="Write" access="public" output="true" returntype="struct" hint="Saves the wizzard to the DB and returns the Wizzard Data as a structure">
<cfargument name="ObjectID" required="yes" type="UUID">
<cfargument name="CurrentStep" required="no" type="numeric">
<cfargument name="Steps" required="no" type="string" default="">
<cfargument name="Data" required="no" type="Struct">

<cfset stWizzard = getData(objectID=arguments.objectid) />

<cfif isDefined("arguments.CurrentStep") AND len(arguments.CurrentStep)>
<cfset stWizzard.CurrentStep = arguments.CurrentStep>
</cfif>

<cfif isDefined("arguments.Steps") AND len(arguments.steps)>
<cfset stWizzard.Steps = arguments.Steps>
</cfif>

<cfif isDefined("arguments.Data")>
	<cfwddx action="CFML2wddx" input="#arguments.data#" output="stWizzard.Data">
</cfif>

<cfset stResult = setData(stProperties=stWizzard,user=stWizzard.UserLogin) />

<cfset stWizzard = getData(objectID=arguments.objectid) />

<cfwddx action="WDDX2CFML" input="#stWizzard.Data#" output="stWizzardData">
<cfset stWizzard.Data = stWizzardData />

<!--- we need to loop through each wizzard object and save to the session --->
<cfloop list="#structKeyList(stWizzard.Data)#" index="i">
	<cfset stProperties = stWizzard.Data[i] />
	
	<cfset bsuccess = createObject("component", application.types[stProperties.typename].typepath).setdata(stProperties=stProperties,bSessionOnly="true") />
</cfloop>

<!--- return the struct --->
<cfreturn stWizzard>

</cffunction>


<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
	<cfargument name="objectid" type="uuid" required="true">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	
	<cfset stWizzard = read(wizzardid=arguments.objectid) />
	
	<cfloop list="#structKeyList(stWizzard.data)#" index="i" >
		<cfset structDelete(Session.TempObjectStore, i) />
	</cfloop>
	
	
	<cfreturn super.deleteData(objectid=arguments.objectid,dsn=arguments.dsn, dbowner=arguments.dbowner) />
</cffunction>


</cfcomponent>
