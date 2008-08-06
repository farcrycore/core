<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Outputs the reset options --->

<cfset request.mode.ajax = true />

<cfset options = "" />
<cfloop collection="#application.stCOAPI.UpdateApp.stProps#" item="thisprop">
	<cfif not listcontainsnocase("datetimecreated,createdby,label,lastupdatedby,ObjectID,datetimelastupdated,lockedBy,locked,ownedby",thisprop)>
		<cfset options = listappend(options,'{ "label": "#application.stCOAPI.UpdateApp.stProps[thisprop].metadata.ftLabel#", "name": "#thisprop#" }') />
	</cfif>
</cfloop>

<cfoutput>{ "options": [ #options# ] }</cfoutput>

<cfsetting enablecfoutputonly="false" />