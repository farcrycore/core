<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false">

<cfif isDefined("attributes.node")>
	<cfset form.node = attributes.node />
</cfif>
<cfif isDefined("url.node")>
	<cfset form.node = url.node />
</cfif>

<cfif isDefined("url.selectedObjectIDs")>
	<cfset form.selectedObjectIDs = url.selectedObjectIDs />
</cfif>


<cfparam name="form.node" default="#application.catID.root#" />
<cfparam name="form.selectedObjectIDs" default="" />


<cfset qTreeCategories = queryNew("nLeft,nRight") />
<cfif len(form.selectedObjectIDs)>
	<cfquery datasource="#application.dsn#" name="qTreeCategories">
	SELECT * FROM nested_tree_objects
	WHERE typename = 'categories'
	AND ObjectID IN (#listQualify(form.selectedObjectIDs,"'")#)
	</cfquery>
</cfif>

<cfquery datasource="#application.dsn#" name="qTree">
select * 
from nested_tree_objects
where parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.node#" />
order by nleft
</cfquery>

<cfoutput>[</cfoutput>

	<cfloop query="qTree">
		<cfif qTree.currentRow NEQ 1><cfoutput>,</cfoutput></cfif>
		
		<cfoutput>
			{ 'id': '#qTree.objectid#', 'text': '#qTree.objectname#', 'leaf':  </cfoutput>
		<cfif qTree.nRight - qTree.nLeft EQ 1>
			<cfoutput>true</cfoutput>
		<cfelse>
			<cfoutput>false </cfoutput>			
		</cfif>
		<cfif listContainsNoCase(form.selectedObjectIDs,qTree.objectID)>
			<cfoutput>,checked:true</cfoutput>
		</cfif>
		

		
		
		<cfif qTree.nRight - qTree.nLeft NEQ 1>
			<cfset expanded = false />
			<cfloop query="qTreeCategories">
				<cfif qTree.nRight GT qTreeCategories.nRight AND qTree.nLeft LT qTreeCategories.nLeft>
					<cfset expanded = true />
				</cfif>
			</cfloop>		
			<cfif expanded>
				<cfoutput>, "expanded":true, "children":</cfoutput>
				<cf_getCategoryNodes node="#qTree.objectid#">
			</cfif>
		</cfif>
		<cfoutput>}</cfoutput>
	</cfloop>
	
<cfoutput>]</cfoutput>

<cfsetting enablecfoutputonly="false" />
