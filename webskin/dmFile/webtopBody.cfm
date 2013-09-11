<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Files Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="dmFile"
	title="Document Library"
	columnList="title,status,datetimecreated,datetimelastupdated,documentDate"
	sortableColumns="title,status,datetimecreated,datetimelastupdated,documentDate"
	lFilterFields="title,catFile"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">