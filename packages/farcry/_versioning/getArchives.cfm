		<cfscript>
			sql = "select * from dmArchive where archiveID = '#objectID#' order by datetimecreated DESC";
		</cfscript>
		
		<cfquery datasource="#application.dsn#" name="qArchives">
			#preserveSingleQuotes(sql)#
		</cfquery>