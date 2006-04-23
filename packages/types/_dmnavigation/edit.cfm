<cfimport taglib="/fourq/tags" prefix="q4"> 
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>



<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<span class="FormTitle">Object Updated</span>
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.externalLink = form.externalLink;
		stProperties.target = form.target;
		stProperties.lNavIDAlias = form.lNavIDAlias;
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	</cfscript>

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmNavigation"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfquery datasource="#application.dsn#">
		UPDATE nested_tree_objects 
		SET objectName = '#FORM.title#'
		WHERE objectID = '#stObj.ObjectID#'
	</cfquery>
	
	
	<cfoutput>
		<input type="button" value="Close" class="normalBttnStyle" onClick="window.close();" >
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
	<span class="FormTitle">Operation has been cancelled</span>
	<br>
		<input type="button" value="Close" class="normalBttnStyle" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
	
<cfelse> <!--- Show the form --->
	<cfform action="#CGI.script_name#?#CGI.query_string#" name="editform">
	<cfoutput>
	<br>
		<table class="FormTable">
			<tr>
				<td colspan="2" align="center"><span class="FormSubHeading">Navigation Node details</span></td>
			</tr>
			<tr>
				<td><span class="FormLabel">Title:</span></td>
				<td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
			</tr>
			<tr>
				<td><span class="FormLabel">External Link:</td>
				<td><input type="Text" name="externalLink" value="#stObj.externalLink#" class="FormTextBox"></td>
			</tr>
			<tr>
				<td nowrap valign="top"><span class="FormLabel">Target:</span></td>
				<td nowrap width="100%">
					<select name="target"onchange="form.target.value=this.options[this.selectedIndex].value">
						<option value="">By Name
						<option value="_blank" >New Popup Window
						<option value="" selected>Same Window
					</select><br>
					<input type="text" name="target" value="#stObj.target#"  onKeydown="form.starget.selectedIndex=0" class="FormTextBox">
				</td>
			</tr>
			<tr valign="top">
				<td nowrap><span class="FormLabel">Nav Aliases:</span></td>
				<td nowrap><input type="text" name="lNavIDAlias" value="#stObj.lNavIDAlias#" class="FormTextBox"></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
					<input type="button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
					
				</td>
			</tr>
		</table>
	</cfoutput>
	</cfform>
</cfif>

