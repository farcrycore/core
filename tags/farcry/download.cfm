<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<cfif isdefined("attributes.downloadfile")>
	<cfset url.downloadfile = attributes.downloadfile>
</cfif>

<!--- should not be able to get object unless authorised. --->
<cfif isDefined("url.DownloadFile") and len(trim(url.DownloadFile))>

	<q4:contentobjectget objectid="#url.DownloadFile#" r_stobject="stFile">
	
    <!--- work out file type --->
    <cfif stFile.typeName eq "dmImage">
        <cfset pos = find(".", stFile.imageFile)>
        <cfset suffix = removeChars(stFile.imageFile, 1, pos)>
    <cfelse>
		<cfset pos = find(".", stFile.filename)>
        <cfset suffix = removeChars(stFile.filename, 1, pos)>
    </cfif>

	<!--- pick a mime type (if required) --->
	<cfswitch expression="#lCase(suffix)#">						

        <cfcase value="gif">
            <cfset mime = "image/gif">
        </cfcase>

        <cfcase value="jpg">
            <cfset mime = "image/jpg">
        </cfcase>

        <cfcase value="jpeg">
            <cfset mime = "image/jpeg">
        </cfcase>

		<cfcase value="pdf">
			<cfset mime = "application/pdf">
		</cfcase>
		
		<cfdefaultcase>
			<cfset mime = "application/unknown">
		</cfdefaultcase>
	
	</cfswitch>
	
	<!--- log download --->
	<cfinvoke component="#application.packagepath#.farcry.stats" method="logEntry">
		<cfinvokeargument name="pageId" value="#url.DownloadFile#"/>
		<cfinvokeargument name="navId" value="#url.DownloadFile#"/>
		<cfinvokeargument name="remoteIP" value="#cgi.REMOTE_ADDR#"/>
		<cfinvokeargument name="sessionId" value="#trim(session.sessionId)#"/>
		<cftry>
			<cfinvokeargument name="browser" value="#trim(cgi.HTTP_USER_AGENT)#"/>
			<cfcatch><cfinvokeargument name="browser" value="Unknown"/></cfcatch>
		</cftry>
		<!--- check is a user is logged in --->
		<cfif request.LoggedIn>
			<cfinvokeargument name="userid" value="#session.dmSec.authentication.userlogin#"/>
		<cfelse>
			<cfinvokeargument name="userid" value="Anonymous"/>		
		</cfif>
	</cfinvoke>
	
	
	<!--- download --->
    <cfif stFile.typeName eq "dmImage">
 		<CFHEADER NAME="content-disposition" VALUE="inline; filename=#stFile.imageFile#">
        <cfcontent type="#mime#" file="#stFile.originalImagePath#/#stFile.imageFile#" deletefile="No" reset="Yes">
    <cfelse>
		<CFHEADER NAME="content-disposition" VALUE="inline; filename=#stFile.filename#">
		<cfcontent type="#mime#" file="#application.defaultFilePath#/#stFile.filename#" deletefile="No" reset="Yes">
    </cfif>
	<cfabort>

<!--- ext file --->
<cfelseif isdefined("url.extFile")>
	
	<!--- work out file type --->
 	<cfset pos = find(".", url.extFile)>
    <cfset suffix = removeChars(url.extFile, 1, pos)>
 

	<!--- pick a mime type (if required) --->
	<cfswitch expression="#lCase(suffix)#">						

        <cfcase value="gif">
            <cfset mime = "image/gif">
        </cfcase>

        <cfcase value="jpg">
            <cfset mime = "image/jpg">
        </cfcase>

        <cfcase value="jpeg">
            <cfset mime = "image/jpeg">
        </cfcase>

		<cfcase value="pdf">
			<cfset mime = "application/pdf">
		</cfcase>
		
		<cfdefaultcase>
			<cfset mime = "application/unknown">
		</cfdefaultcase>
	
	</cfswitch>
	
	<CFHEADER NAME="content-disposition" VALUE="inline; filename=#url.extFile#">
	<cfcontent type="#mime#" file="#url.extFile#" deletefile="No" reset="Yes">
</cfif>

<cfsetting enablecfoutputonly="No">


