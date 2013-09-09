<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Default Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="dmFile"
	columnList="title,datetimelastUpdated,status"
	sortableColumns="title,datetimelastUpdated,status"
	lFilterFields="title,catFile"
	sqlOrderBy="datetimelastUpdated DESC" />

<cfsetting enablecfoutputonly="false">