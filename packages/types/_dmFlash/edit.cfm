<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFlash/edit.cfm,v 1.12 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: edit handler$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	
	<cfscript>
		stProperties = structNew();
		stProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.teaser = form.teaser;
		
		stProperties.flashHeight = form.height;
		stProperties.flashWidth = form.width;
		stProperties.flashQuality = form.quality;
		stProperties.flashAlign = form.quality;
		stProperties.flashBgcolor = form.bgcolor;
		stProperties.flashPlay = form.play;
		stProperties.flashLoop = form.loop;
		stProperties.flashMenu = form.menu;
		stProperties.flashVersion = form.flashVersion;
		stProperties.flashParams = form.flashParams;
		stProperties.displayMethod = form.displayMethod;
		//TODO MUST sort out this date stuff. Can't just keep overwriting datetime created
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>
	
	<!--- upload the flash movie --->
	<cfif trim(len(FORM.flashMovie)) NEQ 0>
		<!--- try and delete current file if its there --->
		<cfif len(stobj.flashmovie)>
			 <cftry> 
				<cffile action="DELETE" file="#application.defaultFilePath#\#stObj.flashMovie#">  
				 <cfcatch>
			
				</cfcatch>			
			</cftry> 
		</cfif>
		<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" nameconflict="OVERWRITE" formfield="flashMovie" destination="#application.defaultFilePath#"> 
		<cfif NOT stReturn.bSuccess>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			File type needs to be a flash movie (.swf) <p></p></cfoutput>
			<cfset error=1>
		<cfelse>	
			<cfscript>
				stProperties.flashMovie = stReturn.ServerFile;
			</cfscript>
		</cfif>	
		
	</cfif>
	
	<cfscript>
		// update the OBJECT	
		oType = createobject("component", application.types.dmFlash.typePath);
		oType.setData(stProperties=stProperties);
	</cfscript>
		
	<!--- get parent to update tree --->	
	<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>
		
<cfelse> <!--- Show the form --->
	<cfoutput>
	<br>
	<span class="FormTitle">#stObj.title#</span><p></p>

	
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	<!--- movie title --->
	<tr>
  		<td><span class="FormLabel">Title:</span></td>
   	 	<td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	
	<!--- display method --->
	<nj:listTemplates typename="dmFlash" prefix="display" r_qMethods="qMethods">
	<tr>
		<td nowrap class="FormLabel">Display Method:</td>
		<td width="100%" class="FormLabel">
		<select name="DisplayMethod" size="1">
		</cfoutput>
		<cfif qMethods.recordcount>
			<cfoutput query="qMethods">
			<option value="#qMethods.methodname#" <cfif qMethods.methodname eq stObj.displaymethod>SELECTED</cfif>>#qMethods.displayname#</option>
			</cfoutput>
		<cfelse>
			<cfoutput><option value="none">None</cfoutput>
		</cfif>
		<cfoutput>
		</select>
		</td>
	</tr>
	
	<!--- upload flash movie --->
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>	
  	 <td><span class="FormLabel">File:</span></td>
   	 <td><input type="file" name="flashMovie" class="FormFileBox"></td>
	</tr>
	
	<tr>
		<td colspan="2">
		<cfif not len(stObj.flashMovie)>
			<span class="FormSubHeading">[No file uploaded]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">Uploading a new file will overwrite this file</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">Existing File :</span> 
		</td>
		<nj:getFileIcon filename="#stObj.flashMovie#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.defaultFilePath#\#stObj.flashMovie#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>		
		</cfif>
		<p>&nbsp;</p>
		</td>
	</tr>
	
	<!--- flash movie params --->
	<tr>
  		<td><span class="FormLabel">Height:</span></td>
   	 	<td><input type="text" name="Height" value="#stObj.flashHeight#" size="4"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Width:</span></td>
   	 	<td><input type="text" name="Width" value="#stObj.flashWidth#" size="4"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Flash Version:</span></td>
   	 	<td><input type="text" name="flashVersion" value="#stObj.flashVersion#" size="10"></td>
	</tr>
	<tr>
  		<td valign="top"><span class="FormLabel">Flash Parameters:</span></td>
   	 	<td><textarea cols="30" rows="4" name="flashParams" class="FormTextArea">#stObj.flashParams#</textarea></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Alignment:</span></td>
   	 	<td>
		<select name="align">
			<option value="left" <cfif stObj.flashalign eq "left">selected</cfif>>Left</option>
			<option value="left" <cfif stObj.flashalign eq "center">selected</cfif>>Center</option>
			<option value="right" <cfif stObj.flashalign eq "right">selected</cfif>>Right</option>
			<option value="Top" <cfif stObj.flashalign eq "Top">selected</cfif>>Top</option>
			<option value="Bottom" <cfif stObj.flashalign eq "Bottom">selected</cfif>>Bottom</option>
		</select></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Quality:</span></td>
   	 	<td>
		<select name="quality">
			<option value="low" <cfif stObj.flashQuality eq "low">selected</cfif>>Low</option>
			<option value="medium" <cfif stObj.flashQuality eq "medium">selected</cfif>>Medium</option>
			<option value="high" <cfif stObj.flashQuality eq "high">selected</cfif>>High</option>
			<option value="best" <cfif stObj.flashQuality eq "best">selected</cfif>>Best</option>
			<option value="autoHigh" <cfif stObj.flashQuality eq "autoHigh">selected</cfif>>autoHigh</option>
			<option value="autoLow" <cfif stObj.flashQuality eq "autoLow">selected</cfif>>autoLow</option>
		</select></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Background Colour:</span></td>
   	 	<td><input type="text" name="bgcolor" value="#stObj.flashBgcolor#" size="9" maxlength="7"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Automatic Play:</span></td>
   	 	<td><input type="radio" name="play" value="1" <cfif stObj.flashPlay>checked</cfif>>True <input type="radio" name="play" value="0" <cfif not stObj.flashPlay>checked</cfif>>False </td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Loop:</span></td>
   	 	<td><input type="radio" name="loop" value="1" <cfif stObj.flashLoop>checked</cfif>>True <input type="radio" name="loop" value="0" <cfif not stObj.flashLoop>checked</cfif>>False </td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Show Menu:</span></td>
   	 	<td><input type="radio" name="menu" value="1" <cfif stObj.flashMenu>checked</cfif>>True <input type="radio" name="menu" value="0" <cfif not stObj.flashMenu>checked</cfif>>False </td>
	</tr>
	
	<tr>
  		<td valign="top"><span class="FormLabel">Teaser:</span></td>
	   	<td>
			<textarea cols="30" rows="4" name="teaser" class="FormTextArea">#stObj.teaser#</textarea>
		</td>
	</tr>
	
	<!--- submit buttons --->
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		</td>
	</tr>		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
	</script>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">