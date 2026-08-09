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
<cfparam name="url.formtheme" default="" />
<cfparam name="url.format" default="edit" />

<!--- the direct upload routes take a JSON POST only. checked here, above the
      pre-dispatch session save, so a request of another shape mutates nothing --->
<cfif structKeyExists(url,"s3op")>
	<cfset s3opContentType = trim(listfirst(lcase(cgi.content_type),";")) />

	<cfif cgi.request_method neq "POST">
		<cfset application.fapi.stream(content={ "error" = "Direct upload requests must be POSTed" },type="json",status="405 Method Not Allowed") />
		<cfabort />
	<cfelseif s3opContentType neq "application/json" and right(s3opContentType,5) neq "+json">
		<cfset application.fapi.stream(content={ "error" = "Direct upload requests must declare a JSON content type" },type="json",status="415 Unsupported Media Type") />
		<cfabort />
	</cfif>
</cfif>

<!--- a request naming a type or property this server does not declare resolves to nothing,
      so it is refused here rather than failing further in. url.formtool is not checked for
      existence: the agreement check below already pins it to the property's own ftType, and
      an ftType with no matching component (ftType defaults to the property's type, and there
      is no "date" formtool) is only ever reached by a type that handles the call itself --->
<cfif not structKeyExists(application.stCOAPI,url.typename)
		or not structKeyExists(application.stCOAPI[url.typename].stProps,url.property)>
	<cfset application.fapi.stream(content={ "error" = "Unknown type or property" },type="json",status="404 Not Found") />
	<cfabort />
</cfif>

<cfset stMetadata = duplicate(application.stCOAPI[url.typename].stProps[url.property].metadata) />

<!--- the handling component must be the one the property declares. the metadata is resolved
      server side above, so requiring agreement means every downstream check reads a context
      that is internally consistent. every core caller builds this url from the property's own
      ftType, so agreement is the normal case --->
<cfif not structKeyExists(stMetadata,"ftType") or compareNoCase(url.formtool,stMetadata.ftType) neq 0>
	<cfset application.fapi.stream(content={ "error" = "Formtool does not match the property" },type="json",status="400 Bad Request") />
	<cfabort />
</cfif>

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
<cfset bStagedProperty = false />
<cfif structkeyexists(form,"fieldnames")>
	<cfloop list="#form.fieldnames#" index="key">
		
		<cfif application.fapi.getPropertyMetadata( typename=url.typename, property=key, md='type', default='string' ) EQ "array">
			<cfset stObj[key] = listToArray(form[key]) />
			<cfset bStagedProperty = true />
		<cfelseif structkeyexists(application.stCOAPI[url.typename].stProps,key)>
		<cfset stObj[key] = form[key] />
			<cfset bStagedProperty = true />
		<cfelseif refindnocase("^#url.property#",key)>
			<cfset stFieldPost.stSupporting[mid(key,len(url.property)+1,len(key))] = form[key] />
		</cfif>
		
	</cfloop>
</cfif>

<!--- Save the updated object to the session. only when the loop above staged a property:
      a request that changed nothing has nothing to save, and leaves the session alone --->
<cfif bStagedProperty AND structKeyExists(stobj, "objectid") AND len(stobj.objectid)>
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

<cfset inputClass = application.fapi.getContentType(typename="formTheme" & url.formtheme).getFormtoolInputClass(stMetadata.ftType)>

<cfinvoke component="#oType#" method="#FieldMethod#" returnvariable="out">
	<cfinvokeargument name="typename" value="#url.typename#" />
	<cfinvokeargument name="stObject" value="#stObj#" />
	<cfinvokeargument name="stMetadata" value="#stMetadata#" />
	<cfinvokeargument name="fieldname" value="#url.fieldname#" />
	<cfinvokeargument name="stFieldPost" value="#stFieldPost#" />
	<cfinvokeargument name="inputClass" value="#inputClass#">
</cfinvoke>

<cfcontent reset="true">
<cfoutput>#out#</cfoutput><cfabort>

<cfsetting enablecfoutputonly="false" />