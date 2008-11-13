<cfprocessingDirective pageencoding="utf-8">

<cfset URL.objectName = replace(URL.objectname,"'","''","ALL")>
<cfif isDefined("URL.parentObjectID") AND isDefined("URL.objectname")>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="addCategory" returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#application.fc.utils.createJavaUUID()#"/>
		<cfinvokeargument name="categoryLabel" value="#url.objectname#"/>
		<cfinvokeargument name="parentID" value="#url.parentObjectID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke> 
	<cfoutput>
	<script>
		parent.document.location.href = parent.document.location.href;

	</script>
	</cfoutput>	
	
</cfif>