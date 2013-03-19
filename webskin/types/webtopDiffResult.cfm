<cfsetting enablecfoutputonly="true" />
<!--- @@viewBinding: type --->

<cfparam name="url.left" type="uuid" />
<cfparam name="url.lefttype" type="string" />
<cfparam name="url.leftseq" type="numeric" />
<cfparam name="url.right" type="uuid" />
<cfparam name="url.righttype" type="string" />
<cfparam name="url.rightseq" type="numeric" />


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stLocal.stLeft = application.fapi.getContentObject(typename=url.lefttype,objectid=url.left) />
<cfset stLocal.stRight = application.fapi.getContentObject(typename=url.righttype,objectid=url.right) />

<!--- Older item on the left --->
<cfif url.rightseq gt url.leftseq>
	<cfset stLocal.tmp = stLocal.stLeft />
	<cfset stLocal.stLeft = stLocal.stRight />
	<cfset stLocal.stRight = stLocal.tmp />
	
	<cfset stLocal.tmp = url.left />
	<cfset url.left = url.right />
	<cfset url.right = stLocal.tmp />
	
	<cfset stLocal.tmp = url.lefttype />
	<cfset url.lefttype = url.righttype />
	<cfset url.righttype = stLocal.tmp />
	
	<cfset stLocal.tmp = url.leftseq />
	<cfset url.leftseq = url.rightseq />
	<cfset url.rightseq = stLocal.tmp />
</cfif>

<!--- Extract archives --->
<cfif stLocal.stLeft.typename eq "dmArchive">
	<cfwddx action="wddx2cfml" input="#stLocal.stLeft.objectWDDX#" output="stLocal.stLeftData" />
<cfelse>
	<cfset stLocal.stLeftData = stLocal.stLeft />
</cfif>
<cfif stLocal.stRight.typename eq "dmArchive">
	<cfwddx action="wddx2cfml" input="#stLocal.stRight.objectWDDX#" output="stLocal.stRightData" />
<cfelse>
	<cfset stLocal.stRightData = stLocal.stRight />
</cfif>

<!--- Differences --->
<cfset stLocal.stResults = application.fc.lib.diff.getObjectDiff(stLocal.stLeftData,stLocal.stRightData) />
<cfset stLocal.qMetadata = application.types[stLocal.stLeftData.typename].qMetadata />
<cfquery dbtype="query" name="stLocal.qMetadata">
	SELECT 		distinct propertyname, ftSeq
	FROM 		stLocal.qMetadata
	ORDER BY 	ftSeq
</cfquery>

<cfoutput>
	<script type="text/javascript">
		diff.left = #url.leftseq#;
		diff.right = #url.rightseq#;
	</script>
	<table width="100%" class="diff-items">
		<thead>
			<tr>
				<th class="diff-item-label">&nbsp;</th>
				<th class="diff-item-value diff-label diff-item-left"><cfif structkeyexists(stLocal.stLeft,"status")>#application.fapi.getResource("workflow.constants.#stLocal.stLeft.status#@label",stLocal.stLeft.status)#<cfelse>#application.fapi.getResource("coapi.dmArchive.constants.older@label","Older")#</cfif></th>
				<th class="diff-item-divider">&nbsp;</th>
				<th class="diff-item-value diff-label diff-item-right"><cfif structkeyexists(stLocal.stRight,"status")>#application.fapi.getResource("workflow.constants.#stLocal.stRight.status#@label",stLocal.stRight.status)#<cfelse>#application.fapi.getResource("coapi.dmArchive.constants.newer@label","Newer")#</cfif></th>
			</tr>
			<tr>
				<th class="diff-item-label">&nbsp;</th>
				<th class="diff-item-value diff-item-teaser diff-item-left" rel="#stLocal.stLeft.objectid#">
					<cfif stLocal.stLeft.typename eq "dmArchive">
						<skin:view stObject="#stLocal.stLeft#" webskin="displayTeaserStandard" mode="display" />
					<cfelse>
						<skin:view typename="dmArchive" webskin="displayTeaserStandard" mode="display" liveObject="#stLocal.stLeft#" />
					</cfif>
				</th>
				<th class="diff-item-divider">&nbsp;</th>
				<th class="diff-item-value diff-item-teaser diff-item-right" rel="#stLocal.stRight.objectid#">
					<cfif stLocal.stRight.typename eq "dmArchive">
						<skin:view stObject="#stLocal.stRight#" webskin="displayTeaserStandard" mode="display" />
					<cfelse>
						<skin:view typename="dmArchive" webskin="displayTeaserStandard" mode="display" liveObject="#stLocal.stRight#" />
					</cfif>
				</th>
			</tr>
		</thead>
		<tbody>
</cfoutput>
<cfif stLocal.stResults.countDifferent gt 0>
	<cfset countprops = 0 />
	<cfloop query="stLocal.qMetadata">
		<cfif structkeyexists(stLocal.stResults,stLocal.qMetadata.propertyname) and stLocal.stResults[stLocal.qMetadata.propertyname].different>
			<cfset countprops = countprops + 1 />
			<cfoutput>
				<cfif countprops mod 2 eq 1><tr class="alt"><cfelse><tr></cfif>
					<td class="diff-item-label">#stLocal.stResults[stLocal.qMetadata.propertyname].label#</td>
					<td class="diff-item-value" >#stLocal.stResults[stLocal.qMetadata.propertyname].leftHighlighted#</td>
					<td class="diff-item-divider">&nbsp;</td>
					<td class="diff-item-value">#stLocal.stResults[stLocal.qMetadata.propertyname].rightHighlighted#</td>
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
<cfelse>
	<cfoutput><tr><td colspan="5">No changes</td></tr></cfoutput>
</cfif>
<cfoutput></tbody></table></cfoutput>

<cfsetting enablecfoutputonly="false" />