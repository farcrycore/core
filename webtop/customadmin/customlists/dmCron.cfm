<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<admin:header />

<ft:processform action="Run Task">
	<cfset stCron = createobject("component",application.stCOAPI.dmCron.packagepath).display(objectid=form.selectedobjectid) />
</ft:processform>

<ft:objectadmin 
	typename="dmCron"
	title="Scheduled Tasks Administration"
	columnList="title,datetimelastUpdated,lastupdatedby"   
	sortableColumns="title,datetimelastUpdated,lastupdatedby"
	lFilterFields="title"
	sqlorderby="datetimelastUpdated desc"
	lCustomActions="Run Task" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />