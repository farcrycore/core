<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
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
<cfparam name="categoryID" default="">

<!--- <cfif categoryID EQ "">
	<cfset objTree = CreateObject("component","#application.packagepath#.farcry.tree")>
	<cfset qtemp = objTree.getRootNode(application.dsn,"categories")>
	<cfif qtemp.recordCount GT 0>
		<cfset categoryID = qtemp.objectID>
	</cfif>
</cfif> --->
		

<cfif librarytype EQ "dmFile">
	<cfset displayLibraryType = "File">
<cfelse>
	<cfset displayLibraryType = "Image">
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


<cfquery dbtype="query" name="qLibraryList">
SELECT	DISTINCT *
FROM	qReturn
WHERE	UPPER(status) = 'APPROVED'
 		AND bLibrary = 1<cfif lExcludeObjectID NEQ "">
		AND objectid NOT IN (#preservesinglequotes(lExcludeObjectID)#)</cfif>
</cfquery>

<cfset stPageination = StructNew()>
<cfset stPageination.qList = qLibraryList>
<cfset stPageination.currentpage = currentpage>
<cfset stPageination.maxRow = 10>
<cfset stPageination.urlParameters = "libraryType=#libraryType#&primaryObjectID=#primaryObjectID#&categoryID=#categoryID#">
<cfset stPageination.urlParametersWithOutFilter = "libraryType=#libraryType#&primaryObjectID=#primaryObjectID#">
<cfset strRefreshUrl = cgi.script_name & "?#stPageination.urlParameters#">

<cfinvoke component="#application.packagepath#.farcry.category" method="getAllCategories" returnvariable="qListCategory" />

<cfoutput>
<body class="popup #displayLibraryType#browse">
<form action="library.cfm" method="post">
<h1>Browse for #displayLibraryType#s...</h1>
<div class="tab-container">
	<ul class="tabs">
	<li id="tab1"><a href="##">#displayLibraryType# Library</a></li>
	<li id="tab2" class="tab-disabled"><a href="library.cfm?#queryString#&librarySection=upload">My Computer</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
		<h2>Browse by category</h2>
<widgets:categoryAssociation typeName="#librarytype#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#">
		<!--- #fDisplayCategory(qListCategory,stPageination.urlParametersWithOutFilter,categoryID)# --->
<ul>
	<li><cfif categoryID EQ ""><strong>[Unassigned]</strong><cfelse>
		<a href="#cgi.script_name#?#stPageination.urlParametersWithOutFilter#">[Unassigned]</a></cfif>
	</li>
</ul>
		<!--- <h3>Search</h3>
		<input value="Enter keyword(s)" type="text" size="15" />
		<input type="submit" value="Go" /> --->
		</div>		
		<div id="content">
		<cfset fDisplayPagination(stPageination)>
<cfif libraryType EQ "dmImage">
			<div class="thumbNailsWrap">
				<ul><cfloop query="qLibraryList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li>
					<label for="libcheck#qLibraryList.currentrow#"><input type="checkbox" id="libcheck#qLibraryList.currentrow#" name="lLibrarySelection" value="#qLibraryList.objectid#" />
					<span>
					<cfif qLibraryList.thumbnail NEQ ""><widgets:imageDisplay objectid="#qLibraryList.objectid#" alt="#qLibraryList.alt#">
						<!--- <img src="#application.url.webroot#/images/#qLibraryList.thumbnail#" alt="#qLibraryList.alt#" /> --->
					<cfelse>
						<img src="../images/no_thumbnail.gif" alt="currently no thumbnail" />
					</cfif>
					</span>#Left(qLibraryList.title,25)#<cfif Len(qLibraryList.title) GT 25> ...</cfif>
					</label>
				</li>
				</cfloop>
				</ul>				
			</div>
<cfelse>
			<div class="filesWrap">
				<ul><cfloop query="qLibraryList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li><label for="libcheck#qLibraryList.currentrow#"><input type="checkbox" id="libcheck#qLibraryList.currentrow#" name="lLibrarySelection" value="#qLibraryList.objectid#">#qLibraryList.title#</label></li></cfloop>
				</ul>				
			</div>
</cfif>
		<cfset fDisplayPagination(stPageination)>
		</div>		
		<div class="f-submit-wrap">
			<!--- <input type="submit" value="Insert &amp; add another" class="f-submit f-submitsecondary" tabindex="12" /> --->
			<cfif qLibraryList.recordCount GT 0>
			<input type="submit" value="Insert" class="f-submit" tabindex="12" /></cfif>
			<input type="button" name="buttoncancel" class="f-submit" value="Cancel" onclick="window.close();">
		</div>
	</div>	
</div>
<input type="hidden" name="bFormSubmission" value="true">
<input type="hidden" name="libraryType" value="#libraryType#">
<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
</form>
</body>
</cfoutput>