<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<ft:processform action="undelete" url="refresh">
	<cfset oArchive = application.fapi.getContentType("dmArchive") />
	<cfloop list="#form.objectid#" index="thisobject">
		<cftry>
			<cfset stResult = oArchive.undeleteArchive(archiveID=thisobject) />
			
			<cfif structkeyexists(stResult,"parent")>
				<skin:bubble message="'#stArchive.label#' has been restored into the tree under '#stResult.parent.title#'" tags="dmArchive,info" />
			<cfelse>
				<skin:bubble message="'#stArchive.label#' has been restored" tags="dmArchive,info" />
			</cfif>
			
			<cfcatch type="undelete">
				<skin:bubble message="#cfcatch.message#" tags="dmArchive,error" />
			</cfcatch>
		</cftry>
	</cfloop>
</ft:processform>

<ft:processform action="goback">
	<cflocation url="?id=#url.id#" addtoken="false">
</ft:processform>


<cfset title = "Undelete Content" />

<cfset aButtons = arraynew(1) />

<cfset stButton = structnew() />
<cfset stButton.text = "Undelete" />
<cfset stButton.value = "undelete" />
<cfset stButton.permission = "" />
<cfset stButton.onclick = "" />
<cfset arrayappend(aButtons,stButton) />

<cfset sqlWhere = "bDeleted=1" />

<cfif structkeyexists(url,"archivetype")>
	<cfset sqlWhere = sqlWhere & " and objectTypename='#url.archivetype#'" />
	
	<cfif isdefined("application.stCOAPI.#url.archivetype#.displayname")>
		<cfset title = "Undelete #application.stCOAPI[url.archivetype].displayname#" />
	<cfelse>
		<cfset title = "Undelete #url.archiveType#" />
	</cfif> />

	<cfset stButton = structnew() />
	<cfset stButton.text = "Go back" />
	<cfset stButton.value = "goback" />
	<cfset stButton.permission = "" />
	<cfset stButton.onclick = "" />
	<cfset arrayappend(aButtons,stButton) />
</cfif>

<ft:objectadmin 
	typename="dmArchive"
	title="#title#"
	columnList="label,objectTypename,username,datetimecreated" 
	sortableColumns="label,objecttypename,username,datetimecreated"
	lFilterFields="label,objecttypename,username"
	sqlorderby="datetimecreated desc"
	sqlwhere="#sqlWhere#"
	lButtons="undelete,goback" aButtons="#aButtons#"
	bEditCol="false"
	emptymessage="No archives available for undelete"
	lButtonsEmpty="goback" />

<cfsetting enablecfoutputonly="false" />