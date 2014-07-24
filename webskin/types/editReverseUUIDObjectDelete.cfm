
<!--- @@viewStack: data --->
<!--- @@mimeType: json --->
<!--- @@Viewbinding: object --->



<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset stResult = delete(stobj.objectid) />

<cfoutput>#serializeJSON(stResult)#</cfoutput>
