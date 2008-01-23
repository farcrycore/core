<cfsetting enablecfoutputonly="true">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$Community: FarCry CMS http://www.farcrycms.org $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/includes/relatedlist.cfm,v 1.15.2.8 2006/05/06 11:26:54 geoff Exp $
$Author: geoff $
$Date: 2006/05/06 11:26:54 $
$Name: p300_b113 $
$Revision: 1.15.2.8 $

|| DESCRIPTION || 
$Description: Related content item picker. $
$TODO: This is in need of a major overhaul.. what happened here? taking ownership. GB 20060314 
Action plan:
 - comment code
 - close out current tickets FC-403, FC-466
 - earmark for refactoring to more flexible tag/component
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<!--- include function libraries --->
<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
<cfinclude template="/farcry/core/admin/includes/json.cfm">
<!--- miscellaneous functions --->
<cfinclude template="/farcry/core/admin/includes/libraryFunctions.cfm">

<!--- environment variables --->
<!--- todo: these need to be scoped! GB20060314 --->
<cfparam name="bFormSubmission" default="false">
<cfparam name="lRelatedTypeName" default="#StructKeyList(application.types)#">
<cfparam name="relatedTypeName" default="#ListFirst(lRelatedTypeName)#">
<cfparam name="lRelatedObjectID" default="">
<cfparam name="fieldName" default="arelatedids">
<cfparam name="bPLPStorage" default="true">
<cfparam name="bShowCategoryTree" default="true">
<cfparam name="searchText" default="">
<cfparam name="searchField" default="">
<cfparam name="bSearchFormSubmitted" default="No">
<cfset plpArrayPropertieName = "#fieldName#">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfparam name="pg" default="1">
<cfparam name="categoryID" default=""> <!--- category filter --->
<cfparam name="currentpage" default="1"> <!--- pagination flag --->
<cfparam name="session.objectPicker.categoryID" default="" />

<cfif categoryID EQ "unassigned">
	<!--- User has clicked the "[Unassigned]" link --->
	<cfset session.objectPicker.categoryID = "unassigned" />
	<cfset categoryID = "" />
<cfelseif (structKeyExists(application.catid, "root") AND NOT len(categoryId)) AND (session.objectPicker.categoryID NEQ "unassigned")>
	<!--- default view state from webtop link should be the category root --->
	<cfset session.objectPicker.categoryID = application.catid['root'] />
	<cfset categoryID = session.objectPicker.categoryID />
<cfelseif len(trim(categoryID))>
	<!--- when in categories, pagination will always send an objectID --->
	<cfset session.objectPicker.categoryID = trim(categoryID) />
</cfif>

<!--- check if related content is being called form a plp or from a normal editform --->
<cfif bPLPStorage>
	<cfset objplp = CreateObject("component","#application.packagepath#.farcry.plpUtilities")>
	<cfset returnstruct = objplp.fRead(primaryObjectID)>
<cfelse>
	<q4:contentobjectget objectid="#primaryObjectID#" r_stobject="stobj">
	<cfset returnstruct=structnew()>
	<cfset returnstruct.plp=structnew()>
	<cfset returnstruct.plp.output=structcopy(stObj)>
	<cfset returnstruct.plp.input=structcopy(stObj)>
</cfif>

<cfif IsArray(returnstruct.plp.output[plpArrayPropertieName])>
	<cfset bStoreAsArray = 1>
<cfelse>
	<cfset bStoreAsArray = 0>
</cfif>

<!------------------------------- 
ACTION: form action 
--------------------------------->
<cfif isDefined("form.buttonsubmit")>	
	<cfset objTypes = CreateObject("component","#application.packagepath#.types.types")>
	<cfset typename = objTypes.findType(primaryObjectID)>
	<cfset objItems = CreateObject("component","#application.types[relatedTypeName].typePath#")>

	<!--- objectids that already exist in the wddx --->
	<cfif bPLPStorage>
		<cfif bStoreAsArray>
			<!--- populate the related array --->
			<cfset objplp.fAddArrayObjects(primaryObjectID,lRelatedObjectID, plpArrayPropertieName)>

			<!--- get the selected items back as an array ---> 
			<cfset arItems = objplp.fGenerateObjectsArray(primaryObjectID,lRelatedTypeName,plpArrayPropertieName)>	
		<cfelse>
			<!--- populate the related array --->
			<cfset objplp.fAppendPropertie(primaryObjectID,plpArrayPropertieName,lRelatedObjectID)>

			<!--- get the selected items back as an array ---> 
			<cfset arItems = objplp.fGenerateObjectsArray(primaryObjectID,lRelatedTypeName,plpArrayPropertieName)>
		</cfif>
	<cfelse>
		<cfset objPrimary = CreateObject("component","#application.types[typename].typePath#")>
		<cfset stProps = objPrimary.getData(objectid=primaryObjectId)>
		<cfset lPreSelectedObjects = ArrayToList(stProps[plpArrayPropertieName])>
		<cfset lSelectidItems = ListAppend(lPreSelectedObjects,lRelatedObjectID)>
		<cfset aSelectidItems = ListToArray(lSelectidItems)>
		<cfset stProps[plpArrayPropertieName] = aSelectidItems>
		<cfset objPrimary.setData(stProps)>
		<cfset arItems = ArrayNew(1)>
		<cfset j = 0>
		<cfloop index="i" from="1" to="#ArrayLen(aSelectidItems)#">
			<q4:contentobjectget objectid="#aSelectidItems[i]#" r_stobject="stItem">
			<cfif NOT StructIsEmpty(stItem)>
				<cfset j = j + 1>
				<cfset arItems[j] = StructNew()>
				<cfset arItems[j].text = JSStringFormat(stItem.label)>
				<cfset arItems[j].objectID = aSelectidItems[i]>
				<cfswitch expression="#stItem.typename#">
					<cfcase value="dmImage">
						<cfif stItem.optimisedimage neq "">
							<cfset arItems[j].value = JSStringFormat("#stItem.objectID#|<a href='#application.url.webroot#/images/#stItem.optimisedimage#' target='_blank'><img src='#application.url.webroot#/images/#stItem.imagefile#' border=0 alt='#stItem.alt#'></a>")>
						<cfelse>
							<cfset arItems[j].value = JSStringFormat("#stItem.objectID#|<img src='#application.url.webroot#/images/#stItem.imagefile#' border=0 alt='#stItem.alt#'>")>
						</cfif>
					</cfcase>
		
					<cfcase value="dmFile">
						<cfif application.config.general.fileDownloadDirectLink eq "false">
							<cfset arItems[j].value = JSStringFormat("#stItem.objectID#|<a href='#application.url.webroot#/download.cfm?DownloadFile=#stItem.objectid#' target='_blank'>#stItem.title#</a>")>
						<cfelse>
							<cfset arItems[j].value = JSStringFormat("#stItem.objectID#|<a href='#application.url.webroot#/files/#stItem.filename#' target='_blank'>#stItem.title#</a>")>
						</cfif>
					</cfcase>

					<cfdefaultcase>
						<cfset arItems[j].value = JSStringFormat(stItem.label)>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- update opening parent window with JSON data and close pop-up --->
	<cfoutput>
	<script type="text/javascript">
	var jsonData = '#jsonencode(arItems)#';
	opener.processReqChange_#plpArrayPropertieName#(jsonData,'');
	window.close();
	</script>
	</cfoutput>
</cfif>

<!--- see if the values are stored in the arelatedids feild or another fieldname --->
<cfif bPLPStorage>
	<cfif bStoreAsArray>
		<cfset returnstruct = objplp.fGetArrayObjects(primaryObjectID,plpArrayPropertieName)>
		<cfset lExcludeObjectID = ArrayToList(returnstruct.output)>
	<cfelse>
		<cfset returnstruct = objplp.fReadPropertie(primaryObjectID,fieldName)>
		<cfset lExcludeObjectID = returnstruct.output>
	</cfif>
<cfelse>
	<cfset lExcludeObjectID = arrayToList(returnstruct.plp.output[plpArrayPropertieName])>
</cfif>
<cfset lExcludeObjectID = ListQualify(lExcludeObjectID,"'")>


<!--- FILTER: category filter --->
<cfif bShowCategoryTree EQ "true">
	<!--- default category id [defaults to unassinged] --->
	<!--- get all child categories --->
	<cfset objCategories = CreateObject("component","#application.packagepath#.farcry.category")>
	<cfif categoryID EQ "">
		<!--- retieve all unassigned --->
		<cfset qReturn = objCategories.getData("",relatedTypeName)>
	<cfelse>
		<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
		<cfset qReturn = objCategories.getData(lCategoryids,relatedTypeName)>
	</cfif>
			
	<cfset objCategories = CreateObject("component","#application.packagepath#.farcry.category")>
	<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
	<cfset qReturn = objCategories.getData(lCategoryids,relatedTypeName)>
	<cfset qListCategory = objCategories.getAllCategories()>
	<!--- <cfinvoke component="#application.packagepath#.farcry.category" method="getAllCategories" returnvariable="qListCategory" /> --->
<cfelse>
	<!--- return everything --->
	<cfquery name="qReturn" datasource="#application.dsn#">
	SELECT	objectid, label
	FROM 	#application.dbowner##relatedTypeName# type
	</cfquery>
</cfif>

<!--- /FILTER --->

<!--- FILTER: keyword filter --->
<cfset aKeywordField = ArrayNew(1)>
<cfset ArrayAppend(aKeywordField,"label")>
<cfset ArrayAppend(aKeywordField,"createdBy")>
<cfset ArrayAppend(aKeywordField,"objectid")>
<!--- /FILTER --->

<!--- QUERY: content listing query --->
<!--- 
todo: this is a real worry.. 
		- need pref cache in session
		- need to clean up UI logic completely
	20060314 GB
--->
<!--- <cfif (bSearchFormSubmitted AND searchField NEQ "" AND trim(searchText) NEQ "") OR (structKeyExists(URL, "searchText") AND len(trim(URL.searchText)))> --->
<cfif (searchField NEQ "" AND trim(searchText) NEQ "") OR (structKeyExists(URL, "searchText") AND len(trim(URL.searchText)))>
	
	<cfquery dbtype="query" name="qReturn">
	SELECT	DISTINCT objectid, label
	FROM	qReturn
	WHERE	LOWER(#searchField#) LIKE '%#trim(lcase(searchText))#%'
	</cfquery>
</cfif>

<cfquery dbtype="query" name="qLibraryList">
SELECT distinct	objectid, label
FROM	qReturn
WHERE 
	label <> '(incomplete)'
<!--- excludes those content items already selected for the underlying wizard (plp) --->
<cfif lExcludeObjectID NEQ "">
	AND objectid NOT IN (#preservesinglequotes(lExcludeObjectID)#)
</cfif>
ORDER BY label
</cfquery>
<!--- /QUERY --->

<!--- manage pop-up pagination --->
<cfset stPageination = StructNew()>
<cfset stPageination.qList = qLibraryList>
<cfset stPageination.currentpage = pg>
<cfset stPageination.urlParametersWithOutFilter = "lRelatedTypeName=#lRelatedTypeName#&relatedTypeName=#relatedTypeName#&primaryObjectID=#primaryObjectID#&fieldName=#fieldName#&bShowCategoryTree=#bShowCategoryTree#&bPLPStorage=#bPLPStorage#">
<cfset stPageination.urlParameters = "#stPageination.urlParametersWithOutFilter#&categoryID=#categoryID#&searchText=#searchText#&searchField=#searchField#">
<cfset stPageination.maxRow = 10>
<cfset strRefreshUrl = cgi.script_name & "?#stPageination.urlParameters#">

<!--------------------------------- 
VIEW: render page
----------------------------------->
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>FarCry</title>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
<!--- DataRequestor Object : used to retrieve xml data via javascript --->
<script src="#application.url.farcry#/includes/lib/DataRequestor.js"></script>
<!--- JSON javascript object --->
<script src="#application.url.farcry#/includes/lib/json.js"></script>
</head>
<body class="popup filebrowse #relatedTypeName#browse">

<h1>Related #relatedTypeName#</h1>
<div class="tab-container">
	<ul class="tabs">
	<li id="tab1"><a href="##">Related Content</a></li>
	<!--- <li id="tab2" class="tab-disabled"><a href="relatedlist.cfm?#queryString#&librarySection=upload">My Computer</a></li> --->
	</ul>
	<div class="tab-panes">
		<div id="utility"><cfif bShowCategoryTree EQ "true">
			<h2>Browse by category</h2>
			<widgets:categoryAssociation typeName="#relatedTypeName#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#">
			<ul>
				<li><cfif categoryID EQ ""><strong>[Unassigned]</strong><cfelse>
					<a href="#cgi.script_name#?#stPageination.urlParametersWithOutFilter#&categoryID=unassigned">[Unassigned]</a></cfif>
				</li>
			</ul></cfif>
			<h3>Search</h3>
			<form name="frmSearch" id="frmSearch" action="relatedlist.cfm" method="post">
				<table>
					<tr>
						<td>Search feild</td>
					</tr>
					<tr>
						<td>
						<select name="searchField" id="searchField"><cfloop index="i" from="1" to="#ArrayLen(aKeywordField)#">
							<option value="#aKeywordField[i]#"<cfif searchField EQ aKeywordField[i]> selected="selected"</cfif>>#aKeywordField[i]#</option></cfloop>
						</select>
						</td>
					<tr>
						<td>
							Keywords
						</td>
					</tr>
					<tr>
						<td>
						<input value="#searchText#" name="searchText" id="searchText" type="text" size="15" />
						</td>
					</tr>
					<tr>
						<td>Object type</td>
					</tr>
					<tr>
						<td>
						<select name="relatedTypeName">
						<cfloop index="availableTypename" list="#lRelatedTypeName#">
							<option value="#availableTypename#"<cfif availableTypename EQ relatedTypeName> selected="selected"</cfif>>#availableTypename#</option>
						</cfloop>
						</select>
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" name="buttonChnage" value="Change">	
						</td>
					</tr>
					<input type="hidden" name="categoryID" value="#categoryID#">
					
					<input type="hidden" name="lRelatedTypeName" value="#lRelatedTypeName#">
					<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
					<input type="hidden" name="bPLPStorage" value="#bPLPStorage#">
					<input type="hidden" name="fieldName" value="#fieldName#">
					<input type="hidden" name="bShowCategoryTree" value="#bShowCategoryTree#">
				</table>
			</form>
		</div>

		<div id="content">
			<fieldset>
			<div class="utilBar"></cfoutput>
				<cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset>
			<form name="frmRelatedList" action="relatedlist.cfm" method="post">		
			<div class="filesWrap">
				<ul><cfloop query="qLibraryList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
					<li><label for="libcheck#qLibraryList.currentrow#"><input type="checkbox" id="libcheck#qLibraryList.currentrow#" name="lRelatedObjectID" value="#qLibraryList.objectid#">#qLibraryList.label#</label></li></cfloop>
				</ul>				
			</div>
			<fieldset>
			<div class="utilBar"></cfoutput>
				<cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset>
		</div>
		<div class="f-submit-wrap"><cfif qLibraryList.recordCount GT 0>
			<input type="submit" name="buttonsubmit" value="Insert" class="f-submit" tabindex="12" /></cfif>
			<input type="button" name="buttoncancel" class="f-submit" value="Cancel" onClick="window.close();">
		</div>
			<input type="hidden" name="lRelatedTypeName" value="#lRelatedTypeName#">
			<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
			<input type="hidden" name="bPLPStorage" value="#bPLPStorage#">
			<input type="hidden" name="fieldName" value="#fieldName#">
			<input type="hidden" name="bShowCategoryTree" value="#bShowCategoryTree#">
		</form>
	</div>
</div>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">
