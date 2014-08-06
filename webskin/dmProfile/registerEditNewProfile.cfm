<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset stPropMetadata = structNew()>
<cfset stPropMetadata.firstName.ftLabelAlignment = "block" />
<cfset stPropMetadata.lastname.ftLabelAlignment = "block" />
<cfset stPropMetadata.emailAddress.ftLabelAlignment = "block" />

<ft:object objectid="#stobj.objectid#" typename="dmProfile" lfields="firstName,lastname,emailAddress" stPropMetadata="#stPropMetadata#"/>