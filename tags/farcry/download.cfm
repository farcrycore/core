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
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

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

<cfif isDefined("url.typename")>
	<cfset attributes.typename = url.typename />
</cfif>

<cfif isdefined("url.fieldname") and len(url.fieldname)>
	<cfset attributes.fieldname = url.fieldname />
</cfif>


<cfif isDefined("url.disp")>
	<cfset attributes.disp = url.disp />
</cfif>
<!--- environment variables --->
<cfparam name="request.mode.lvalidstatus" default="approved" type="string" />

<!--- required attributes --->
<cfif not structkeyexists(attributes,"objectid") or not isvalid("uuid",attributes.objectid)>
	<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object not specfied")) />
	<cfexit method="exittag" />
</cfif>

<!--- optional attributes --->
<cfparam name="attributes.fieldname" type="string" default="" />
<cfparam name="attributes.typename" type="string" default="" />
<cfparam name="attributes.disp" type="string" default="attachment" />
<cfparam name="attributes.loginpath" default="#application.fapi.getLink(href=application.url.publiclogin,urlParameters='returnUrl='&application.fc.lib.esapi.encodeForURL(cgi.script_name&'?'&cgi.query_string))#" type="string">

<!--- determine typename if its not supplied --->
<cfif not len(attributes.typename)>
	<cfset attributes.typename = application.coapi.coapiUtilities.findType(objectid=attributes.objectid) />
</cfif>
<cfif not len(attributes.typename)>
	<!--- call onMissingTemplate if downloadObject not found --->
	<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object type not specfied")) />
	<cfexit method="exittag" />
</cfif>

<!--- get content item --->
<cftry>
	<cfset oType = application.fapi.getContentType(attributes.typename) />
	<cfcatch>
		<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object does not exist")) />
		<cfexit method="exittag" />
	</cfcatch>
</cftry>
<cfset stFile = oType.getData(objectid=attributes.objectid) />

<!--- check status and permissions on file --->
<cfif not structkeyexists(stFile,"objectid") or (structkeyexists(stFile,"bDefaultObject") and stFile.bDefaultObject)>
	<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object does not exist")) />
	<cfexit method="exittag" />
<cfelseif structKeyExists(stFile, "status") and NOT listFind(request.mode.lvalidstatus, stFile.status)>
	<cfif request.mode.bAdmin>
		<!--- SET DRAFT MODE ONLY FOR THIS REQUEST. --->
		<cfset request.mode.showdraft = 1 />
		<cfset request.mode.lValidStatus = "draft,pending,approved" />
	<cfelseif len(attributes.loginpath)>
		<skin:location url="#attributes.loginpath#" urlParameters="showdraft=1&error=draft" />
	<cfelse>
		<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("You are not authorised to view this file")) />
		<cfexit method="exittag" />
	</cfif>
</cfif>

<!--- check view permission --->
<sec:CheckPermission objectid="#stFile.objectid#" type="#stFile.typename#" permission="View" result="filepermission" />
<cfif not filepermission>
	<cfif application.security.isLoggedIn() or not len(attributes.loginpath)>
		<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("You are not authorised to view this file")) />
		<cfexit method="exittag" />
	<cfelse>
		<skin:location url="#attributes.loginpath#" urlParameters="showdraft=1&error=draft" />
	</cfif>
</cfif>

<!--- determine the fieldname --->
<cfif len(attributes.fieldname)>
	<!--- check fieldname exists --->
	<cfset stProp = application.fapi.getPropertyMetadata(typename=stFile.typename, property=attributes.fieldname, default="")>
	<cfif NOT isStruct(stProp) OR structIsEmpty(stProp)>
		<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object property does not exist")) />
		<cfexit method="exittag" />
	<cfelse>
		<cfset stLocation = oType.getFileLocation(stObject=stFile,fieldname=attributes.fieldname) />
	</cfif>
<cfelse>
	<cfset stLocation = oType.getFileLocation(stObject=stFile) />
</cfif>


<!--- What to do if the returned struct is empty (i.e. user doesn't have permission) --->
<cfif structisempty(stLocation) or stLocation.method eq "none">
	
	<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error(stLocation.error)) />
	<cfexit method="exittag" />
	
<cfelse>
	
	<!------------------------------------
	DOWNLOAD FILE
	------------------------------------->
	<cfif stLocation.method eq "stream">
		<cfheader name="content-disposition" VALUE='#attributes.disp#; filename="#listlast(stLocation.path,'/')#"' />
		<cfheader name="cache-control" value="" />
		<cfheader name="pragma" value="" />
		<cftry>
			<cfif StructKeyExists(stLocation,"mimetype")> <!--- mimetype could be unknown - happend with .dot --->
				<cfcontent type="#stLocation.mimetype#" file="#stLocation.path#" deletefile="No" reset="Yes" />
			<cfelse>
				<cfcontent file="#stLocation.path#" deletefile="No" reset="Yes" />
			</cfif>
			
			<cfcatch><!--- prevent unnecessary log entries when user cancels download whilst it is in progress ---></cfcatch>
		</cftry>
	<cfelseif stLocation.method eq "redirect">
		<cflocation url="#urldecode(stLocation.path)#" addtoken="false" />
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false" />