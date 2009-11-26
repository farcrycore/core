
<cfparam name="form.fieldname" default="" />
<cfparam name="form.selectedObjectIDs" default="" />
<cfparam name="form.rootNodeID" default="" />


<cfquery datasource="#application.dsn#" name="qRoot">
	SELECT objectid, objectname, nLeft,nRight
	FROM nested_tree_objects
	WHERE typename = 'dmCategory'
	AND ObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.rootNodeID#" />
</cfquery>

<cfset qSelected = queryNew("nLeft,nRight") />

<cfif len(form.selectedObjectIDs)>
	<cfquery datasource="#application.dsn#" name="qSelected">
		SELECT nLeft,nRight
		FROM nested_tree_objects
		WHERE typename = 'dmCategory'
		AND ObjectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.selectedObjectIDs#" />)
	</cfquery>
</cfif>




<cfoutput>
<ul class="unorderedlisttree" id="#form.fieldname#-checkboxTree">
	<cfif qRoot.recordCount>
		#renderNode(qRoot.objectid, qRoot.objectname, qRoot.nLeft, qRoot.nRight)#
	</cfif>
</ul>
</cfoutput>



<cffunction name="renderNode" access="private" output="true">
	<cfargument name="nodeID" required="true" />
	<cfargument name="nodeLabel" required="true" />
	<cfargument name="nLeft" required="false" default="1" />
	<cfargument name="nRight" required="false" default="2" />
	
	<cfset var qChildren = "" />
	<cfset var checked = false />
	<cfset var expanded = false />
	
	
	<cfquery datasource="#application.dsn#" name="qChildren">
		SELECT *
		FROM nested_tree_objects
		WHERE parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.nodeID#" />
		ORDER BY nleft
	</cfquery>
	
	
	<cfif listFindNoCase(form.selectedObjectIDs, arguments.nodeID) >
		<cfset checked = true />
		<cfset expanded = true />
	</cfif>
	
	<cfif not expanded>		
		<cfloop query="qSelected">
			<cfif arguments.nRight GT qSelected.nRight AND arguments.nLeft LT qSelected.nLeft>
				<cfset expanded = true />
				<cfbreak />
			</cfif>
		</cfloop>	
	</cfif>

	<cfoutput>
	<li>
	    <input type="checkbox" name="#form.fieldname#" value="#arguments.nodeID#" <cfif checked>checked="checked"</cfif>>
	    <label>#jsstringFormat(arguments.nodeLabel)#</label>
		<cfif qChildren.recordCount>
			<ul <cfif expanded>ft:expanded="expanded"</cfif>>
				<cfloop query="qChildren">
					#renderNode(qChildren.objectid, qChildren.objectname, qChildren.nLeft, qChildren.nRight)#
				</cfloop>
			</ul>
		</cfif>
	</li>
	</cfoutput>

</cffunction> 

