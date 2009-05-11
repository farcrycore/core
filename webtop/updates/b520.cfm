<!--- @@description:
Adds datetimelastupdate field to all rule tables<br />
--->
<cfoutput>
<html>
<head>
<title>Farcry Core 5.2.0 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>
	
	<cfset result = "" />
	
	<cfloop collection="#application.stCOAPI#" item="thistype">
		<cfif find(".types.",application.stCOAPI[thistype].packagepath) and structkeyexists(application.stCOAPI[thistype].stProps,"status")>
			<cfloop collection="#application.stCOAPI[thistype].stProps#" item="thisprop">
				<cfif isdefined("application.stCOAPI.#thistype#.stProps.#thisprop#.metadata.ftType") and application.stCOAPI[thistype].stProps[thisprop].metadata.ftType eq "file">
					<cfquery datasource="#application.dsn#" name="qFiles">
						select		objectid,label,#thisprop#
						from		#application.dbowner##thistype#
						where		status=<cfqueryparam cfsqltype="cf_sql_varchar" value="draft" />
					</cfquery>
					
					<cfloop query="qFiles">
						<cftry>
							<cfset application.formtools.file.oFactory.onDraft(
									typename=thistype,
									stObject=application.fapi.getContentObject(objectid=qFiles.objectid,typename=thistype),
									stMetadata=application.stCOAPI[thistype].stProps[thisprop].metadata,
									previousStatus="approved"
								) />
							
							<cfcatch>
								<cfset result = "#result#<li>Error moving file (#thisprop#) for #qFiles.label# (#qFiles.objectid#): #cfcatch.message#</li>" />
							</cfcatch>
						</cftry>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
	
	<cfoutput><p><strong>All done.</strong> Return to <a href="#application.url.webtop#">FarCry Webtop</a>.</p></cfoutput>
	<cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li>Moves files for draft objects into the secure files directory</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run 5.2.0 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
