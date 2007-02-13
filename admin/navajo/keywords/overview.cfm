<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/navajo/keywords/overview.cfm,v 1.10 2005/09/13 06:34:27 guy Exp $
$Author: guy $
$Date: 2005/09/13 06:34:27 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Displays edit form for category tree $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >


<ft:processForm action="Sort Children Ascending">
	<cfif len(form.categoryID)>
		<cfset qChildren = application.factory.oTree.getDescendants(objectid=form.categoryid, bIncludeSelf=false, depth=1) />
		
		
		<cfquery dbtype="query" name="qSortedChildren">
		SELECT objectid,parentid,UPPER(objectname) as catname FROM qChildren
		ORDER BY catname desc
		</cfquery>
		
		<cfif qSortedChildren.recordCount>
			<cfloop query="qSortedChildren">
				<cfset stResult = application.factory.oTree.moveBranch(objectid=qSortedChildren.objectid, parentid=form.categoryID, pos=1) />
			</cfloop>
		</cfif>
	</cfif>
	
	<cfoutput>
	<script type="text/javascript">
	parent.cattreeframe.document.location.reload();
	</script>
	</cfoutput>
</ft:processForm>


<cfoutput><LINK href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css"></cfoutput>

<cfif isDefined("form.submit")>
	<cfquery name="q" datasource="#application.dsn#">
	UPDATE nested_tree_objects
	SET objectname = '#trim(form.objectname)#'
	WHERE objectID = '#objectid#'
	</cfquery>

	<cfquery name="q" datasource="#application.dsn#">
	UPDATE #application.dbowner#categories
	SET categoryLabel = '#form.objectname#'<cfif isDefined("form.alias")>
		,alias = '#form.alias#'</cfif>
	WHERE categoryid = '#objectid#'
	</cfquery>	
	
	<cfset oCat = createObject("component", "#application.packagepath#.farcry.category")>
	<cfset application.catid = oCat.getCatAliases()>

	<cfoutput><script type="text/javascript">
	parent.cattreeframe.document.location.reload();
	</script></cfoutput>
</cfif>


<cfif isDefined("objectid")>
<!--- 	Techincally this join is not necessary - but up intil b220, the category table
	was not updated when users edited a nodes label, but nested_tree_objects was. This join
	will save any unexpected label changes when editing category nodes. 
 --->
 	<cftry>	
	 	<cfquery name="q" datasource="#application.dsn#">
		SELECT	ntm.objectname,cat.alias
		FROM	nested_tree_objects ntm, categories cat
		WHERE 	ntm.objectid = cat.categoryid AND ntm.objectID = '#objectid#'
		</cfquery>
	
		<!--- used to chect if duplicate nav aliases exists --->
		<cfquery name="qListAliases" datasource="#application.dsn#">
		SELECT  alias
		FROM    categories
		WHERE	categoryID != '#objectid#'
		</cfquery>

		<cfset lNavAliases = ValueList(qListAliases.alias)>
		<cfset aNavAliases = ListToArray(lNavAliases)>

		<cfloop index="i" from="1" to="#ArrayLen(aNavAliases)#">
			<cfset aNavAliases[i] = JSStringFormat(UCASE(trim(aNavAliases[i])))>
		</cfloop>
		
		<cfcatch><cfdump var="#cfcatch#"></cfcatch>
	</cftry>

	<cfoutput>
<script type="text/javascript">
function trim(str)
{
   return str.replace(/^\s*|\s*$/g,"");
}

var strDuplicateName = "";
var aNavAliasAll = new Array(1);<cfloop index="i" from="1" to="#ArrayLen(aNavAliases)#">
aNavAliasAll['#aNavAliases[i]#'] = 1;</cfloop>

function doSubmit(objForm)
{
	// break down the nav aliase so can compare to nav aliase that already exists (,)
	var strNavAlias = objForm.alias.value.toUpperCase();
	var aNavAlias = strNavAlias.split(",");
	strDuplicateName = "";

	for(i=0; i< aNavAlias.length; i++)
	{
		// do check on nav each alias item
		alias_name = trim(aNavAlias[i]);
		if(aNavAliasAll[alias_name]){
			strDuplicateName = alias_name;
			break;
		}
	}
	
	if(strDuplicateName != ""){<cfif application.config.overviewTree.bAllowDuplicateNavAlias EQ "Yes">
		return window.confirm("Warning: This Navigation Alias [" + strDuplicateName + "] already exists.\nDo you wish to add it anyway?");<cfelse>
		alert("Error: You are not allowed to add duplicate Navigation Alias [" + strDuplicateName + "].\n");
		return false;</cfif>
	}
}

</script>
	<form action="#ListLast(cgi.script_name,'/')#" name="frm" method="post" onsubmit="return doSubmit(document.frm);">
	<table>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].categoryName#</td>
			<td><input name="objectname" type="Text" size="35" value="#q.objectname#"></td>
			<td><input type="Submit" value="#application.adminBundle[session.dmProfile.locale].update#" name="submit" class="normalbttnstyle"></td>
		</tr>
		<cfset bDev = request.dmsec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer")>
		<cfif bDev EQ 1>
			<td>
				#application.adminBundle[session.dmProfile.locale].alias#
			</td>
			<td colspan="2">
				<input name="alias" type="Text" size="35" value="#q.alias#">
			</td>
		</cfif>
	</table>
	<input type="hidden" name="objectid" value="#objectid#">
	</form>
	</cfoutput>
	
	
	<cfif isDefined("url.objectid") AND len(url.objectid)>
		<cfoutput><hr /></cfoutput>
		<ft:form>
			<cfoutput><input type="hidden" name="categoryID" value="#url.objectid#"></cfoutput>
			<ft:farcryButton value="Sort Children Ascending" />
		</ft:form>
	</cfif>
</cfif>