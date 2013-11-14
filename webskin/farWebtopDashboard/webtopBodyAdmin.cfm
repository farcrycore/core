
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Webtop Dashboard Admin" />

<ft:objectadmin 
	typename="farWebtopDashboard"
	title="Webtop Dashboard Admin"
	columnList="title,lRoles,lCards,datetimelastUpdated"
	sortableColumns="title,datetimelastUpdated"
	lFilterFields="title"
	sqlorderby="title" />

<admin:footer />