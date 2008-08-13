<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: dmNavigation Library Selected --->
<!--- @@author: Jeff Coughlin (jeff [at] jeffcoughlin [dot] com)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Change me if desired --->
<cfset myDelimeter = ">" />

<cfsavecontent variable="dmNavigationLibrarySelectedHead">
<cfoutput>
<style type="text/css" media="all">
  div.librarySelect { display: block; clear: both; margin: 5px 0; }
  div.librarySelect h2 { margin: 0; padding: 0; }
  div.librarySelect span { clear: left; font-size: .95em; color: ##555; }
</style>
</cfoutput>
</cfsavecontent>

<skin:htmlHead id="dmNavigationLibrarySelectedHead" text="#variables.dmNavigationLibrarySelectedHead#" />

<cfif listFindNoCase("Root,Images,Files,Trash", stObj.label) is false>
  <cfset qAncestors = application.factory.oTree.getAncestors(objectid=stObj.objectid, bIncludeSelf=true) />
  <cfset lAncestorNames = valuelist(qAncestors.objectName, myDelimeter) />
  <cfif listLen(lAncestorNames, myDelimeter) gte 1 and listGetAt(lAncestorNames, 1, myDelimeter) eq "Root">
    <cfset lAncestorNames = listDeleteAt(lAncestorNames, 1, myDelimeter) />
  </cfif>

  <!--- (optional) Now change all ">" symbols to the string "&gt;" --->
  <cfset lAncestorNames = replace(lAncestorNames, ">", "&gt;", "all") />

  <cfoutput>
  <div class="librarySelect">
    <h2>#stObj.label#</h2>
    <span>#lAncestorNames#</span>
  </div>
  </cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />