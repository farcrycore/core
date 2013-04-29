<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit form for profile --->
<!--- @@description: Accessed throught the overview section of the webtop.  Primary edit handler for users interacting with their own profile. --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfif application.security.checkPermission("SecurityUserManagementTab")>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,avatar,phone,fax,position,department,locale,overviewHome" includeFieldSet="false" />
<cfelse>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,avatar,phone,fax,position,department,locale" includeFieldSet="false" />
</cfif>

<cfsetting enablecfoutputonly="false" />