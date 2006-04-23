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
		stProperties.teaser = form.teaser;
		stProperties.include = form.include;
		stProperties.displayMethod = form.displayMethod;
		//TODO MUST sort out this date stuff. Can't just keep overwriting datetime created
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	</cfscript>

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmInclude"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfoutput>
		<span class="FormTitle">INCLUDE UPDATE SUCCESSFUL</span><br>
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
	<br>
	<span class="FormTitle">Operation has been cancelled</span>
	
<cfelse> <!--- Show the form --->
	<cfoutput>
	<br>
	<span class="FormTitle">#stObj.title#</span>

	
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	<tr>
  		<td><span class="FormLabel">Title:</span></td>
   	 	<td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	<cfinvoke component="#application.packagepath#.types.dmInclude" method="getIncludes" returnvariable="qGetIncludes"/>
 	<tr>	
		<td><span class="FormLabel">Include:</span></td>
   		<td width="100%" class="FormLabel">
		</cfoutput>
			<cfif qGetIncludes.recordCount>
			<select name="include">
			<cfoutput query="qGetIncludes">
				<option value="#include#" <cfif qGetIncludes.include eq stObj.include>SELECTED</cfif>>#include#</option>
			</cfoutput>
			</select>
			<cfelse>
				NO INCLUDE FILES AVAILABLE
			</cfif>
			<cfoutput>
		</td>
	</tr>
	<nj:listTemplates typename="dmInclude" prefix="display" r_qMethods="qMethods">
	<tr>
		<td nowrap class="FormLabel">Display Method:</td>
		<td width="100%" class="FormLabel">
		<select name="DisplayMethod" size="1">
		</cfoutput>
		<cfoutput query="qMethods">
		<option value="#qMethods.methodname#" <cfif qMethods.methodname eq stObj.displaymethod>SELECTED</cfif>>#qMethods.displayname#</option>
		</cfoutput>
		<cfoutput>
		</select>
		</td>
	</tr>	
	
	<tr>
  		<td valign="top"><span class="FormLabel">Teaser:</span></td>
	   	<td>
			<textarea cols="30" rows="4" name="teaser" class="FormTextArea">#stObj.teaser#</textarea>
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">
		</td>
	</tr>		
	</table>
	
	</form>
	</cfoutput>
</cfif>	