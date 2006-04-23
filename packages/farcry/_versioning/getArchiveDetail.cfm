<cfscript>
	sql = "select * from #application.dbowner#dmArchive where objectID = '#stArgs.objectID#'";
</cfscript>

<cfquery datasource="#application.dsn#" name="qArchives">
	#preserveSingleQuotes(sql)#
</cfquery>