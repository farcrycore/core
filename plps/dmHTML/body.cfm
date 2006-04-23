<!--- 
dmHTML PLP
 - start (start.cfm)
--->
<cfimport taglib="/farcry/tags" prefix="tags">
<cfimport taglib="/farcry/tags/navajo" prefix="farcry">
<cfimport taglib="/fourq/tags/" prefix="q4">

<!--- copy related items to a list for looping --->
<cfset relatedItems = arraytolist(output.aObjectIds)>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">

<cfoutput>
	<script language="JavaScript">
	function PopUpWindow (url, hWind, nWidth, nHeight, nScroll)
	{
		var cToolBar = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=" + nScroll + ",resizable=0,width=" + nWidth + ",height=" + nHeight
  		var popupwin = window.open(url, hWind, cToolBar);
	}
	
	function insert( objectId )
	{
		eWebEditPro.instances["body"].editor.pasteHTML("asdf");
	}
	
	function insertHTML( html )
	{
		/* eWebEditPro.instances["body"].editor.pasteHTML(  ); */
		
		soEditor.insertText(html, '', true,true);
	}
	</script> 
	</cfoutput>
	
	<cfoutput>

	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">BODY</div>
	
	<tags:soEditor_lite 
		   form="editform" 
		   field="body" 
           scriptpath="#application.url.farcry#/siteobjects/soeditor/lite/"
		   new="false" 
		   save="false" 
		   height="80%"
		   html="#output.body#">
	</cfoutput>
	
	<cfoutput><table>
	<tr>
		<td>
			<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">--- insert image ---</option></cfoutput>
				
				<cfloop list="#relatedItems#" index="id">
					<!--- get object details --->
					<q4:contentobjectget objectid="#id#" r_stobject="stImages">
					<!--- check objectype is an image and path exists --->
					<cfif stImages.typeName eq "dmImage">
						<cfif stImages.imagefile neq "">
							<cfoutput><option value="&lt;img src='/images/#stImages.imagefile#' alt='#stImages.alt#'&gt;">#stImages.title#</option></cfoutput>
						</cfif>
					</cfif>
				</cfloop>
		<cfoutput>	</select>
		</td>
		<td>
			<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">--- insert thumbnail ---</option></cfoutput>
				<cfloop list="#relatedItems#" index="id">
					<!--- get object details --->
					<q4:contentobjectget objectid="#id#" r_stobject="stImagesThumbnails">
					<!--- check objectype is an image and path exists --->
					<cfif stImagesThumbnails.typeName eq "dmImage">
						<cfif stImagesThumbnails.thumbnailImagePath neq "">
							<cfoutput><option value="&lt;img src='/images/#stImagesThumbnails.thumbnailImagePath#' alt='#stImagesThumbnails.alt#'&gt;">#stImagesThumbnails.title#</option></cfoutput>
						</cfif>
					</cfif>
				</cfloop>
			<cfoutput></select>
		</td>
		<td>
				<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">--- insert file ---</option></cfoutput>
				<cfloop list="#relatedItems#" index="id">
					<!--- get object details --->
					<q4:contentobjectget objectid="#id#" r_stobject="stFiles">
					<!--- check objectype is an file and path exists --->
					<cfif stFiles.typeName eq "dmFile">
						<cfif stFiles.filename neq "">
							<cfoutput><option value="<a href='#application.url.webroot#/download.cfm?DownloadFile=#id#' target='_blank'>#stFiles.title#</a>">#stFiles.title#</option></cfoutput>
						</cfif>
					</cfif>
				</cfloop>
			<cfoutput></select>
		</td>
	</tr>
	</table></cfoutput>
	
	<cfoutput>
	<cftrace inline="true" text="Form complete">
		<tags:PLPNavigationButtons bDropDown="true" onClick="soEditor.updateFormField();">
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</cfoutput>
	
</cfform>
	
	
<cfelse>

<!---
TODO
sort out general mechanism for dealing with ektron issues...
needs upgradability etc...
ignoring these ektron issues for now 	
	<farcry:njEktron_scrub in="form.body">
    <farcry:njEktron_scrubReverse in="form.body"> --->
 
	<tags:plpUpdateOutput>
</cfif>
