<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/download.cfm,v 1.17.2.1 2005/12/19 07:53:41 suspiria Exp $
$Author: suspiria $
$Date: 2005/12/19 07:53:41 $
$Name: milestone_3-0-1 $
$Revision: 1.17.2.1 $

|| DESCRIPTION ||
$Description: Downloads a dmFile object$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">




<cfif isdefined("attributes.downloadfile") and len(attributes.downloadfile)>
	<cfset url.downloadfile = attributes.downloadfile>
</cfif>
<cfif isDefined("url.downloadfile")>
	<cfset url.objectid = url.downloadfile />
</cfif>


<cfif isdefined("attributes.objectid") and len(attributes.objectid)>
	<cfset url.objectid = attributes.objectid>
</cfif>


<cfif isdefined("attributes.fieldname") and len(attributes.fieldname)>
	<cfset url.fieldname = attributes.fieldname>
<cfelse>
	<cfset url.fieldname = "" />
</cfif>

<cfif isdefined("attributes.typename") and len(attributes.typename)>
	<cfset url.typename = attributes.typename>
<cfelse>
	<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq") />
	<cfset url.typename = q4.findType(objectid="#url.objectid#") />	
</cfif>


<!--- should not be able to get object unless authorised. --->
<cfif isDefined("url.objectid") and len(trim(url.objectid))>
	<cfset o = createObject("component", application.types[url.typename].packagePath) />
	
	<cfset stFile = o.getData(objectid="#url.objectid#") />

	<cfif not len(url.fieldname)>
		<!--- Name of the file field has not been sent. We need to loop though the type to determine which field contains the file path --->

		<cfloop list="#structKeyList(application.types[url.typename].stprops)#" index="i">
			<cfif structKeyExists(application.types[url.typename].stprops[i].metadata, "ftType") and application.types[url.typename].stprops[i].metadata.ftType EQ "file" >
				<cfset url.fieldname = i />
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif len(url.fieldname)>
	
	
		<cfset pos = find(".", stFile[url.fieldname])>
        <cfset suffix = removeChars(stFile[url.fieldname], 1, pos)>
	
	
		<!--- pick a mime type (if required) --->
		<cfswitch expression="#lCase(suffix)#">
			<cfcase value="mpg,mpeg">
				<cfset mime = "video/mpeg">
			</cfcase>
			<cfcase value="avi">
				<cfset mime = "video/x-msvideo">
			</cfcase>
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
			<cfinvokeargument name="pageId" value="#url.objectid#"/>
			<cfinvokeargument name="navId" value="#url.objectid#"/>
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
	
	
		<!--- Determine the base filepath --->
		<cfif structKeyExists(application.types[url.typename].stprops[url.fieldname].metadata, "ftSecure") and application.types[url.typename].stprops[url.fieldname].metadata.ftSecure >
			<cfset baseFilepath = application.path.secureFilePath />
		<cfelse>
			<cfset baseFilepath = application.path.defaultFilePath />
		</cfif>
		
		
		<!--- Ensure that the first character of the path in the DB is a  "/" --->
		<cfif left(stFile[url.fieldname],1) NEQ "/">
			<cfset stFile[url.fieldname] = "/#stFile[url.fieldname]#" />
		</cfif>
		<!--- Replace any  "\" with "/" for compatibility with everything --->
		<cfset filepath = replace("#baseFilepath##stFile[url.fieldname]#","\","/","all")>
		<!--- Determine the ACTUAL filename --->
		<cfset fileName = listLast(filepath,"/")>

	
		<!--- download --->

 		<cfheader name="content-disposition" VALUE="attachment; filename=#fileName#">
		<cfheader name="cache-control" value="">
		<cfheader name="pragma" value="">
	    <cftry>
	        <cfcontent type="#mime#" file="#filepath#" deletefile="No" reset="Yes">
		<cfcatch><!--- prevent unnecessary log entries when user cancels download whilst it is in progress ---></cfcatch>
	    </cftry>
	    
		<cfabort>
	</cfif>
	
	
<!--- ext file --->
<!--- TODO: this is legacy and needs to be looked at for 4.0 --->
<cfelseif isdefined("url.extFile") and isDefined("application.config.verity.contentType.extFiles.aProps.uncpath")>

	<!--- get filename --->
	<cfset filename = replace(url.extFile,"\","/","all")>
	<cfset fileName = listLast(filename,"/")>

	<!--- work out file type --->
 	<cfset pos = find(".", url.extFile)>
    <cfset suffix = removeChars(url.extFile, 1, pos)>

	<!--- pick a mime type (if required) --->
	<cfswitch expression="#lCase(suffix)#">
		<cfcase value="mpg,mpeg">
			<cfset mime = "video/mpeg">
		</cfcase>
		<cfcase value="avi">
			<cfset mime = "video/x-msvideo">
		</cfcase>
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

	<!--- download file via unc path specified for external files --->
	<cfheader name="content-disposition" value="attachment; filename=#fileName#" />
	<cfheader name="cache-control" value="">
	<cfheader name="pragma" value="">

    <cftry>
	<cfcontent type="#mime#" file="#application.config.verity.contentType.extFiles.aProps.uncpath#/#fileName#" deletefile="No" reset="Yes">
    <cfcatch><!--- prevent unnecessary log entries when user cancels download whilst it is in progress ---></cfcatch>
    </cftry>
    <cfabort>

</cfif>

<cfsetting enablecfoutputonly="No">