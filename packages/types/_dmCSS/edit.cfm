<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
		stProperties.filename = form.filename;
					
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	</cfscript>
	
	<!--- check for file to upload --->
	<cfif trim(len(form.cssFile)) NEQ 0>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="cssFile" destination="#application.RootPHY#/www/css/" accept="text/css" nameConflict="Overwrite"> 
		
		<!--- check for error --->
		<cfif not stReturn.bSuccess>
			<div><span class="title">Error!</span><p></p>
			<cfoutput>#stReturn.message#<p></p>
			<span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#objectid#">Return to edit form</a></cfoutput></div>
			<cfabort>
		</cfif>
		<cfscript>
			stProperties.filename = stReturn.ServerFile;
		</cfscript>
	<cfelse>
		<cfif isdefined("cssContent")>
			<!--- save content as file --->
			<cffile 
			  action = "write" 
			  file = "#application.RootPHY#/www/css/#stProperties.filename#"
			  output = "#cssContent#"> 
		</cfif>
	</cfif>
	
	


	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmCSS"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfoutput>
		<span class="FormTitle">CSS UPDATE SUCCESSFUL</span>
		<input type="button" value="Close" class="normalBttnStyle" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
	</cfoutput>
	
	<nj:TreeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<nj:updateTree objectId="#parentID#" complete="0">

<cfelseif isDefined("FORM.cancel")> <!--- update was cancelled --->
	<span class="FormTitle">Operation has been cancelled</span><p></p>
	<input type="button" value="Close" class="normalBttnStyle" onClick="location.href='edittabOverview.cfm?objectid=<cfoutput>#stObj.ObjectID#</cfoutput>'" >
<cfelse> <!--- Show the form --->


	<cfoutput>
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table border="0">
	<tr>
		<td colspan="2" align="center">
			<span class="FormTitle">#stObj.title#</span>
		</td>
	</tr>
	
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<!--- don't show filename textbox, just pass as hidden field --->
		<input type="hidden" name="filename" value="#stObj.filename#">
		<!--- <tr>	
		 <td><span class="FormLabel">CSS File:</span></td>
		 <td><input type="text" name="filename" value="#stObj.filename#" class="FormTextBox"></td>
		</tr> --->
	<tr>
		<td ><span class="FormLabel">Upload File</span></td>
		<td>
			<input type="file" name="cssFile" class="FormFileBox">&nbsp;&nbsp;
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
  	 <td valign="top"><span class="FormLabel">Description:</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	</tr>

	<cfif stObj.filename neq "" and FileExists("#application.RootPHY#/www/css/#stObj.filename#")>
		<cffile 
		  action = "read" 
		  file = "#application.RootPHY#/www/css/#stObj.filename#"
		  variable = "css">
		<tr>
			<td valign="top"><span class="FormLabel">Style Sheet</span></td>
			<td><textarea cols="30" rows="20" name="cssContent" class="FormTextArea">#css#</textarea></td>
		</tr>
	</cfif>

	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="submit" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
		</td>
	</tr>		
	</table>
	
	</form>
	</cfoutput>
</cfif>	