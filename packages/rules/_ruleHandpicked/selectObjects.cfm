<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectObjects.cfm,v 1.4 2003/07/24 00:41:52 brendan Exp $
$Author: brendan $
$Date: 2003/07/24 00:41:52 $
$Name: b131 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose teaser handler (teaser.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lobjectids" default="">
<cfparam name="cookie.hp_#output.cleanObjectID#" default="#output.lObjectIDs#">


<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>
<script language="JavaScript">
	
	var rowcolor="red";
	function selectRow(id){
		em = document.getElementById(id);
		if (em.style.color != rowcolor)
			em.style.color="red";
		else
			em.style.color="black";
		}	
	// tell the server above the current page; it will call the 
	// serverGet() function when it's done
	function serverPut(objID,cleanUUID){
		// the URL of the script on the server to run
		strURL = "setHandpickedCookie.cfm";
		// if you need to pass any variables to the script, 
		// then populate the following string with a valid query string	
		strQueryString = "objectId=" + objID + "&cookiename="+cleanUUID+"&" + Math.random();
		em = document.getElementById('row'+objID);
		if (em.style.color != rowcolor)
		{
			em.style.color="red";
			strQueryString = strQueryString + "&action=append";
		}	
		else
		{	
			strQueryString = strQueryString + "&action=remove";
			em.style.color="black";
		}	
	
		// this will append a random number to the URL string that will 
		// ensure the document isn't cached
		//strURL = strURL + "/" + Math.random();
		// if the query string variable isn't blank, then append it to the URL
		if( strQueryString.length > 0 ){
			strURL = strURL + "?" + strQueryString;
		}
		
		// if IE then change the location of the IFRAME 
		if( document.all ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.location = strURL;
	
		// otherwise, change Netscape v6's IFRAME source file
		} else if( document.getElementById ){
			// this loads the URL stored in the strURL variable into the hidden frame
			document.getElementById("idServer").contentDocument.location = strURL;

		// otherwise, change Netscape v4's ILAYER source file
		} else if( document.layers ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.src = strURL;
		}
	
		return true;
	}

</script>

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.submit") or (isdefined("form.quicknav") and form.quicknav neq "")>
	<cfscript>
		output.lObjectIDs = evaluate("cookie.hp_" & output.cleanObjectID);
	</cfscript>
</cfif>

<cfif NOT isDefined("FORM.search")>
	<tags:plpNavigationMove>
<cfelse>
	<cfloop index="FormItem" list="#FORM.FieldNames#">
		<cfset "output.#FormItem#" = Evaluate("FORM.#FormItem#")>
	</cfloop>	
</cfif>


<cfif NOT thisstep.isComplete>


<cfparam name="FORM.thisPage" default="1">

<!--- Build SQL  --->
<cfscript>
	sql = "SELECT * FROM #output.dmType#";
	sql = sql & " WHERE status = 'approved'";
	sql = sql & " ORDER BY #output.orderby# #output.orderdir#";
</cfscript>

<cfquery name="recordset" datasource="#application.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>


<!--- This script block sorts out next/previous page stuff --->
<cfscript>
	numRecords = 20; //this is the number of records to display per page
	thisPage = FORM.thisPage;
	if (recordSet.recordCount GT 0)
	{
		startRow = ((thisPage*numRecords) + 1) - numRecords; //the query row which we start from
		endRow = (numRecords + startRow)-1;
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
		endrow=1;
		startrow=1;
	}
</cfscript>


<cfoutput>

	<style type="text/css">
		border {border:thin solid Black; }
	</style>

	<div class="FormTitle">Select Object Type</div>
	<div class="FormTable" align="center">
	<form name="form" action="" method="post">
 	<table>
	<tr>
		<td>
			Object Type - #output.dmType#
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td>
						Order by
						<select name="orderby">
							<option value="label" <cfif output.orderby IS "label">selected</cfif>>Label</option>
							<option value="datetimelastupdated" <cfif output.orderby IS "datetimelastupdated">selected</cfif>>Date Object Last Updated</option>
						</select>
						<select name="orderdir">
							<option value="ASC" <cfif output.orderdir IS "ASC">selected</cfif>>Ascending</option>
							<option value="DESC" <cfif output.orderby IS "DESC">selected</cfif>>Descending</option>
						</select>
						<input type="submit" name="search" value="Go">
					</td>
				</tr>
			</table>
		</td>
	</tr>										
	
	</table>
	
	<table class="border" width="100%" style="border:thin solid Black;" >
	<tr>
		<td colspan="3">
			<table width="100%" cellspacing="0" class="border">
			<tr >
				<td>#recordSet.recordcount# items</td>
				<td align="right" valign="middle">
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
				</td>
			</tr>		
			</table>
		</td>
	</tr>
		<tr>
			<td>
				Select
			</td>
			<td>
				Label
			</td>
			<td>
				Last Updated
			</td>
		</tr>
		<cfloop query="recordSet" startrow="#startRow#" endrow="#endRow#">
		<tr id="row#recordSet.objectID#">
			<td>
				<input onClick="serverPut('#recordSet.objectID#','#output.cleanObjectID#');" type="checkbox" name="lObjectIDs" value="#objectID#" <cfif listcontainsnocase(evaluate("cookie.hp_" & output.cleanobjectID),recordset.objectID)>checked</cfif>>
				<cfif listcontainsnocase(evaluate("cookie.hp_" & output.cleanobjectID),recordSet.objectID)>
					<script>
						selectRow('row#recordset.objectID#');
					</script>
				</cfif>	
			</td>
			<td>
				#label#
			</td>
			<td>
				#dateformat(datetimelastupdated,"dd-mmm-yyyy")#
			</td>
		</tr>
		</cfloop>
	</table>
	</form>
	</div>
</cfoutput>
<cfoutput>
<STYLE TYPE="text/css">
		##idServer { 
			position:relative; 
			width: 1px; 
			height: 1px; 
			clip:rect(0px 1px 1px 0px); 
			display:none;
			 
		}
	</STYLE>

<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P>This page uses a hidden frame and requires either Microsoft 
		Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
		higher.)</P>
		</ILAYER>
</IFRAME>	
</cfoutput>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">	
	<cfoutput>
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	</cfoutput>
	
</cfform>
	
<cfelse>
	<tags:plpUpdateOutput>
</cfif>