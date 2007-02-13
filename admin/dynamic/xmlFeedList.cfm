<cfsetting enablecfoutputonly="No">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/display/" prefix="display">

<cfparam name="stargs.typename" default="dmXMLExport">

<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
	
<head>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>

<div class="FormSubTitle">#application.adminBundle[session.dmProfile.locale].rSSFeeds#</div>

<cfscript>
		o = createObject("component", application.types[stArgs.typename].typePath);
</cfscript>

<script>
function editObject(objectID)
{
	document.dynamicAdmin.objectid = objectID;
}	

function confirmDelete(objectID){
	var msg = "#application.adminBundle[session.dmProfile.locale].confirmDeleteItem#";
	if (confirm(msg))
	{	
		return true;
	}	
	else
		return false;
}				
</script>

</cfoutput>


<cfif isDefined("form.add")>
	<cfscript>
		objectID = o.create();
		o.edit(objectid=objectid);
	</cfscript>

</cfif>

<cfif isDefined("form.edit")>
	<cfscript>
		o.edit(objectid=form.objectid);
	</cfscript>
</cfif>

<cfif isDefined("form.delete")>
	<cfscript>
		o.delete(objectid=form.objectid);
	</cfscript>
</cfif>


<cfparam name="url.order" default="datetimecreated">
<cfparam name="url.direction" default="desc">

<cfparam name="url.pgno" default="1">

<!--- get objects to display --->
<cfscript>
	recordSet = o.getAll();
</cfscript>

<cfparam name="FORM.thisPage" default="1">
<cfscript>
	numRecords = 30;
	thisPage = FORM.thisPage;
	if (recordSet.recordCount GT 0)
	{
		startRow = ((thisPage*numRecords) + 1) - numRecords; //the query row which we start from
		numPages = recordSet.recordcount/numRecords;
		numPages = ceiling(numPages); // the number of 'pages' of results
		if (thisPage GT 1){
			prevPage = thisPage - 1; 
		}	//the next page to advance to  
		if (thisPage LT numPages){
			nextPage = thisPage + 1;
		}	 // the previous page to go back to	
	}else
	{	numpages = 1;
		thispage = 1;
	}
</cfscript>

<cfset comment = false>

<cfoutput>
<cfif isDefined("msg")>
<div class="FormTableClear" style="margin-left:0;">
	<strong>#msg#</strong>
</div>
</cfif>

<table width="100%" cellspacing="1"> 
	<tr>
		<td>
		<table width="90%" cellspacing="0">
			<tr>
				<td>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].items,"#recordSet.recordcount#")#</td>
				<td align="right" valign="middle">
				<form action="" method="post" name="dynamicAdmin">
					<cfif thisPage GT 1>
						<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="prev" name="prev"  onclick="this.form.thisPage.selectedIndex--;this.form.submit();" >
					</cfif>
					Page 
					<select name="thisPage" onChange="this.form.submit();">
						<cfloop from="1" to="#numPages#" index="i">
							<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
						</cfloop>
					</select> of #numPages#
					<cfif thisPage LT numpages>
						<input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="next" onclick="this.form.thisPage.selectedIndex++;this.form.submit();">
					</cfif>
					<cfif isDefined("form.fieldnames")>
					<cfloop list="#form.fieldnames#" index="element">
						<cfif NOT element IS "thisPage">
						<input type="Hidden" name="#element#" value="#evaluate('form.'&element)#">
						</cfif>
					</cfloop>
					</cfif>
					</form>
				</td>
			</tr>		
		</table>
		</td>
	</tr>

	<tr>
		<td>
			<table cellpadding="5" cellspacing="0" border="1" width="90%">
			<tr class="dataheader">
				<td align="center"> #application.adminBundle[session.dmProfile.locale].feed# </td>
				<td align="center" width="80"> #application.adminBundle[session.dmProfile.locale].edit# </td>
				<td align="center" width="80"> #application.adminBundle[session.dmProfile.locale].preview# </td>
				<td align="center" width="80"> #application.adminBundle[session.dmProfile.locale].validate# </td>
				<td align="center" width="80"> #application.adminBundle[session.dmProfile.locale].delete# </td>
			</tr>
         </cfoutput>
		<cfif recordSet.recordCount EQ 0 >
			<cfoutput>
			<tr>
				<td colspan="8" align="center">
					<strong>#application.adminBundle[session.dmProfile.locale].noRecsRecovered#</strong>
				</td>	
			</tr>
			</cfoutput>
		<cfelse>
			<cfoutput query="recordSet" startrow="#startRow#" maxrows="#numRecords#"> 
			<cfscript>
				finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#");
				editObjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=#objectID#&finishUrl=#finishURL#&type=#stArgs.typename#";
				previewURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1&mode=preview";
				validateURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1&mode=validate";
			</cfscript>
			  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#"> 
				<td>#title#</td>
				<td align="center">
					<form action="" method="post" name="form_#recordset.objectid#">
					<input type="hidden" name="objectid" value="#recordset.objectid#">
					<input type="button" name="edit" value="#application.adminBundle[session.dmProfile.locale].edit#" onClick="location.href='#editObjectURL#';">
				</td>
				<td align="center">
					<input type="button" name="preview" value="#application.adminBundle[session.dmProfile.locale].preview#" onClick="window.open('#previewURL#');">
				</td>
				<td align="center">
					<input type="button" name="validate" value="#application.adminBundle[session.dmProfile.locale].validate#" onClick="window.open('#validateURL#');">
				</td>
				<td align="center">
					<input type="submit" name="delete" value="#application.adminBundle[session.dmProfile.locale].delete#" onClick="return confirmDelete('#recordset.objectid#')">
					</form>
				</td>
			  </tr>
			</cfoutput>
		</cfif>
		<cfoutput> </table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
			<table class="BorderTable">
			<tr>
				<td nowrap valign="top">
				<!--- get permissions  --->
					<form action="" method="post">
					<cfset finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#")>
					<input type="button" value="#application.adminBundle[session.dmProfile.locale].add#" width="100" style="width:100;" class="normalbttnstyle" name="add" onClick="window.location='#application.url.farcry#/navajo/createObject.cfm?typename=#stArgs.typename#&finishURL=#finishURL#';" >
					</form>					
				</td>
				</tr>
			<tr><td>&nbsp;</td></tr>					
			</table>
			</form>		
		</td> 
	</tr>
</table>
</cfoutput>	
