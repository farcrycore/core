<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/start.cfm,v 1.7 2003/09/09 09:23:14 paul Exp $
$Author: paul $
$Date: 2003/09/09 09:23:14 $
$Name: b201 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: dmHTML PLP - Start Step $
$TODO: clean up formatting -- test in Mozilla 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>
<tags:plpNavigationMove>

<cfif NOT thisstep.isComplete>
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table width="400" border="0" cellspacing="0" cellpadding="5">
	<tr>
		<td nowrap class="FormLabel">Title:</td>
		<td width="100%"><input type="text" name="title" value="#output.Title#" maxlength="255" class="FormTextBox"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">Keywords:</td>
		<td width="100%"><input type="text" name="metakeywords" value="#output.metakeywords#" maxlength="255"  class="FormTextBox"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel" valign="top">Extended Metadata
		<a href="javascript:void(0);" id="yesLink" onClick="document.getElementById('noLink').style.display='inline';this.style.display='none';document.getElementById('metadatacell').style.display='none';" style="display:<cfif len(trim(output.extendedmetadata))>inline<cfelse>none</cfif>;"><img src="#application.url.farcry#/images/yes.gif" border="0" alt="Extended Metadata"></a>	
		<a href="javascript:void(0);" id="noLink" onClick="this.style.display='none';document.getElementById('yesLink').style.display='inline';document.getElementById('metadatacell').style.display='inline';" style="display:<cfif NOT len(trim(output.extendedmetadata))>inline<cfelse>none</cfif>;"><img src="#application.url.farcry#/images/no.gif" border="0" alt="No extended metadata"></a>
		</td>
		<td id="metadatacell" style="display:<cfif len(trim(output.extendedmetadata))>inline<cfelse>none</cfif>;" width="100%"><textarea name="extendedmetadata" rows="10" cols="50" class="FormTextBox" wrap="off">#output.extendedmetadata#</textarea><br>
* typically this will be inserted unaltered into the HEAD section of your templates</td>
	</tr>
	</cfoutput>
	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmHTML" prefix="displaypage" r_qMethods="qMethods">
	<cfoutput>
	<tr>
		<td nowrap class="FormLabel">Display Method:</td>
		<td width="100%" class="FormLabel">
		<select name="DisplayMethod" size="1">
		</cfoutput>
		<cfoutput query="qMethods">
		<option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displaymethod>SELECTED</cfif>>#qMethods.displayname#</option>
		</cfoutput>
		<cfoutput>
		</select>
		</td>
	</tr>
	</table>
	</div>
	</cfoutput>	
	
<!---  display commentlog for this object  --->
	<div class="FormTableClear">
	<display:OpenLayer width="100%" title="Comment Log" isClosed="Yes" border="no">
		<cfif len(output.CommentLog)>
		<cfoutput>
		<textarea rows="10" style="width: 100%;">#output.CommentLog#</textarea>
		</cfoutput>
		<cfelse>
		<cfoutput>
		There are no comments available.
		</cfoutput>
		</cfif>
	</display:OpenLayer>
	</div>
	
	<cfif len(output.versionID)>
	<cfinvoke  component="#application.packagepath#.farcry.versioning" method="getArchives" returnvariable="qGetArchives">
		<cfinvokeargument name="objectID" value="#output.versionID#"/>
	</cfinvoke>		
	<!--- display past archived versions of this object --->
	<div class="FormTableClear">
	<display:OpenLayer width="100%" title="Archived Versions" isClosed="Yes" border="no">
		
		<cfif NOT qGetArchives.recordCount>
			<cfoutput>No records returned</cfoutput>
		<cfelse>
			<table width="100%" border="0" cellspacing="1" bgcolor="##999999">
	        <tr> 
    	      <td class="rowsHeader"> View </td>
	          <td class="rowsHeader"> Label </td>
    	      <td class="rowsHeader"> Archive Date </td>
	          <td class="rowsHeader"> By </td>
    	    </tr>	
			<tr>
			<cfoutput query="qGetArchives" > 
			<cfscript>
				previewURL = "#application.url.farcry#/navajo/displayArchive.cfm?objectID=#qGetArchives.objectID#";
			</cfscript>
        	  <tr> 
            	<td class="rows" align="center"> 
        	      <a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/images/treeImages/preview.gif" border="0"></a> 
            	</td>
	            <td class="rows"> 
		             <a href="#previewURL#">#label#</a>
				</td>
            	<td class="rows"> 
              		#dateFormat(dateTimeCreated,"dd-mmm-yyyy")#
				</td>
            	<td class="rows"> 
              		#lastUpdatedBy# 
			 	</td>
          	</tr>
	        </cfoutput>
			</table>
		</cfif>

	
	</display:OpenLayer>
	</div>
	</cfif>
	<cfoutput>
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	//bring focust to title
	document.editform.title.focus();
	objForm = new qForm("editform");
	objForm.title.validateNotNull("Please enter a title");
		//-->
	</SCRIPT>
	</form>
	</cfoutput>
<cfelse>
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">