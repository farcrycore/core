<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Changes --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfset stLocal.otherVersion = structnew() />
<cfset stLocal.approvedVersion = structnew() />
<cfset stLocal.defaultLeft = "" />
<cfset stLocal.defaultRight = "" />
<cfif stObj.status eq "approved">
	<cfset stLocal.approvedVersion = stObj />
	<cfset stLocal.qOtherVersions = application.fapi.getContentObjects(typename=stObj.typename,lProperties="objectid,status",versionID_eq=stObj.objectid) />
	<cfif stLocal.qOtherVersions.recordcount>
		<cfset stLocal.otherVersion = getData(objectid=stLocal.qOtherVersions.objectid[1]) />
		<cfset stLocal.defaultRight = stLocal.otherVersion.objectid />
		<cfset stLocal.defaultLeft = stLocal.approvedVersion.objectid />
	<cfelse>
		<cfset stLocal.defaultRight = stLocal.approvedVersion.objectid />
	</cfif>
<cfelse>
	<cfset stLocal.otherVersion = stObj />
	<cfset stLocal.defaultRight = stLocal.otherVersion.objectid />
	<cfif len(stObj.versionID)>
		<cfset stLocal.approvedVersion = getData(objectid=stObj.versionid) />
		<cfset stLocal.defaultRight = stLocal.otherVersion.objectid />
		<cfset stLocal.defaultLeft = stLocal.approvedVersion.objectid />
	</cfif>
</cfif>

<cfif not structisempty(stLocal.approvedVersion)>
	<cfset stLocal.qArchives = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,datetimecreated",archiveID_eq=stLocal.approvedVersion.objectid,orderBy="datetimecreated desc") />
	<cfif stLocal.qArchives.recordcount and not len(stLocal.defaultLeft)>
		<cfset stLocal.defaultLeft = stLocal.qArchives.objectid[1] />
	</cfif>
<cfelse>
	<cfset stLocal.qArchives = querynew("empty") />
</cfif>

<skin:onReady><cfoutput>
	var diffURL = "#application.fapi.getLink(type='#stObj.typename#',view='webtopDiffResult',urlParameters='left=NEWLEFT&right=NEWRIGHT&ajaxmode=1')#";
	var currentLeft = "#stLocal.defaultLeft#";
	var currentRight = "#stLocal.defaultRight#";
	
	function updateResults(){
		$j("##diff-results").load(diffURL.replace("NEWLEFT",currentLeft).replace("NEWRIGHT",currentRight));
	};
	
	$j("##diff-left").bind("change",function(){
		currentLeft = $j(this).val();
		updateResults();
	});
	$j("##diff-right").bind("change",function(){
		currentRight = $j(this).val();
		updateResults();
	});
	
	updateResults();
</cfoutput></skin:onReady>

<cfoutput>
	<table width="100%">
		<tr>
			<td width="20%" style="font-weight:bold;">Property</td>
			<td width="40%" style="font-weight:bold;">
				Compare
				<select name="left" id="diff-left">
					<cfif not structisempty(stLocal.otherVersion)><option value="#stLocal.otherVersion.objectid#"<cfif stLocal.otherVersion.objectid eq stLocal.defaultLeft> selected</cfif>>#stLocal.otherVersion.status#</option></cfif>
					<cfif not structisempty(stLocal.approvedVersion)><option value="#stLocal.approvedVersion.objectid#"<cfif stLocal.approvedVersion.objectid eq stLocal.defaultLeft> selected</cfif>>#stLocal.approvedVersion.status#</option></cfif>
					<cfloop query="stLocal.qArchives">
						<option value="#stLocal.qArchives.objectid#"<cfif stLocal.qArchives.objectid eq stLocal.defaultLeft> selected</cfif>>#timeformat(stLocal.qArchives.datetimecreated,"hh:mmtt")#, #dateformat(stLocal.qArchives.datetimecreated,"dd mmm yyyy")#</option>
					</cfloop>
				</select>
			</td>
			<td width="40%" style="font-weight:bold;">
				to
				<select name="right" id="diff-right">
					<cfif not structisempty(stLocal.otherVersion)><option value="#stLocal.otherVersion.objectid#"<cfif stLocal.otherVersion.objectid eq stLocal.defaultRight> selected</cfif>>#stLocal.otherVersion.status#</option></cfif>
					<cfif not structisempty(stLocal.approvedVersion)><option value="#stLocal.approvedVersion.objectid#"<cfif stLocal.approvedVersion.objectid eq stLocal.defaultRight> selected</cfif>>#stLocal.approvedVersion.status#</option></cfif>
					<cfloop query="stLocal.qArchives">
						<option value="#stLocal.qArchives.objectid#"<cfif stLocal.qArchives.objectid eq stLocal.defaultRight> selected</cfif>>#timeformat(stLocal.qArchives.datetimecreated,"hh:mmtt")#, #dateformat(stLocal.qArchives.datetimecreated,"dd mmm yyyy")#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>
	
	<div id="diff-results"></div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />