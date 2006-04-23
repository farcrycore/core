		<cfscript>
			sql = "select * from #application.dbowner#dmArchive where archiveID = '#stArgs.objectID#' order by datetimecreated DESC";
		</cfscript>
		
		<cfquery datasource="#application.dsn#" name="qArchives">
			#preserveSingleQuotes(sql)#
		</cfquery>