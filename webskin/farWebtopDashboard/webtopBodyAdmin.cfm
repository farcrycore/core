<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Webtop Dashboard Admin Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfoutput>
	<div class="alert alert-info">
		<i class="fa fa-info-circle"></i> Note: When creating a new dashboard you must restart the application
		before the dashboard will be visible to webtop users.
	</div>
</cfoutput>

<ft:objectadmin 
	typename="farWebtopDashboard"
	title="Webtop Dashboard Admin"
	columnList="title,lRoles,lCards,datetimelastUpdated"
	sortableColumns="title,datetimelastUpdated"
	lFilterFields="title"
	sqlorderby="title" />


<cfsetting enablecfoutputonly="true">