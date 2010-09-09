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


<cfparam name="form.node" default="#application.catID.root#" />
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

<cfoutput>[</cfoutput>

	<cfloop query="qTree">
		<cfset tempLeft=qTree.nLeft>
		<cfset tempRight=qTree.nRight>
		<cfif qTree.currentRow NEQ 1><cfoutput>,</cfoutput></cfif>

		<cfoutput>
			{"id": "#qTree.objectid#", "text": "<label for='fccat-#qTree.objectid#'><input id='fccat-#qTree.objectid#' name='#form.fieldname#'  type='<cfif form.multiple>checkbox<cfelse>radio</cfif>' value='#qTree.objectid#' <cfif listFindNoCase(form.lSelectedItems, qTree.objectid)>checked</cfif> /> #jsstringFormat(qTree.objectname)#</label>", "leaf":  </cfoutput>
		<cfif qTree.nRight - qTree.nLeft EQ 1>
			<cfoutput>true</cfoutput>
		<cfelse>
			<cfoutput>false </cfoutput>
		</cfif>
		

		
		<cfif listContainsNoCase(form.lSelectedItems,qTree.objectID)>
			<cfoutput>,"checked":true</cfoutput>
		</cfif>



		<cfif qTree.nRight - qTree.nLeft NEQ 1>
			<cfset expanded = false />
			<cfloop query="qTreeCategories">
				<cfif tempRight GT qTreeCategories.nRight AND tempLeft LT qTreeCategories.nLeft>
					<cfset expanded = true />
				</cfif>
			</cfloop>
			<cfif expanded>
				<cfoutput>, "expanded":true, "children":</cfoutput>
				<cf_getCategoryNodes node="#qTree.objectid#">
			<cfelse>
				<cfoutput>,"hasChildren": </cfoutput>
				<cfif qTree.nRight - qTree.nLeft EQ 1>
					<cfoutput>false</cfoutput>
				<cfelse>
					<cfoutput>true</cfoutput>
			</cfif>
							
		</cfif>
		</cfif>
		<cfoutput>}</cfoutput>
	</cfloop>

<cfoutput>]</cfoutput>

<cfsetting enablecfoutputonly="false" />
