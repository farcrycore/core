<cfprocessingDirective pageencoding="utf-8">

<cfif isDefined("URL.objectid")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="deleteCategory"returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#url.objectID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>
		<!--- <cfdump var="#stStatus#"> --->
		<cfset message = "#application.adminBundle[session.dmProfile.locale].deleteCategoryOK#">
		
		<script>
			parent.document.location.reload();
		</script>
	
</cfif>