<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfmodule template="#application.url.webroot#/download.cfm" DownloadFile="#url.downloadfile#">
<!--- <cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">

	<!--- should not be able to get object unless authorised. --->
	<cfif isDefined("url.DownloadFile") and len(trim(url.DownloadFile))>

		<q4:contentobjectget objectid="#url.DownloadFile#" r_stobject="stFile">
		<!--- <cfdump var="#stFile#"> --->
		<!--- <cfabort> --->
		<!--- pick a mime type (if required) --->
		<!--- <cfswitch expression="#lCase(stFile.FILETYPE)#">						

			<cfcase value="pdf">
				<cfset mime="application/pdf">
			</cfcase>
			
			<cfdefaultcase>
				<cfset mime="application/unknown">
			</cfdefaultcase>
		
		</cfswitch>  --->
		<cfset mime="application/unknown">
		
		<CFHEADER NAME="content-disposition" VALUE="inline; filename=#stFile.filename#">
		 					
		<cfcontent type="#mime#" file="#stFile.filepath#/#stFile.filename#" deletefile="No" reset="Yes">
		<cfabort>
				
	</cfif> --->

<cfsetting enablecfoutputonly="No">


