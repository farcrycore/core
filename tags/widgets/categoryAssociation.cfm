<cfsetting enablecfoutputonly="true">
<cfset typeName = attributes.typeName>
<!--- <cfset objectID = attributes.objectID> --->
<cfparam name="attributes.lSelectedCategoryID" default="">
<!--- category as input (category selection) --->
<cfparam name="attributes.categoryFormFieldName" default="lSelectedCategoryID">
<!--- category as naviagtion --->
<cfparam name="attributes.naviagtionURL" default=""> <!--- used for category navigation --->
<cfparam name="attributes.naviagtionVariableName" default="categoryID"> <!--- name of the objectid passed via the url as a naviagtion vatriable --->

<!--- allow toggle of entire category associtaion --->
<cfparam name="attributes.bAllowToggle" default="1">

<cfset arQlist = ArrayNew(1)>
<cfset lSelectedCategoryID = attributes.lSelectedCategoryID>
<cfif StructKeyExists(application.catid,typeName)> <!--- get all categories which have this typename as an alias --->
	<cfset lCategoryNodes = application.catid[typeName]>
	<cfset iCounter = 1>
	<cfloop index="categoryID" list="#lCategoryNodes#">
		<cfset qList = application.factory.oTree.getDescendants(objectid=categoryID,bIncludeSelf=1)>
		<cfset arQlist[iCounter] = StructNew()>
		<cfset arQlist[iCounter].title = "Categories">
		<cfset arQlist[iCounter].qList = qList>
		<cfset iCounter = iCounter + 1>
	</cfloop>
<cfelse> <!--- get all categories --->
	<cfset objCategories = CreateObject("component","#application.packagepath#.farcry.category")>
	<cfset qList = objCategories.getAllCategories()>
	<cfset arQlist[1] = StructNew()>
	<cfset arQlist[1].title = "Categories">
	<cfset arQlist[1].qList = qList>
</cfif>

<cfoutput><label><b>Selected Categories:</b></cfoutput>
<cfloop from="1" to="#ArrayLen(arQlist)#" index="j">
	<cf_categoryDisplay qListCategory="#arQlist[j].qList#" lSelectedCategoryID="#lSelectedCategoryID#" naviagtionURL="#attributes.naviagtionURL#" naviagtionVariableName="#attributes.naviagtionVariableName#" iCounter="#j#">
</cfloop>
<cfoutput></label></cfoutput>
<cfoutput>
<script type="text/javascript" src="#application.url.farcry#/js/showhide.js"></script>
</cfoutput>
<cfsetting enablecfoutputonly="false">