<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Tag for File Download --->
<!--- @@Description: Locates the relevant file and delivers to the user. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<!--- run once only --->
<cfif thistag.ExecutionMode eq "end">
	<cfexit method="exittag" />
</cfif>

<!--------------------------------------
accommodate legacy implementations 
--------------------------------------->
<cfif isdefined("url.downloadfile") and len(url.downloadfile)>
	<cfset url.objectid = url.downloadfile />
</cfif>

<cfif isDefined("url.objectid")>
	<cfset attributes.objectid = url.objectid />
</cfif>

<cfif isdefined("url.fieldname") and len(url.fieldname)>
	<cfset attributes.fieldname = url.fieldname />
</cfif>

<!--- environment variables --->
<cfparam name="request.mode.lvalidstatus" default="approved" type="string" />

<!--- required attributes --->
<cfparam name="attributes.objectid" type="uuid" />

<!--- optional attributes --->
<cfparam name="attributes.fieldname" type="string" default="" />
<cfparam name="attributes.typename" type="string" default="" />

<!--- determine typename if its not supplied --->
<cfif not len(attributes.typename)>
	<cfset attributes.typename = application.coapi.coapiUtilities.findType(objectid=attributes.objectid) />
</cfif>
<cfif not len(attributes.typename)>
	<cfthrow type="core.tags.farcry.download" message="File not found." detail="Typename for the file reference could not be determined." />
</cfif>

<!--- get content item --->
<cfset oType = createObject("component", application.types[attributes.typename].packagePath) />
<cfset stFile = oType.getData(objectid=attributes.objectid) />


<!--- todo: should be checking standard view permission --->

<!--- check status of file --->
<cfif structKeyExists(stFile, "status")>
	<cfif NOT listFind(request.mode.lvalidstatus, stFile.status)>
		<cfthrow type="core.tags.farcry.download" message="File not available." detail="You are not authorised to view this file." />
	</cfif>
</cfif>

<!--- determine the fieldname --->
<cfif NOT len(attributes.fieldname)>
	<!--- Name of the file field has not been sent. We need to loop though the type to determine which field contains the file path --->
	<cfloop list="#structKeyList(application.types[attributes.typename].stprops)#" index="i">
		<cfif structKeyExists(application.types[attributes.typename].stprops[i].metadata, "ftType") AND application.types[attributes.typename].stprops[i].metadata.ftType EQ "file">
			<cfset attributes.fieldname = i />
		</cfif>
	</cfloop>
</cfif>
<cfif NOT len(attributes.fieldname)>
	<cfthrow type="core.tags.farcry.download" message="File not found." detail="Fieldname for the file reference could not be determined." />
</cfif>
<cfif NOT len(stfile[attributes.fieldname])>
	<cfthrow type="core.tags.farcry.download" message="File not found." detail="Fieldname for the file reference was empty." />
</cfif>


<!--- determine the base filepath --->
<cfif structKeyExists(application.types[attributes.typename].stprops[attributes.fieldname].metadata, "ftSecure") AND application.types[attributes.typename].stprops[attributes.fieldname].metadata.ftSecure>
	<cfset baseFilepath = application.path.secureFilePath />
<cfelse>
	<cfset baseFilepath = application.path.defaultFilePath />
</cfif>

<!--- Ensure that the first character of the path in the DB is a  "/" --->
<cfif left(stFile[attributes.fieldname],1) NEQ "/">
	<cfset stFile[attributes.fieldname] = "/#stFile[attributes.fieldname]#" />
</cfif>
<!--- Replace any  "\" with "/" for compatibility with everything --->
<cfset filepath = replace("#baseFilepath##stFile[attributes.fieldname]#","\","/","all")>
<!--- Determine the ACTUAL filename --->
<cfset fileName = listLast(filepath,"/")>

<!--- check file exists --->
<cfif NOT fileExists(filepath)>
	<cfthrow type="core.tags.farcry.download" message="File not found." detail="The physical file is missing." />
</cfif>

<!--- determine mime type --->
<cfset mimeType=getPageContext().getServletContext().getMimeType(filePath) />


<!--- todo: determine config for logging options; stats is being deprecated --->
<!--- log download --->
<cfinvoke component="#application.packagepath#.farcry.stats" method="logEntry">
	<cfinvokeargument name="pageId" value="#attributes.objectid#"/>
	<cfinvokeargument name="navId" value="#attributes.objectid#"/>
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
	
	
<!------------------------------------
DOWNLOAD FILE
------------------------------------->
<cfheader name="content-disposition" VALUE='attachment; filename="#fileName#"' />
<cfheader name="cache-control" value="" />
<cfheader name="pragma" value="" />
<cftry>
<cfcontent type="#mimeType#" file="#filepath#" deletefile="No" reset="Yes" />
<cfcatch><!--- prevent unnecessary log entries when user cancels download whilst it is in progress ---></cfcatch>
</cftry>




<cfsetting enablecfoutputonly="false" />