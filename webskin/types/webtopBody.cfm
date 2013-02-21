<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Default Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="#url.typename#"
	columnList="label,datetimelastupdated,datetimecreated"
	sortableColumns="label,datetimelastupdated,datetimecreated"
	lFilterFields="label"
	sqlOrderBy="datetimecreated DESC" />


<cfsetting enablecfoutputonly="false">