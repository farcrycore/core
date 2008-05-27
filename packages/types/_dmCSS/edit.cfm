<cfsetting enablecfoutputonly="yes" />
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmCSS/edit.cfm,v 1.34.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.34.2.1 $

|| DESCRIPTION || 
$Description: CSS Stylesheet reference edit handler$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">

<!--- determine where the edit handler has been called from to provide the right return url --->
<cfparam name="url.ref" default="sitetree" type="string">
<cfif url.ref eq "typeadmin"> 
	<!--- typeadmin redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/content/dmcss.cfm">
<cfelse> 
	<!--- site tree redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#">
</cfif>

<!--- default form elements --->
<cfparam name="form.title" default="">
<cfparam name="form.bThisNodeOnly" default="0">
<cfparam name="form.mediaType" default="">
<cfparam name="form.description" default="">
<cfparam name="form.cssContent" default="">

<!--- local variables --->
<cfparam name="errormessage" default="">
<cfset lMediaTypes = "all,aural,braille,embossed,handheld,print,projection,screen,tty,tv">

<!------------------------------------------------ 
	Form Action
	 - self posting form
------------------------------------------------->
<!--- action: cancel --->
<cfif isDefined("form.cancel")>
	<!--- cancel content item lock --->
	<cfset setlock(locked="false")>
	<cflocation url="#cancelCompleteURL#" addtoken="no">
</cfif>

<cfif isDefined("form.update")>
	<!--- action: update --->
	<cfset stProperties = structNew()>
	<cfset stProperties.objectid = stObj.ObjectID>
	<cfset stProperties.title = form.title>
	<cfset stProperties.label = form.title>
	<cfset stProperties.description = form.description>
	<cfset stProperties.filename = form.css_file_original>
	<cfset stProperties.mediaType = form.mediaType>
	<cfset stProperties.datetimelastupdated = Now()>
	<cfset stProperties.lastupdatedby = session.dmSec.authentication.userlogin>
	<cfset stProperties.bThisNodeOnly = bThisNodeOnly>
		
	<cftry> 
		<!--- check for file to upload --->
		<cfif len(form.css_file_upload)>		
			<cffile action="upload" filefield="css_file_upload" destination="#application.path.project#/www/css/" accept="text/css" nameConflict="Overwrite"> 
			<cfset stProperties.filename = cffile.ServerFile>
		
		<!--- else, update the css content of original file --->
		<cfelseif len(stProperties.filename)>
			<cffile action="write" file="#application.path.project#/www/css/#stProperties.filename#" output="#cssContent#" charset="utf-8">
		</cfif>

		<cfcatch> 
			<!--- if error flow back through the page and display the error message --->
			<cfset errormessage = errormessage & cfcatch.message>
		</cfcatch>
	</cftry>

	<!--- update the OBJECT if no error occured and reloacte--->
	<cfif NOT len(errormessage)>
		<!--- remove content item lock --->
		<cfset setlock(locked="false")>
		<!--- update content item --->
		<cfset setData(stProperties=stProperties)>

		<!--- if not typeadmin edit then refresh JS tree data --->
		<cfif url.ref neq "typeadmin"> 
			<!--- get parent to update site js tree --->
			<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
			<!--- update site js tree --->
			<nj:updateTree objectId="#parentID#">
			<!--- relocate iframes for tree and edit areas using JS --->
			<cfoutput>
			<script type="text/javascript">
			if(parent['sidebar'].frames['sideTree'])
				parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
				parent['content'].location.href = "#cancelCompleteURL#"
			</script>
			</cfoutput>
			<cfabort>
			
		<cfelse>
			<cflocation url="#cancelCompleteURL#" addtoken="no">
		</cfif>

	<cfelse>
		<!--- show error --->
		<cfoutput><p id="fading1" class="fade"><span class="error">#errormessage#</span></p></cfoutput>
	</cfif>

<!--- set default values for form--->
<cfelse> 
	<!--- Lock content item for editing--->
	<cfset setlock(locked="true")>

	<cfset title = stObj.title>
	<cfset bThisNodeOnly = stObj.bThisNodeOnly>
	<cfset mediaType = stObj.mediaType>
	<cfset description = stObj.description>
	<cfif stObj.filename NEQ "">
		<cftry>
				
			<cffile action="read" file="#application.path.project#/www/css/#stObj.filename#" variable="cssContent">
			<cfcatch type="any">
				<cfset readErrormessage = cfcatch.message>
				<cfoutput><p id="fading1" class="fade"><span class="error">#readErrormessage#</span></p></cfoutput>
			</cfcatch>
		</cftry>
	</cfif>
</cfif>

<!------------------------------------------------ 
	Form Display 
------------------------------------------------->
<!--- output form UI --->
<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" enctype="multipart/form-data" name="fileForm" method="post">
	<fieldset>
<h3>#application.rb.getResource("generalInfo")#: <span class="highlight">#stObj.title#</span></h3>
		<label for="title"><b>#application.rb.getResource("titleLabel")#</b>
			<input type="text" name="title" id="title" value="#title#" maxlength="255" size="45" /><br />
		</label>

		<widgets:fileUpload fileFieldPrefix="css" fieldLabel="Upload CSS:" uploadType="file" fieldValue="#stObj.filename#" previewURL="/css/" bShowPreview="0">

		<label for="cssContent"><b>CSS Content:</b>
			<textarea name="cssContent" id="cssContent" cols="40" rows="10">#cssContent#</textarea><br />		
		</label>
		<label for="bThisNodeOnly"><b>Use CSS in this folder only:</b>
			<input type="checkbox" name="bThisNodeOnly" value="1"<cfif bThisNodeOnly EQ 1> checked="checked"</cfif> /><br />
		</label>

		<label for="mediaType"><b>Media Type:</b>
			<select name="mediaType" id="mediaType" multiple="true"><cfloop index="iMedia" list="#lMediaTypes#">
				<option value="#iMedia#"<cfif ListFindNoCase(mediaType,iMedia)> selected="selected"</cfif>>#iMedia#</option></cfloop>
			</select><br />
		</label>

		<label for="description"><b>Description:</b>
			<textarea name="description" id="description" cols="40">#description#</textarea><br />
		</label>
	</fieldset>
	<div class="f-submit-wrap">
	<input type="submit" name="update" value="OK" class="f-submit" />
	<input type="submit" name="cancel" value="Cancel" class="f-submit" />
	</div>
</form>
</cfoutput>
<cfsetting enablecfoutputonly="no" />