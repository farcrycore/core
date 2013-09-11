<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Files Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="dmFile"
	columnList="title,status,datetimecreated,datetimelastupdated"
	sortableColumns="title,status,datetimecreated,datetimelastupdated"
	lFilterFields="title,catFile"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">