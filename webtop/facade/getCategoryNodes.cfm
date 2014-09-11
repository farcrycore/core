<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false">

<cfif isDefined("url.node")>
	<cfset form.node = url.node />
</cfif>
<cfif isDefined("attributes.node")>
	<cfset form.node = attributes.node />
</cfif>
<cfif isDefined("url.root") AND url.root NEQ "source">
	<cfset form.node = url.root />
</cfif>
<cfif isDefined("url.fieldname")>
	<cfset form.fieldname = url.fieldname />
</cfif>
<cfif isDefined("url.multiple")>
	<cfset form.multiple = url.multiple />
</cfif>

<cfif isDefined("url.lSelectedItems")>
	<cfset form.lSelectedItems = url.lSelectedItems />
</cfif>


<cfparam name="form.node" default="#application.fapi.getCatID("root")#" />
<cfparam name="form.lSelectedItems" default="" />
<cfparam name="form.multiple" default="true" />
<cfparam name="tempLeft" default="1" />
<cfparam name="tempRight" default="1" />

<cfset qTreeCategories = queryNew("nLeft,nRight") />

<cfif len(form.lSelectedItems)>
	<cfquery datasource="#application.dsn#" name="qTreeCategories">
		SELECT * FROM nested_tree_objects
		WHERE typename = 'dmCategory'
		AND ObjectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.lSelectedItems#" />)
	</cfquery>
</cfif>

<cfquery datasource="#application.dsn#" name="qTree">
	SELECT *
	FROM nested_tree_objects
	WHERE parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.node#" />
	ORDER BY nleft
</cfquery>

<cfset aResult = arraynew(1) />

<cfloop query="qTree">
	<cfset stNode = structnew() />
	<cfset stNode["id"] = qTree.objectid />
	
	<cfset stNode["text"] = "<label for='fccat-#qTree.objectid#'><input id='fccat-#qTree.objectid#' name='#form.fieldname#'  type='" />
	<cfif form.multiple>
		<cfset stNode["text"] = stNode["text"] & "checkbox" />
	<cfelse>
		<cfset stNode["text"] = stNode["text"] & "radio" />
	</cfif>
	<cfset stNode["text"] = stNode["text"] & "' value='#qTree.objectid#' " />
	<cfif listFindNoCase(form.lSelectedItems, qTree.objectid)>
		<cfset stNode["text"] = stNode["text"] & "checked" />
	</cfif>
	<cfset stNode["text"] = stNode["text"] & "	/> #qTree.objectname#</label>" />
	
	<cfif qTree.nRight - qTree.nLeft EQ 1>
		<cfset stNode["leaf"] = true />
	<cfelse>
		<cfset stNode["leaf"] = false />
	</cfif>
	
	<cfif listContainsNoCase(form.lSelectedItems,qTree.objectID)>
		<cfset stNode["checked"] = true />
	</cfif>
	
	<cfset tempLeft=qTree.nLeft>
	<cfset tempRight=qTree.nRight>
	<cfif qTree.nRight - qTree.nLeft NEQ 1>
		<cfset expanded = false />
		<cfloop query="qTreeCategories">
			<cfif tempRight GT qTreeCategories.nRight AND qTreeCategories.nLeft GT tempLeft>
				<cfset expanded = true />
			</cfif>
		</cfloop>
		<cfif expanded>
			<cfset stNode["expanded"] = true />
			<cfset stNode["children"] = arraynew(1) />
			<cf_getCategoryNodes node="#qTree.objectid#" variable="stNode.children">
		<cfelse>
			<cfif qTree.nRight - qTree.nLeft EQ 1>
				<cfset stNode["hasChildren"] = false />
			<cfelse>
				<cfset stNode["hasChildren"] = true />
			</cfif>
		</cfif>
	</cfif>
	
	<cfset arrayappend(aResult,stNode) />
</cfloop>

<cfif isdefined("attributes.variable")>
	<cfset "caller.#attributes.variable#" = aResult />
<cfelse>
	<cfcontent type="application/json" variable="#ToBinary( ToBase64( serializejson(aResult) ) )#" reset="Yes">
</cfif>

<cfsetting enablecfoutputonly="false" />