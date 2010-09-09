<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Provides an interface for formtools to provide AJAX functionality --->


<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfparam name="url.formtool" />
<cfparam name="url.typename" />
<cfparam name="url.property" />
<cfparam name="url.fieldname" />


<!--------------------------------------------------------------------------------------- 
THE SAVE NEEDS TO BE FIXED SO THAT THE OBJECT IS PASSED THROUGH <FT:PROCESSFORMOBJECTS />
A simple setdata causes problems with things like arrays being saved as empty strings.
 --------------------------------------------------------------------------------------->
 
<!--- Save the updated object to the session --->


<!---<ft:processFormObjects objectID="#url.objectid#" bSessionOnly="true">
	<cfloop list="#structKeylist(stProperties)#" index="key">
		<cfoutput>#stProperties[key]##chr(13)##chr(10)#</cfoutput>
	</cfloop>
</ft:processFormObjects>--->


<cfset stMetadata = duplicate(application.stCOAPI[url.typename].stProps[url.property].metadata) />
<cfset oType = createobject("component",application.stCOAPI[url.typename].packagepath) />

<!---
<cfset stObj = oType.getData(objectid=url.objectid) />
<cfset stMetadata.value = stObj[url.property] />
--->
<!--- SET THE VALUE PASSED INTO THE FORMTOOL --->
<cfif len(url.property) AND structKeyExists(form, url.property)>
	<cfset stMetadata.value = form[url.property] />
</cfif>

<cfif structkeyexists(url,"objectid")>
	<cfset stObj = oType.getData(objectid=url.objectid) />
<cfelse>
	<cfset stObj = structnew() />
</cfif>


<!--- Update the object with any other fields that have come through --->
<cfif structkeyexists(form,"fieldnames")>
	<cfloop list="#form.fieldnames#" index="key">
		<!---<cfoutput>#form[key]##chr(13)##chr(10)#</cfoutput>--->
		<cfif application.fapi.getPropertyMetadata( typename=url.typename, property=key, md='type', default='string' ) EQ "array">
			<cfset stObj[key] = listToArray(form[key]) />
		<cfelse>
		<cfset stObj[key] = form[key] />
		</cfif>
		
	</cfloop>
</cfif>

<!--- Save the updated object to the session --->
<cfif structKeyExists(stobj, "objectid") AND len(stobj.objectid)>
	<cfset stResult = application.fapi.setData(stProperties="#stObj#", bSessionOnly="true") />
</cfif>

<cfif structKeyExists(stMetadata,"ftAjaxMethod") AND len(stMetadata.ftAjaxMethod)>
	<cfset FieldMethod = stMetadata.ftAjaxMethod />

	<!--- Check to see if this method exists in the current oType CFC. If not, use the formtool --->
	<cfif not structKeyExists(oType,stMetadata.ftAjaxMethod)>
		<cfset oType = application.formtools[url.formtool].oFactory />
	</cfif>
<cfelse>
	<cfif structKeyExists(oType,"ftAjax#url.property#")>
		<cfset FieldMethod = "ftAjax#url.property#">
	<cfelse>
		<cfset FieldMethod = "ajax" />
		<cfset oType = application.formtools[url.formtool].oFactory />
	</cfif>
</cfif>

<cfinvoke component="#oType#" method="#FieldMethod#" returnvariable="out">
	<cfinvokeargument name="typename" value="#url.typename#" />
	<cfinvokeargument name="stObject" value="#stObj#" />
	<cfinvokeargument name="stMetadata" value="#stMetadata#" />
	<cfinvokeargument name="fieldname" value="#url.fieldname#" />
</cfinvoke>

<cfcontent reset="true">
<cfoutput>#out#</cfoutput><cfabort>

<cfsetting enablecfoutputonly="false" />