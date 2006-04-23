<cfif isDefined("URL.parentObjectID") AND isDefined("URL.objectname")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="addCategory" returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#createUUID()#"/>
		<cfinvokeargument name="categoryLabel" value="#url.objectname#"/>
		<cfinvokeargument name="parentID" value="#url.parentObjectID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
	
	<script>
		parent.document.location.reload();
	</script>
	
</cfif>