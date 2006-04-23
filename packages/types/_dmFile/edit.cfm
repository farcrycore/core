<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<span class="FormTitle">Object Updated</span>
		
	
	<!--- TODO - error generation try/catch on file upload fields	 --->

	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
	
		//TODO - fix this - with createodbctime etc		
		stProperties.datetimelastupdated = Now();
		stProperties.datetimecreated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	</cfscript>
	<!--- upload the original file 	--->
	<!--- TODO - need to specify proper directory here - and a bit more error checking on function return - assumes success at the moment  --->
	<cfif trim(len(FORM.filename)) NEQ 0>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="filename" destination="#application.defaultFilePath#"> 
		<cfif NOT stReturn.bSuccess>
			<h3>An error has occured - details below</h3>
			<cfdump var="#stReturn#">
			<cfabort>
		<cfelse>	
			<cfscript>
				stProperties.filename = stReturn.ServerFile;
				stProperties.filepath = stReturn.ServerDirectory;
			</cfscript>
		</cfif>	
		
	</cfif>
	

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmFile"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfoutput>
		<span class="FormTitle">FILE UPLOAD SUCCESSFUL</span>
		<input type="button" value="Close" class="normalBttnStyle" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
	</cfoutput>
	
	<nj:TreeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<nj:updateTree objectId="#parentID#" complete="1">

<cfelseif isDefined("FORM.cancel")> <!--- update was cancelled --->
	<br>
	<span class="FormTitle">Operation has been cancelled</span><p></p>
		
<cfelse> <!--- Show the form --->
	
	<cfoutput>
	<br>
	<span class="FormTitle">File Upload Details</span>
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  	 <td><span class="FormLabel">File:</span></td>
   	 <td><input type="file" name="filename" class="FormFileBox"></td>
	</tr>
	<tr>
		<td colspan="2">
		<cfif not len(stObj.filename)>
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
		<nj:getFileIcon filename="#stObj.filename#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
		</td>
		<td>
			<a href="#stObj.filePath#\#stObj.filename#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
	</tr>
<!--- 	<tr>
		<td>
			<nj:getFileIcon filename="#stThisFile.filename#" r_stIcon="fileicon"> 	
			<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
		</td>
		<td>
			#left(stThisFile.title,50)#
		</td>
		<td align="center">
			<cfif len(trim(stThisFile.filename)) NEQ 0>
				<a href="#stThisFile.filePath#\#stThisFile.filename#" target="_blank">
					<img src="#application.url.farcry#/navajo/nimages/preview.gif" border="0">
				</a>
			<cfelse>
					
			</cfif>
		</td>
	</tr>	
 --->	
	<tr>
  	 <td valign="top"><span class="FormLabel">Description:</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="Submit" value="Done!" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
		</td>
	</tr>
		
	</table>
	
	</form>
	</cfoutput>
</cfif>	