<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<ft:processform action="undelete" url="refresh">
	<cfset oArchive = application.fapi.getContentType("dmArchive") />
    <cfif structKeyExists(form, "objectid")>
    	<cfloop list="#form.objectid#" index="thisobject">
    		<cftry>
    			<cfset aResult = oArchive.undeleteArchive(archiveID=thisobject) />
			
    			<cfif structkeyexists(aResult[1],"parent")>
    				<skin:bubble message="'#aResult[1].object.label#' has been restored into the tree under '#aResult[1].parent.title#'" tags="dmArchive,info" />
    			<cfelse>
    				<skin:bubble message="'#aResult[1].object.label#' has been restored" tags="dmArchive,info" />
    			</cfif>
			
    			<cfcatch type="undelete">
    				<skin:bubble message="#cfcatch.message#" tags="dmArchive,error" />
    			</cfcatch>
    		</cftry>
    	</cfloop>
    </cfif>
</ft:processform>

<ft:processform action="cascadingundelete" url="refresh">
	<cfset oArchive = application.fapi.getContentType("dmArchive") />
    <cfif structKeyExists(form, "objectid")>
    	<cfloop list="#form.objectid#" index="thisobject">
    		<cftry>
    			<cfset aResult = oArchive.undeleteArchive(archiveID=thisobject,cascade=true) />
			
    			<cfloop from="1" to="#arraylen(aResult)#" index="i">
    				<cfif structkeyexists(aResult[i],"parent")>
    					<skin:bubble message="'#aResult[i].object.label#' has been restored into the tree under '#aResult[i].parent.title#'" tags="dmArchive,info" />
    				<cfelse>
    					<skin:bubble message="'#aResult[i].object.label#' has been restored" tags="dmArchive,info" />
    				</cfif>
    			</cfloop>
			
    			<cfcatch type="undelete">
    				<skin:bubble message="#cfcatch.message#" tags="dmArchive,error" />
    			</cfcatch>
    		</cftry>
    	</cfloop>
    </cfif>    
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

<cfset stButton = structnew() />
<cfset stButton.text = "Cascading Undelete" />
<cfset stButton.value = "cascadingundelete" />
<cfset stButton.permission = "" />
<cfset stButton.onclick = "" />
<cfset stbutton.hint = "Cascade undelete to deleted children and related content">
<cfset arrayappend(aButtons,stButton) />

<cfset sqlWhere = "bDeleted=1" />

<cfif structkeyexists(url,"archivetype")>
	<cfset sqlWhere = sqlWhere & " and objectTypename='#url.archivetype#'" />
	
	<cfif isdefined("application.stCOAPI.#url.archivetype#.displayname")>
		<cfset title = "Undelete #application.stCOAPI[url.archivetype].displayname#" />
	<cfelse>
		<cfset title = "Undelete #url.archiveType#" />
	</cfif>
	
	<cfset stButton = structnew() />
	<cfif structkeyexists(url,"dialogID")>
		<cfset stButton.text = "Close" />
		<cfset stButton.value = "close" />
		<cfset stButton.permission = "" />
		<cfset stButton.onclick = "top.$fc.closeBootstrapModal(); return false;" />
	<cfelse>
		<cfset stButton.text = "Go back" />
		<cfset stButton.value = "goback" />
		<cfset stButton.permission = "" />
		<cfset stButton.onclick = "" />
	</cfif>
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
	lButtons="undelete,cascadingundelete,goback,close" aButtons="#aButtons#"
	bEditCol="false"
	emptymessage="No archives available for undelete"
	lButtonsEmpty="goback,close" />

<cfsetting enablecfoutputonly="false" />