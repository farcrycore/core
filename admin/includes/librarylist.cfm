<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
<cfparam name="searchText" default="">
<cfparam name="searchField" default="">
<cfparam name="bSearchFormSubmitted" default="No">
<cfset objplp = CreateObject("component","#application.packagepath#.farcry.plpUtilities")>
<cfif bFormSubmission EQ "true">
	<cfset objTypes = CreateObject("component","#application.packagepath#.types.types")>
	<cfset typename = objTypes.findType(primaryObjectID)>
	<cfset objItems = CreateObject("component","#application.types[typename].typepath#")>
	<cfset stObj = objItems.getData(primaryObjectID)>
	
	<!--- objectids that already exist in the wddx --->
	<cfset objplp.fAddArrayObjects(primaryObjectID,lLibrarySelection)>
	<!--- <cfset returnstruct = objplp.fGetArrayObjects(primaryObjectID)> --->

	<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
	<cfinclude template="/farcry/farcry_core/admin/includes/json.cfm">
	<cfset arItems = objplp.fGenerateObjectsArray(primaryObjectID,libraryType)>
<cfoutput><script type="text/javascript">
var jsonData = '#jsonencode(arItems)#';
opener.processReqChange#libraryType#(jsonData,'');
window.close();
</script></cfoutput>
</cfif>

<cfset returnstruct = objplp.fGetArrayObjects(primaryObjectID)>
<cfset lExcludeObjectID = ArrayToList(returnstruct.output)>
<cfset lExcludeObjectID = ListQualify(lExcludeObjectID,"'")>

<!--- filter --->
<!--- default category id [defaults to unassinged] --->
<cfparam name="categoryID" default="" />
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

<!--- filter by keyword --->
<cfset aKeywordField = ArrayNew(1)>
<cfset ArrayAppend(aKeywordField,"label")>
<cfset ArrayAppend(aKeywordField,"createdBy")>
<cfset ArrayAppend(aKeywordField,"objectid")>
<cfif librarytype EQ "dmFile">
	<cfset displayLibraryType = "file">
<cfelse>
	<cfset displayLibraryType = "image">
</cfif>

<!--- get all child categories --->
<cfset objCategories = CreateObject("component","#application.packagepath#.farcry.category")>
<cfif categoryID EQ "">
	<!--- retieve all unassigned --->
	<cfset qReturn = objCategories.getData("",librarytype)>
<cfelse>
	<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
	<cfset qReturn = objCategories.getData(lCategoryids,librarytype)>
</cfif>
	
<cfif bSearchFormSubmitted AND searchField NEQ "" AND trim(searchText) NEQ "">
	<cfquery dbtype="query" name="qReturn">
	SELECT	*
	FROM	qReturn
	WHERE	#searchField# LIKE '%#trim(searchText)#%'
	</cfquery>
</cfif>

<cfquery dbtype="query" name="qLibraryList">
SELECT	DISTINCT *
FROM	qReturn
WHERE	status is not null 
		AND UPPER(status) = 'APPROVED'
 		AND bLibrary = 1<cfif lExcludeObjectID NEQ "">
		AND objectid NOT IN (#preservesinglequotes(lExcludeObjectID)#)</cfif>
</cfquery>

<cfset stPageination = StructNew()>
<cfset stPageination.qList = qLibraryList>
<cfset stPageination.currentpage = currentpage>
<cfset stPageination.maxRow = 10>
<cfset stPageination.urlParameters = "libraryType=#libraryType#&primaryObjectID=#primaryObjectID#&categoryID=#categoryID#&searchText=#searchText#&bSearchFormSubmitted=#bSearchFormSubmitted#&searchField=#searchField#">
<cfset stPageination.urlParametersWithOutFilter = "libraryType=#libraryType#&primaryObjectID=#primaryObjectID#">
<cfset strRefreshUrl = cgi.script_name & "?#stPageination.urlParameters#">

<cfinvoke component="#application.packagepath#.farcry.category" method="getAllCategories" returnvariable="qListCategory" />

<cfoutput>
<body class="popup #displayLibraryType#browse">
<h1>Browse for #displayLibraryType#s...</h1>
<div class="tab-container">
	<ul class="tabs">
	<li id="tab1"><a href="##">#displayLibraryType# Library</a></li>
	<li id="tab2" class="tab-disabled"><a href="library.cfm?#queryString#&librarySection=upload">My Computer</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
			<h2>Browse by category</h2></cfoutput>
			<widgets:categoryAssociation typeName="#librarytype#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#"><cfoutput>
			<ul>
				<li><cfif categoryID EQ ""><strong>[Unassigned]</strong><cfelse>
					<a href="#cgi.script_name#?#stPageination.urlParametersWithOutFilter#&categoryID=unassigned">[Unassigned]</a></cfif>
				</li>
			</ul>

			<h3>Search</h3>
			<form name="frmSearch" id="frmSearch" action="library.cfm" method="post">
				<select name="searchField" id="searchField"><cfloop index="i" from="1" to="#ArrayLen(aKeywordField)#">
					<option value="#aKeywordField[i]#"<cfif searchField EQ aKeywordField[i]> selected="selected"</cfif>>#aKeywordField[i]#</option></cfloop>
				</select><br />
				<input value="#searchText#" name="searchText" id="searchText" type="text" size="15" />
				<input type="hidden" name="categoryID" value="#categoryID#">
				<input type="submit" name="buttonSearch" id="buttonSearch" value="Go" />
				<input type="hidden" name="libraryType" value="#libraryType#">
				<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
				<input type="hidden" name="bSearchFormSubmitted" value="Yes">
			</form>
		</div>

		<form name="frmLibrary" id="frmLibrary" action="library.cfm" method="post">
		<div id="content">
			<fieldset>
			<div class="utilBar"></cfoutput>
				<cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset>
			<cfif libraryType EQ "dmImage">
			<div class="thumbNailsWrap">
				<ul><cfloop query="qLibraryList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li>
					<label for="libcheck#qLibraryList.currentrow#"><input type="checkbox" id="libcheck#qLibraryList.currentrow#" name="lLibrarySelection" value="#qLibraryList.objectid#" />
					<span>
					<cfif qLibraryList.ThumbnailImage NEQ "">
						<widgets:imageDisplay objectid="#qLibraryList.objectid#" alt="#qLibraryList.alt#">
					<cfelse>
						<img src="../images/no_thumbnail.gif" alt="currently no thumbnail" />
					</cfif>
					</span>#Left(qLibraryList.title,25)#<cfif Len(qLibraryList.title) GT 25> ...</cfif>
					</label>
				</li>
				</cfloop>
				</ul>				
			</div><cfelse>
			<div class="filesWrap">
				<fieldset>
				<ul><cfloop query="qLibraryList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li><label for="libcheck#qLibraryList.currentrow#"><input type="checkbox" id="libcheck#qLibraryList.currentrow#" name="lLibrarySelection" value="#qLibraryList.objectid#">#qLibraryList.title#</label></li></cfloop>
				</ul>
			</div></cfif>
			<fieldset>
			<div class="utilBar">
				</cfoutput><cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset>
		</div>
		<div class="f-submit-wrap"><cfif qLibraryList.recordCount GT 0>
			<input type="submit" value="Insert" class="f-submit" tabindex="12" /></cfif>
			<input type="button" name="buttoncancel" class="f-submit" value="Cancel" onclick="window.close();">
		</div>
		<input type="hidden" name="bFormSubmission" value="true">
		<input type="hidden" name="libraryType" value="#libraryType#">
		<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
	</form>
	</div>
</div>
</body>
</cfoutput>