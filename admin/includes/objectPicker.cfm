<cfsetting enablecfoutputonly="true">
<cfparam name="bFormSubmission" default="no">
<cfparam name="typeName" default="">
<cfparam name="categoryID" default="">
<cfparam name="currentpage" default="1">
<cfparam name="lSelection" default="">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
<cfinclude template="/farcry/farcry_core/admin/includes/libraryFunctions.cfm">
<cfparam name="fieldName" default="">

<!--- if sumbitted then updtae the caller field and close window --->
<cfif bFormSubmission EQ "yes">
	<cfset objType = CreateObject("component","#application.types[typename].typepath#")>
	<cfset previewValue ="">
	<cfswitch expression="#typename#">
		<cfcase value="dmImage">
			<cfset previewValue = objType.getURLImagePath(lSelection,"thumb")>
		</cfcase>

	</cfswitch>

	<cfoutput>
<script type="text/javascript"><cfif previewValue EQ "">
opener.fObjectSelected_#fieldName#('#lSelection#')<cfelse>
opener.fObjectSelected_#fieldName#('#lSelection#','#previewValue#')</cfif>
window.close();
</script>
	</cfoutput>
</cfif>
<!--- filter --->
<!--- default category id [defaults to root] --->
<cfif categoryID EQ "">
	<cfset objTree = CreateObject("component","#application.packagepath#.farcry.tree")>
	<cfset qtemp = objTree.getRootNode(application.dsn,"categories")>
	<cfif qtemp.recordCount GT 0>
		<cfset categoryID = qtemp.objectID>
	</cfif>
</cfif>

<cfset stPageination = StructNew()>
<cfset stPageination.currentpage = currentpage>
<cfset stPageination.maxRow = 20>
<cfset objCategories = CreateObject("component","#application.packagepath#.farcry.category")>
<!--- check if the appliaction has paging set up NEED THE stoired procedure SELECT_WITH_PAGING --->
<cfif StructKeyExists(Application,"bAllowPaging") AND Application.bAllowPaging>
	<cfset returnstruct = objCategories.fPagingContentObjectByCategoryID(categoryID,typename,stPageination.currentpage,stPageination.maxRow)>
	<cfset qList = returnstruct.queryObject>
	<cfset stPageination.numberOfRecords = returnstruct.totalRecords>
<cfelse>
	<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
	<cfset qList = objCategories.getData(lCategoryids,typeName)>
</cfif>

<cfset objType = CreateObject("component","#application.types[typename].typepath#")>

<!--- get all child categories --->
<cfset stPageination.qList = qList>
<cfset stPageination.urlParameters = "typeName=#typeName#&categoryID=#categoryID#">
<cfset stPageination.urlParametersWithOutFilter = "typeName=#typeName#">
<cfset strRefreshUrl = cgi.script_name & "?#stPageination.urlParameters#">

<cfinvoke component="#application.packagepath#.farcry.category" method="getAllCategories" returnvariable="qListCategory" />

<cfsetting enablecfoutputonly="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry</title>
<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
<style type="text/css" title="default" media="screen">@import url(../css/tabs.css);</style>
</head>
	<body>
<cfoutput>
<body class="popup filebrowse">
<form action="objectPicker.cfm" method="post">
<div class="tab-container">
	<ul class="tabs">
	<li id="tab1"><a href="##">Choose #typeName#</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
		<h2>Browse by category</h2>
<widgets:categoryAssociation typeName="#typeName#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#">
		<h3>Search</h3>
		<input value="Enter keyword(s)" type="text" size="15" />
		<input type="submit" value="Go" />
		</div>
		<div id="content">
		<cfset fDisplayPagination(stPageination)>
<cfif typeName EQ "dmImage">
			<div class="thumbNailsWrap">
				<ul><cfloop query="qList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li>
					<label for="objectPicker_#qList.currentrow#">
					<input type="radio" id="objectPicker_#qList.currentrow#"<cfif lSelection EQ qList.objectid> checked="checked"</cfif> name="lSelection" value="#qList.objectid#" />
					<span>
					<cfif qList.thumbnail NEQ "">
						<img src="#objType.getURLImagePath(qList.objectid,'thumb')#" alt="#qList.alt#" />
					<cfelse>
						<img src="../images/no_thumbnail.gif" alt="currently no thumbnail" />
					</cfif>
					</span>
					#qList.title#</label>
				</li>
				</cfloop>
				</ul>				
			</div>
<cfelse>
			<div class="filesWrap">
				<ul><cfloop query="qList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
				<li><label for="objectPicker_#qList.currentrow#">
					<input type="radio" id="objectPicker_#qList.currentrow#" name="lSelection" value="#qList.objectid#" />#qList.title#</label></li></cfloop>
				</ul>				
			</div>
</cfif>
		<cfset fDisplayPagination(stPageination)>
		</div>		
		<div class="f-submit-wrap">
			<!--- <input type="submit" value="Insert &amp; add another" class="f-submit f-submitsecondary" tabindex="12" /> --->
			<cfif qList.recordCount GT 0>
			<input type="submit" value="Insert" class="f-submit" tabindex="12" /></cfif>
			<input type="button" name="buttoncancel" class="f-submit" value="Cancel" onclick="window.close();">
		</div>
	</div>	
</div>
<input type="hidden" name="bFormSubmission" value="true">
<input type="hidden" name="typeName" value="#typeName#">
<input type="hidden" name="fieldName" value="#fieldName#">
</form>
</body>
</cfoutput>
</html>
