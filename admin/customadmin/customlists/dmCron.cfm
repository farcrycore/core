<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<admin:header />

<ft:processform action="Run Task">
<cfdump var="#form#">
</ft:processform>

<ft:objectadmin 
	typename="dmCron"
	permissionset="news"
	title="Scheduled Tasks Administration"
	columnList="label,datetimelastUpdated,lastupdatedby"   
	sortableColumns="label,datetimelastUpdated,lastupdatedby"
	lFilterFields="label"
	sqlorderby="datetimelastUpdated desc"
	lCustomActions="Run Task" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />