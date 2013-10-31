<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: dmNavigation Library Selected --->
<!--- @@author: Jeff Coughlin (jeff [at] jeffcoughlin [dot] com)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Change me if desired --->
<cfset myDelimeter = " > " />

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
    <span>#stObj.label#</span><br>
    <span class="muted">#lAncestorNames#</span>
  </div>
  </cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />