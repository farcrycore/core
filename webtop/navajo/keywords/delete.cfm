<cfprocessingDirective pageencoding="utf-8">

<cfif isDefined("URL.objectid")>
	

<cftry>
	<cfinvoke  component="#application.packagepath#.farcry.category" method="deleteCategory"returnvariable="stStatus">
		<cfinvokeargument name="categoryID" value="#url.objectID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
		<!--- <cfdump var="#stStatus#"> --->
		<cfset message = "#application.rb.getResource("deleteCategoryOK")#">
		<cfoutput>
		<script language="javascript">
			parent.cattreeframe.location.reload();
		</script>
		</cfoutput>
	<cfcatch>
		<cfset errorMsg = cfcatch.message>
		<cfoutput>
		<script language="javascript">
			alert("#errorMsg#");
		</script>
		</cfoutput>
	</cfcatch>
</cftry>	
</cfif>