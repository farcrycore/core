<cfsetting enablecfoutputonly="true" />
<!--- @@viewBinding: type --->

<cfparam name="url.left" type="uuid" />
<cfparam name="url.right" type="uuid" />

<cfset stLocal.oProfile = application.fapi.getContentType("dmProfile") />


<cfset stLocal.stLeft = application.fapi.getContentObject(objectid=url.left) />
<cfset stLocal.leftArchive = "" />
<cfif not structkeyexists(stLocal.stLeft,"typename")>
	<cfset stLocal.stLeft = application.fapi.getContentObject(typename="dmArchive",objectid=url.left) />
</cfif>
<cfif stLocal.stLeft.typename eq "dmArchive">
	<cfset stLocal.leftArchive = stLocal.stLeft.objectid />
	<cfwddx action="wddx2cfml" input="#stLocal.stLeft.objectWDDX#" output="stLocal.stLeft" />
	<cfset stLocal.stProfile = stLocal.oProfile.getProfile(username=stLocal.stLeft.createdby) />
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.leftLabel = "#dateformat(stLocal.stLeft.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.stLeft.datetimecreated,'h:mmtt')# - #stLocal.stProfile.firstname# #stLocal.stProfile.lastname#" />
	<cfelse>
		<cfset stLocal.leftLabel = "#dateformat(stLocal.stLeft.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.stLeft.datetimecreated,'h:mmtt')# - #listfirst(stLocal.stLeft.createdby,'_')#" />
	</cfif>
<cfelse>
	<cfset stLocal.stProfile = stLocal.oProfile.getProfile(username=stLocal.stLeft.lastupdatedby) />
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.leftLabel = "#ucase(left(stLocal.stLeft.status,1))##lcase(mid(stLocal.stLeft.status,2,100))# - #stLocal.stProfile.firstname# #stLocal.stProfile.lastname#" />
	<cfelse>
		<cfset stLocal.leftLabel = "#ucase(left(stLocal.stLeft.status,1))##lcase(mid(stLocal.stLeft.status,2,100))# - #listfirst(stLocal.stLeft.lastupdatedby,'_')#" />
	</cfif>
</cfif>

<cfset stLocal.stRight = application.fapi.getContentObject(objectid=url.right) />
<cfset stLocal.rightArchive = "" />
<cfif not structkeyexists(stLocal.stRight,"typename")>
	<cfset stLocal.stRight = application.fapi.getContentObject(typename="dmArchive",objectid=url.right) />
</cfif>
<cfif stLocal.stRight.typename eq "dmArchive">
	<cfset stLocal.rightArchive = stLocal.stRight.objectid />
	<cfwddx action="wddx2cfml" input="#stLocal.stRight.objectWDDX#" output="stLocal.stRight" />
	<cfset stLocal.stProfile = stLocal.oProfile.getProfile(username=stLocal.stRight.createdby) />
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.rightLabel = "#dateformat(stLocal.stRight.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.stRight.datetimecreated,'h:mmtt')# - #stLocal.stProfile.firstname# #stLocal.stProfile.lastname#" />
	<cfelse>
		<cfset stLocal.rightLabel = "#dateformat(stLocal.stRight.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.stRight.datetimecreated,'h:mmtt')# - #listfirst(stLocal.stRight.createdby,'_')#" />
	</cfif>
<cfelse>
	<cfset stLocal.stProfile = stLocal.oProfile.getProfile(username=stLocal.stRight.lastupdatedby) />
	<cfif structkeyexists(stLocal.stProfile,"lastname") and len(stLocal.stProfile.lastname)>
		<cfset stLocal.rightLabel = "#ucase(left(stLocal.stRight.status,1))##lcase(mid(stLocal.stRight.status,2,100))# - #stLocal.stProfile.firstname# #stLocal.stProfile.lastname#" />
	<cfelse>
		<cfset stLocal.rightLabel = "#ucase(left(stLocal.stRight.status,1))##lcase(mid(stLocal.stRight.status,2,100))# - #listfirst(stLocal.stRight.lastupdatedby,'_')#" />
	</cfif>
</cfif>

<cfset stLocal.stResults = application.fc.lib.diff.performObjectDiff(stLocal.stLeft,stLocal.stRight) />
<cfset stLocal.qMetadata = application.types[stLocal.stLeft.typename].qMetadata />
<cfquery dbtype="query" name="stLocal.qMetadata">
	SELECT 		distinct propertyname, ftSeq
	FROM 		stLocal.qMetadata
	ORDER BY 	ftSeq
</cfquery>

<cfoutput>
	<p>#stLocal.stResults.countDifferent# propert<cfif stLocal.stResults.countDifferent eq 1>y<cfelse>ies</cfif> changed.</p><br>
	<table width="100%" class="diff-items">
		<tr>
			<th style="font-weight:bold;">Property</th>
			<th style="font-weight:bold;">
				#stLocal.leftLabel#
				<cfif len(stLocal.leftArchive)>
					[<a href="##" class="rollback" rel="#stLocal.leftArchive#">rollback</a>]
				<cfelseif stLocal.stLeft.status eq "draft">
					[<a href="##" class="discarddraft" rel="#stLocal.stLeft.objectid#">discard</a>]
				</cfif>
			</th>
			<th style="font-weight:bold;">
				#stLocal.rightLabel#
				<cfif len(stLocal.rightArchive)>
					[<a href="##" class="rollback" rel="#stLocal.rightArchive#">rollback</a>]
				<cfelseif stLocal.stRight.status eq "draft">
					[<a href="##" class="discarddraft" rel="#stLocal.stRight.objectid#">discard</a>]
				</cfif>
			</th>
		</tr>
</cfoutput>
<cfif stLocal.stResults.countDifferent gt 0>
	<cfset countprops = 0 />
	<cfloop query="stLocal.qMetadata">
		<cfif structkeyexists(stLocal.stResults,stLocal.qMetadata.propertyname) and stLocal.stResults[stLocal.qMetadata.propertyname].different>
			<cfset countprops = countprops + 1 />
			<cfoutput>
				<tr<cfif countprops mod 2 eq 1> style="background-color:##f8f8f8;"</cfif>>
					<td width="20%" valign="top" style="padding:3px;">#stLocal.stResults[stLocal.qMetadata.propertyname].label#</td>
					<td width="40%" valign="top" class="property-value" style="font-size:12px;white-space:pre-wrap;padding:3px;">#stLocal.stResults[stLocal.qMetadata.propertyname].leftHighlighted#</td>
					<td width="40%" valign="top" class="property-value" style="font-size:12px;white-space:pre-wrap;padding:3px;">#stLocal.stResults[stLocal.qMetadata.propertyname].rightHighlighted#</td>
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
<cfelse>
	<cfoutput><tr><td colspan="3">No changes</td></tr></cfoutput>
</cfif>
<cfoutput></table></cfoutput>

<cfsetting enablecfoutputonly="false" />