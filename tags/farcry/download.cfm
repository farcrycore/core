<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
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
	<!--- call onMissingTemplate if downloadObject not found --->
	<cfset oApp=createObject("component","farcry.projects.#application.applicationname#.www.application")>
	<cfset oApp.onMissingTemplate(thepage=cgi.QUERY_STRING)>
</cfif>

<!--- get content item --->
<cfset oType = createObject("component", application.types[attributes.typename].packagePath) />
<cfset stFile = oType.getData(objectid=attributes.objectid) />


<!--- todo: should be checking standard view permission --->

<!--- check status of file --->
<cfif structKeyExists(stFile, "status")>
	<cfif NOT listFind(request.mode.lvalidstatus, stFile.status)>
		<cfif request.mode.bAdmin>
			<!--- SET DRAFT MODE ONLY FOR THIS REQUEST. --->
			<cfset request.mode.showdraft = 1 />
			<!---<cfset session.dmSec.Authentication.showdraft = request.mode.showdraft />--->
			<cfset request.mode.lValidStatus = "draft,pending,approved" />
		<cfelse>
			<cfthrow type="core.tags.farcry.download" message="File not available." detail="You are not authorised to view this file." />
		</cfif>		
	</cfif>
</cfif>

<!--- determine the fieldname --->
<cfif len(attributes.fieldname)>
	<cfset stLocation = oType.getFileLocation(stObject=stFile,fieldname=attributes.fieldname) />
<cfelse>
	<cfset stLocation = oType.getFileLocation(stObject=stFile) />
</cfif>


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
	<cfif application.security.isLoggedIn()>
		<cfinvokeargument name="userid" value="#application.security.getCurrentUserID()#"/>
	<cfelse>
		<cfinvokeargument name="userid" value="Anonymous"/>
	</cfif>
</cfinvoke>


<!--- What to do if the returned struct is empty (i.e. user doesn't have permission) --->
<cfif structisempty(stLocation) or structkeyexists(stLocation,"message")>
	
	<!--- Do nothing --->
	
<cfelse>

	<!------------------------------------
	DOWNLOAD FILE
	------------------------------------->
	<cfif stLocation.type eq "stream">
		<cfheader name="content-disposition" VALUE='attachment; filename="#stLocation.fileName#"' />
		<cfheader name="cache-control" value="" />
		<cfheader name="pragma" value="" />
		<cftry>
			<cfif StructKeyExists(stLocation,"mimeType")> <!--- mimetype could be unknown - happend with .dot --->
				<cfcontent type="#stLocation.mimeType#" file="#stLocation.path#" deletefile="No" reset="Yes" />
			<cfelse>
				<cfcontent file="#stLocation.path#" deletefile="No" reset="Yes" />
			</cfif>
		<cfcatch><!--- prevent unnecessary log entries when user cancels download whilst it is in progress ---></cfcatch>
		</cftry>
	<cfelse>
		<cflocation url="#stLocation.path#" addtoken="false" />
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false" />