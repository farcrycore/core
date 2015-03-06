<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Provides an interface for formtools to provide AJAX functionality --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- explicitly set ajax request mode --->
<cfset request.mode.ajax = 1>

<cfloop collection="#url#" item="key">
	<cfif refindnocase("/formtool/\w+",key)>
		<cfloop from="1" to="#listlen(key,'/')#" index="i" step="2">
			<cfset url[listgetat(key,i,"/")] = listgetat(key,i+1,"/") />
		</cfloop>
		<cfbreak />
	</cfif>
</cfloop>

<cfparam name="url.formtool" />
<cfparam name="url.typename" />
<cfparam name="url.property" />
<cfparam name="url.fieldname" />


<cfset stMetadata = duplicate(application.stCOAPI[url.typename].stProps[url.property].metadata) />
<cfset oType = createobject("component",application.stCOAPI[url.typename].packagepath) />

<!---
<cfset stObj = oType.getData(objectid=url.objectid) />
<cfset stMetadata.value = stObj[url.property] />
--->
<!--- SET THE VALUE PASSED INTO THE FORMTOOL --->
<cfif len(url.property) AND structKeyExists(form, url.property)>
	<cfset stMetadata.value = form[url.property] />
<cfelse>
	<cfset stMetadata.value = "" />
</cfif>
<cfif len(url.fieldname)>
	<cfset stMetadata.FormFieldPrefix = left(url.fieldname,len(url.fieldname)-len(url.property)) />
<cfelse>
	<cfset stMetadata.FormFieldPrefix = "" />
</cfif>

<cfif structkeyexists(url,"objectid")>
	<cfset stObj = oType.getData(objectid=url.objectid) />
<cfelse>
	<cfset stObj = structnew() />
</cfif>


<!--- Update the object with any other fields that have come through --->
<cfset stFieldPost = structnew() />
<cfset stFieldPost.stSupporting = structnew() />
<cfset stFieldPost.stSupporting.value = stMetadata.value />
<cfif structkeyexists(form,"fieldnames")>
	<cfloop list="#form.fieldnames#" index="key">
		
		<cfif application.fapi.getPropertyMetadata( typename=url.typename, property=key, md='type', default='string' ) EQ "array">
			<cfset stObj[key] = listToArray(form[key]) />
		<cfelseif structkeyexists(application.stCOAPI[url.typename].stProps,key)>
		<cfset stObj[key] = form[key] />
		<cfelseif refindnocase("^#url.property#",key)>
			<cfset stFieldPost.stSupporting[mid(key,len(url.property)+1,len(key))] = form[key] />
		</cfif>
		
	</cfloop>
</cfif>

<!--- Save the updated object to the session --->
<cfif structKeyExists(stobj, "objectid") AND len(stobj.objectid)>
	<cfset stResult = application.fapi.setData(stProperties="#stObj#", bSessionOnly="true") />
</cfif>

<!--- Figure out ajax method --->
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
	<cfinvokeargument name="stFieldPost" value="#stFieldPost#" />
</cfinvoke>

<cfcontent reset="true">
<cfoutput>#out#</cfoutput><cfabort>

<cfsetting enablecfoutputonly="false" />