<cfsetting enablecfoutputonly="true">
<cfparam name="bFormSubmission" default="no">
<cfparam name="typeName" default="">
<cfparam name="categoryID" default="">
<cfparam name="currentpage" default="1">
<cfparam name="lSelection" default="">
<cfparam name="fieldName" default="">
<cfparam name="searchText" default="">
<cfparam name="searchField" default="">
<cfparam name="bSearchFormSubmitted" default="No">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
<cfinclude template="/farcry/farcry_core/admin/includes/libraryFunctions.cfm">
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
	<!--- TODO: need further investigation need total number of records taht also fil ethe search criteria, this stored proc only retyurns the a max record not all records that match criteria (was done for performance)--->
	<!--- <cfset returnstruct = objCategories.fPagingContentObjectByCategoryID(categoryID,typename,stPageination.currentpage,stPageination.maxRow)>
	<cfset qList = returnstruct.queryObject>
	<cfset stPageination.numberOfRecords = returnstruct.totalRecords> --->
	<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
	<cfset qList = objCategories.getData(lCategoryids,typeName)>
<cfelse>
	<cfset lCategoryids = objCategories.getCategoryBranchAsList(categoryID)>
	<cfset qList = objCategories.getData(lCategoryids,typeName)>
</cfif>

<!--- filter by keyword --->
<cfset aKeywordField = ArrayNew(1)>
<cfset ArrayAppend(aKeywordField,"label")>
<cfset ArrayAppend(aKeywordField,"createdBy")>
<cfset ArrayAppend(aKeywordField,"objectid")>

<cfif bSearchFormSubmitted AND searchField NEQ "" AND trim(searchText) NEQ "">
	<cfquery dbtype="query" name="qList">
	SELECT	*
	FROM	qList
	WHERE	#searchField# LIKE '%#trim(searchText)#%'
	</cfquery>
</cfif>

<cfset objType = CreateObject("component","#application.types[typename].typepath#")>

<!--- get all child categories --->
<cfset stPageination.qList = qList>
<cfset stPageination.urlParameters = "typeName=#typeName#&categoryID=#categoryID#&bSearchFormSubmitted=#bSearchFormSubmitted#&searchField=#searchField#&searchText=#searchText#&fieldName=#fieldName#">
<cfset stPageination.urlParametersWithOutFilter = "typeName=#typeName#&fieldName=#fieldName#">
<cfset strRefreshUrl = cgi.script_name & "?#stPageination.urlParameters#">

<cfinvoke component="#application.packagepath#.farcry.category" method="getAllCategories" returnvariable="qListCategory" />

<cfsetting enablecfoutputonly="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry</title><cfoutput>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
<style type="text/css">
.thumbNailsWrap li {width:#Application.config.image.thumbnailwidth+10#px;height:9.2em;}
.thumbNailsWrap li img {width:#Application.config.image.thumbnailwidth#px;height:#Application.config.image.thumbnailheight#px}
.thumbNailsWrap li input {top:#Application.config.image.thumbnailheight-9#px;}
.thumbNailsWrap li span {width:#Application.config.image.thumbnailwidth+3#px;height:#Application.config.image.thumbnailheight+3#px;}</cfoutput>
</style>
</head><cfoutput>
<body class="popup imagebrowse">
<h1>Object Picker</h1>
<div class="tab-container">
	<ul class="tabs">
		<li id="tab1"><a href="##">Choose #typeName#</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
			<h2>Browse by category</h2></cfoutput>
			<widgets:categoryAssociation typeName="#typeName#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#"><cfoutput>
			
			<h3>Search</h3>
			<form name="frmSearch" id="frmSearch" action="objectPicker.cfm" method="post">
				<select name="searchField" id="searchField"><cfloop index="i" from="1" to="#ArrayLen(aKeywordField)#">
					<option value="#aKeywordField[i]#"<cfif searchField EQ aKeywordField[i]> selected="selected"</cfif>>#aKeywordField[i]#</option></cfloop>
				</select><br />
				<input value="#searchText#" name="searchText" id="searchText" type="text" size="15" />
				<input type="submit" name="buttonSearch" id="buttonSearch" value="Go" />
				<input type="hidden" name="bSearchFormSubmitted" value="Yes">
				<input type="hidden" name="typeName" value="#typeName#">
				<input type="hidden" name="fieldName" value="#fieldName#">
			</form>
		</div>

		<form action="objectPicker.cfm" method="post" name="frmRelated" id="frmRelated">
		<div id="content">
			<fieldset>
			<div class="utilBar"></cfoutput>
				<cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset><cfif typeName EQ "dmImage">
			<div class="thumbNailsWrap">
				<ul><cfloop query="qList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
					<li>
						<label for="objectPicker_#qList.currentrow#">
						<input type="radio" id="objectPicker_#qList.currentrow#"<cfif lSelection EQ qList.objectid> checked="checked"</cfif> name="lSelection" value="#qList.objectid#" />
						<span>
						<cfif qList.ThumbnailImage NEQ "">
							<widgets:imageDisplay objectid="#qList.objectid#" alt="#qList.alt#">
						<cfelse>
							<img src="../images/no_thumbnail.gif" alt="currently no thumbnail" />
						</cfif>
						</span>#Left(qList.title,25)#<cfif Len(qList.title) GT 25> ...</cfif></label>
					</li></cfloop>
				</ul>
			</div><cfelse>
			<div class="filesWrap">
				<ul><cfloop query="qList" startrow="#stPageination.startRow#" endrow="#stPageination.startRow+stPageination.maxRow-1#">
					<li><label for="objectPicker_#qList.currentrow#"><input type="radio" id="objectPicker_#qList.currentrow#" name="lSelection" value="#qList.objectid#" />#qList.title#</label></li></cfloop>
				</ul>
			</div></cfif>
			<fieldset>
			<div class="utilBar"></cfoutput>
				<cfset fDisplayPagination(stPageination)><cfoutput>
			</div>
			</fieldset>
		</div>
		<div class="f-submit-wrap">
			<input type="submit" name="buttonsubmit" value="Insert" class="f-submit" tabindex="12" />
			<input type="button" name="buttoncancel" class="f-submit" value="Cancel" onclick="window.close();" />
			<input type="hidden" name="bFormSubmission" value="true">
			<input type="hidden" name="typeName" value="#typeName#">
			<input type="hidden" name="fieldName" value="#fieldName#">
		</div>
		</form>
	</div>
</div>	
</body>
	
<!--- <body class="popup filebrowse">

<div class="tab-container">
	<ul class="tabs">
	<li id="tab1"><a href="##">Choose #typeName#</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
		<h2>Browse by category</h2>
<!--- <widgets:categoryAssociation typeName="#typeName#" lSelectedCategoryID="#categoryID#" naviagtionURL="#stPageination.urlParametersWithOutFilter#"> --->
		<h3>Search</h3>
<form name="frmSearch" id="frmSearch" action="objectPicker.cfm" method="post">
<fieldset>
		<select name="searchField" id="searchField"><cfloop index="i" from="1" to="#ArrayLen(aKeywordField)#">
			<option value="#aKeywordField[i]#"<cfif searchField EQ aKeywordField[i]> selected="selected"</cfif>>#aKeywordField[i]#</option></cfloop>
		</select>
		<input value="#searchText#" name="searchText" id="searchText" type="text" size="15" />
		<input type="submit" name="buttonSearch" id="buttonSearch" value="Go" />
		<input type="hidden" name="bSearchFormSubmitted" value="Yes">
		<input type="hidden" name="typeName" value="#typeName#">
		<input type="hidden" name="fieldName" value="#fieldName#">
</fieldset>
</form>
		</div>
		<div id="content">
		MY CONTENT
		</div>
<!--- <form action="objectPicker.cfm" method="post">
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
					</span>#Left(qList.title,25)#<cfif Len(qList.title) GT 25> ...</cfif></label>
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
			<input type="hidden" name="bFormSubmission" value="true">
			<input type="hidden" name="typeName" value="#typeName#">
			<input type="hidden" name="fieldName" value="#fieldName#">
</form> --->
	</div>	
</div>
</body> --->
</cfoutput>
</html>
