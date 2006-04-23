<cfif isDefined("URL.objectid")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="deleteCategory"returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#url.objectID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
		<!--- <cfdump var="#stStatus#"> --->
		<cfset message = "category deletion successful">
		
		<script>
			parent.document.location.reload();
		</script>
	
</cfif>