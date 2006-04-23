<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/files.cfm,v 1.2 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmEvent Edit PLP - Adds files as associated objects.$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfoutput>
<script>
var isIE=document.all?true:false;
var layers = isIE?document.all.tags("DIV"):null;
selectedDiv = "fileform";
function toggleForm(selectedDiv,display)
{
	el = document.getElementById(selectedDiv);
	el.style.display=display;
	el = document.getElementById('newfile');
	if (display == 'inline')			
		el.style.display='none';
	else	
		el.style.display='inline';
}

function hideAll()
{
	for(var i=0;i<layers.length;i++){
		if (layers[i].id != 'PLPMoveButtons')
			layers[i].style.display='none';
	}	
}
  

function removeUploadBtn()
{
	el = document.getElementById('newfile');
	el.style.display='none';
}
</script></cfoutput>

<cfscript>
	/*this page has a number of different form postings. establishing what action to take
	based on the form submitted*/ 
	if (isDefined("form.newObject") OR isDefined("form.editObject"))
		action = 'update';
	else if (isDefined("form.deleteObject"))
		action = 'deleteObject';
	else
		action = 'normal';
</cfscript>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfswitch expression="#action#">
	<cfcase value="update">
		
		<cfscript>
			stProperties = structNew();
			if (isDefined("form.editObject"))
			{
				stProperties.objectID = form.objectID;
			}	
			else  
			{	
				stProperties.objectID = createUUID();
				stProperties.datetimecreated = Now();
				arrayAppend(output.aObjectIds,stProperties.objectID);
			}	
			stProperties.title = form.filetitle;
			stProperties.label = form.filetitle;
			stProperties.createdby = session.dmSec.authentication.userlogin;
			stProperties.description = form.description;
			stProperties.datetimelastupdated = Now();
			stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		</cfscript>
		
		<!--- upload the original file 	--->
		<cfif trim(len(FORM.filename)) NEQ 0 AND form.filename NEQ form.filename_old>
			<!--- upload new file (if accept list not specified in config, accept everything) --->
			<cfif len(application.config.file.filetype)>
				<cfinvoke 
					component="#application.packagepath#.farcry.form" 
					method="uploadFile" 
					destination="#application.defaultFilePath#" 
					returnvariable="stReturn" 
					formfield="filename" 
					accept="#application.config.file.filetype#" /> 
			<cfelse>
				<cfinvoke 
					component="#application.packagepath#.farcry.form" 
					method="uploadFile" 
					destination="#application.defaultFilePath#" 
					returnvariable="stReturn" 
					formfield="filename" /> 
			</cfif>
			
			<cfif NOT stReturn.bSuccess>
				<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
				File types that are accepted: #application.config.file.filetype# <p></p></cfoutput>
				<cfset error=1>
			<cfelse>
				<!--- delete old file --->
				<cftry>
					<cffile action="delete" file="#application.defaultFilePath#/#form.filename_old#">
					<cfcatch type="any"></cfcatch>
				</cftry>	
				<cfscript>
					stProperties.filename = stReturn.ServerFile;
					stProperties.filepath = stReturn.ServerDirectory;
					//test for this array existance
				</cfscript>
			</cfif>
		</cfif>
		
		<cfscript>
			typeName = "dmFile";
		</cfscript>
		<!--- if form.editfile exists - then an existing object is being edited - else must create new object --->
		
		<cfif isDefined("form.editObject")>
			<q4:contentobjectdata typename="#application.packagepath#.types.#typeName#" stProperties="#stProperties#" objectid="#stProperties.objectID#">
		<cfelse>
			<q4:contentobjectcreate typename="#application.packagepath#.types.#typeName#" stproperties="#stProperties#" r_objectid="NewObjID">
		</cfif>
	</cfcase>

	<cfcase value="deleteObject">
		<cfif isDefined("form.objectID")>
			<!--- delete them from the database --->
			<nj:deleteObjects lObjectIDs="#form.objectID#" typename="dmFile" rMsg="msg">
			<cfloop list="#form.objectID#" index="objectID">
				<cfoutput>
				<cfloop index="i" from="#arrayLen(output.aObjectIds)#" to="1" step="-1">
					<cfif output.aObjectIds[i] is objectId>
						<cfset ArrayDeleteAt(output.aObjectIds, i )>
					</cfif>
				</cfloop> 
				</cfoutput>
			</cfloop>
		<cfelse>
			<cfset msg = "No objects were selected for deletion">	
		</cfif>	
	</cfcase>
	<cfdefaultcase>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>

<cfif isDefined("msg")>
	<cfoutput>#msg#</cfoutput>
</cfif>

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">Files</div></cfoutput>

<cfif (StructKeyExists(output, "aObjectIDs"))>
	<cfset aFileArray = arrayNew(1)>
	<cfloop from="1" to="#arrayLen(output.aObjectIds)#" index="i">
		<!--- get the objectType --->
		<cfinvoke component="farcry.fourq.fourq" returnvariable="typename" method="findType" objectID="#output.aObjectIds[i]#">
		<cfif typename IS "dmFile">
			<cfscript>
				arrayAppend(aFileArray,output.aObjectIds[i]);
			</cfscript>
		</cfif>
	</cfloop>
	<cfif arrayLen(aFileArray) GT 0>
	<cfoutput>
	<form action="" method="post">
	<table class="borderTable" >
	<tr>
		<td colspan="5" align="center"><strong>Existing Files</strong></td> 
	</tr>
	<tr>
		<td>&nbsp;
			
		</td>
		<td align="center"><span class="FormLabel">Title</span></td>
		<td align="center"><span class="FormLabel">Preview</span></td>
		<td align="center"><span class="FormLabel">Edit</span></td>
		<td align="center"><span class="FormLabel">Delete</span></td>
	</tr></cfoutput>
	<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
		<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
		<cfoutput>
		<tr>
			<td>
				<nj:getFileIcon filename="#stThisFile.filename#" r_stIcon="fileicon"> 	
				<img src="#application.url.farcry#/images/treeImages/#fileicon#">
			</td>
			<td>
				#left(stThisFile.title,50)#
			</td>
			<td align="center">
				<cfif len(trim(stThisFile.filename)) NEQ 0>
				<a href="#stThisFile.filePath#\#stThisFile.filename#" target="_blank">
					<img src="#application.url.farcry#/images/treeImages/preview.gif" border="0">
				</a>
				<cfelse>
					<span class="FormLabel">[No file uploaded]</span>	
				</cfif>
			</td>

			<td align="center">
				<a href="javascript:void(0);" onClick="hideAll();toggleForm('#i#_edit','inline');">
					<img src="#application.url.farcry#/images/treeImages/edit.gif" border="0">
				</a>
			</td>
			<td align="center">
				<input type="checkbox" name="objectID" value="#stThisFile.objectID#">
			</td>
		</tr></cfoutput>
	</cfloop>
	<cfoutput>
	<tr>
		<td colspan="4">&nbsp;</td>
		<td><input name="deleteObject" type="submit" class="normalbttnstyle" value="delete"></td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<cfelse>
	<cfoutput>
		<table>
			<tr>
				<td><span class="FormLabel">No files have been added to this object</span></td>
			</tr>
		</table>
	</cfoutput>	
	</cfif>
</cfif>

<cfoutput>
<div id="newfile" style="display:inline;">
<p>
<input type="button" class="normalbttnstyle" onClick="toggleForm('fileform','inline');" value="Upload New File">
</p>
</div></cfoutput>

<!--- Output the file edit divs --->
<cfif arrayLen(aFileArray) GT 0>
<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
	<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
	<cfoutput>
	<div id="#i#_edit" style="display:none;">
	<form action="" method="post" enctype="multipart/form-data" name="editFileForm_#i#">
	<span class="FormTitle">Edit File</span>
	<table>
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="filetitle" value="#stThisFile.title#" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  	 <td valign="top" ><span class="FormLabel">File:</span> </td>
   	 <td>
	 	<input type="file" name="filename" claass="FormFileBox">
		<input type="hidden" name="filename_old" value="#stThisFile.filename#">
		<cfif len(stThisFile.filename) NEQ 0>
			<br>[file exists]
		</cfif>
	 </td>
	</tr>
	
	<tr>
  	 <td valign="top"><span class="FormLabel">Description:</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stThisFile.description#</textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="hidden" name="objectID" value="#stThisFile.objectID#">
			<input type="Submit" name="editObject" value="Upload File" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="toggleForm('#i#_edit','none')"; >
		</td>
	</tr>
		
	</table>
	<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("editFileForm_<cfoutput>#i#</cfoutput>");
		objForm.filetitle.validateNotNull("Please enter a title");
			//-->
		</SCRIPT>
	</form>	
</div></cfoutput>
	</cfloop>
</cfif>

<!--- Upload new file DIV --->
<cfoutput><div id="fileform" style="display:none">
<span class="FormTitle">Upload File</span>
	
<form action="" method="post" enctype="multipart/form-data" name="fileForm">
	
	<table border="0">
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="filetitle" value="" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  		<td><span class="FormLabel">File: </span></td>
	  	<td>
	 		<input type="file" name="filename" class="FormFileBox">
			<input type="hidden" name="filename_old" value="">
		</td>
	</tr>
	
	<tr>
  		<td valign="top"><span class="FormLabel">Description:</span></td>
   	 	<td><textarea cols="30" rows="4" name="description" class="FormTextArea"></textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="newObject" value="Upload File" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="toggleForm('fileform','none')"; >
		</td>
	</tr>
</table>
	<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm2 = new qForm("fileForm");
		objForm2.filetitle.validateNotNull("Please enter a title");
		objForm2.filename.validateNotNull("Please enter a file");
			//-->
		</SCRIPT>
	</form>	
</div>
<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform"></cfoutput>
	<tags:plpNavigationButtons>
<cfoutput></form>
</div>

</cfoutput>
<cfelse>	

	
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">