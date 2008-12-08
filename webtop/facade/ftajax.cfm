<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Provides an interface for formtools to provide AJAX functionality --->

<cfparam name="url.formtool" />
<cfparam name="url.typename" />
<cfparam name="url.property" />
<cfparam name="url.fieldname" />

<cfset stMetadata = application.stCOAPI[url.typename].stProps[url.property].metadata />
<cfset oType = createobject("component",application.stCOAPI[url.typename].packagepath) />

<cfif structkeyexists(url,"objectid")>
	<cfset stObj = oType.getData(objectid=url.objectid) />
<cfelse>
	<cfset stObj = structnew() />
</cfif>

<cfif structkeyexists(form,"fieldnames")>
	<cfloop list="#form.fieldnames#" index="key">
		<cfset stObj[key] = form[key] />
	</cfloop>
</cfif>

<cfif structKeyExists(stMetadata,"ftAjaxMethod")>
	<cfset FieldMethod = stMetadata.ftAjaxMethod />
	
	<!--- Check to see if this method exists in the current oType CFC. If not, use the formtool --->
	<cfif not structKeyExists(oType,stMetadata.ftAjaxMethod)>
		<cfset oType = application.stCOAPI[url.formtool].oFactory />
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

<cfcontent reset="true"><cfoutput>#out#</cfoutput><cfabort>

<cfsetting enablecfoutputonly="false" />