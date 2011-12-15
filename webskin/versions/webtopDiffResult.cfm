<cfsetting enablecfoutputonly="true" />
<!--- @@viewBinding: type --->

<cfparam name="url.left" type="uuid" />
<cfparam name="url.right" type="uuid" />

<cfset stLocal.stLeft = application.fapi.getContentObject(objectid=url.left) />
<cfif not structkeyexists(stLocal.stLeft,"typename")>
	<cfset stLocal.stLeft = application.fapi.getContentObject(typename="dmArchive",objectid=url.left) />
</cfif>
<cfif stLocal.stLeft.typename eq "dmArchive">
	<cfwddx action="wddx2cfml" input="#stLocal.stLeft.objectWDDX#" output="stLocal.stLeft" />
</cfif>

<cfset stLocal.stRight = application.fapi.getContentObject(objectid=url.right) />
<cfif not structkeyexists(stLocal.stRight,"typename")>
	<cfset stLocal.stRight = application.fapi.getContentObject(typename="dmArchive",objectid=url.right) />
</cfif>
<cfif stLocal.stRight.typename eq "dmArchive">
	<cfwddx action="wddx2cfml" input="#stLocal.stRight.objectWDDX#" output="stLocal.stRight" />
</cfif>

<cfset stLocal.stResults = application.fc.lib.diff.performObjectDiff(stLocal.stLeft,stLocal.stRight) />
<cfset stLocal.qMetadata = application.types[stLocal.stLeft.typename].qMetadata />
<cfquery dbtype="query" name="stLocal.qMetadata">
	SELECT 		distinct propertyname, ftSeq
	FROM 		stLocal.qMetadata
	ORDER BY 	ftSeq
</cfquery>


<cfif stLocal.stResults.countDifferent eq 0>
	<cfoutput><p>No changes.</p></cfoutput>
<cfelse>
	<cfoutput><p>#stLocal.stResults.countDifferent# propert<cfif stLocal.stResults.countDifferent eq 1>y<cfelse>ies</cfif> changed.</p><table width="100%"></cfoutput>
	<cfloop query="stLocal.qMetadata">
		<cfif structkeyexists(stLocal.stResults,stLocal.qMetadata.propertyname) and stLocal.stResults[stLocal.qMetadata.propertyname].different>
			<cfoutput>
				<tr>
					<td width="20%" valign="top" style="font-weight:bold;">#stLocal.stResults[stLocal.qMetadata.propertyname].label#</td>
					<td width="40%" valign="top" style="font-size:12px;white-space:pre-wrap;">#stLocal.stResults[stLocal.qMetadata.propertyname].leftHighlighted#</td>
					<td width="40%" valign="top" style="font-size:12px;white-space:pre-wrap;">#stLocal.stResults[stLocal.qMetadata.propertyname].rightHighlighted#</td>
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
</cfif>
<cfoutput></table></cfoutput>

<cfsetting enablecfoutputonly="false" />