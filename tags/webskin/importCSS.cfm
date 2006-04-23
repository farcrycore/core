<cfsetting enablecfoutputonly="yes" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/importCSS.cfm,v 1.17 2005/10/28 03:24:54 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:24:54 $
$Name: milestone_3-0-0 $
$Revision: 1.17 $

|| DESCRIPTION || 
Import CSS for templates based on site tree

|| DEVELOPER ||
Geoff Bowers (modius@daemon.com.au)
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: type (import or link)
out:
--->

<!--- optional attributes --->
<cfparam name="attributes.type" default="import" />


<!--- get style sheets --->
<cfscript>
	// get navigation elements to root
	qAncestors = request.factory.oTree.getAncestors(objectid=request.navid, bIncludeSelf=true);
	// create query
	qStylesheets = queryNew("filename,mediaType");
</cfscript>

<!--- loop through and determine which ones have CSS objects --->
<cfloop query="qAncestors">
	<!--- check for style sheet --->
	<cfquery datasource="#application.dsn#" name="qCheck">
	SELECT dmCSS.objectid, dmCSS.filename, dmCSS.mediaType, dmCSS.bThisNodeOnly, dmnav.objectid as callerObjectID
	FROM #application.dbowner#dmCSS dmCss, #application.dbowner#dmNavigation_aObjectIDs dmnav
	WHERE 
		dmCSS.objectid = dmnav.data
		AND dmnav.objectid = '#qAncestors.objectid#'
		AND dmCSS.label != '(incomplete)'
	ORDER BY dmnav.seq
	</cfquery>

	<!--- append css to list --->
	<cfif qCheck.recordcount>
		<cfloop query="qCheck">
			<cfif qCheck.bThisNodeOnly eq false OR qCheck.callerObjectID eq request.navid>
				<cfset temp = queryAddRow(qStylesheets, 1) />
				<cfset temp = querySetCell(qStylesheets, "filename", qCheck.filename) />
				<cfset temp = querySetCell(qStylesheets, "mediaType", qCheck.mediaType) />
			</cfif>
		</cfloop>
	</cfif>
</cfloop>


<cfif qStylesheets.recordcount>
  <!--- Check if custom media type is used at all --->
  <cfset bUseCustomMediaTypes = false />
  <cfloop query="qStylesheets">
    <cfif qStylesheets.mediaType neq ''>
      <cfset bUseCustomMediaTypes = true />
      <cfbreak />
    </cfif>
  </cfloop>
	<cfif attributes.type eq "import">
	  <cfif bUseCustomMediaTypes is false>
	    <cfoutput><!-- FOUC'd hack -->#chr(13)##chr(10)#<script type="text/javascript"> </script>#chr(13)##chr(10)#</cfoutput>
	  </cfif>
		<cfoutput><style type="text/css"<cfif bUseCustomMediaTypes is false> media="all"</cfif>>#chr(13)##chr(10)#</cfoutput>
		<!--- loop through style sheets and import --->	
		<cfloop query="qStylesheets">
      <cfoutput>@import url("#application.url.webroot#/css/#qStylesheets.filename#")<cfif mediaType neq ''> #qStylesheets.mediaType#<cfelseif bUseCustomMediaTypes is true> all</cfif>;#chr(13)##chr(10)#</cfoutput>
		</cfloop>
		<cfoutput></style>#chr(13)##chr(10)#</cfoutput>
	<cfelse>
		<!--- loop through style sheets and link --->
		<cfloop query="qStylesheets">
			<cfoutput><link rel="stylesheet" type="text/css"<cfif qStylesheets.mediaType neq ''> media="#qStylesheets.mediaType#"</cfif> href="#application.url.webroot#/css/#qStylesheets.filename#" />#chr(13)##chr(10)#</cfoutput>
		</cfloop>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no" />