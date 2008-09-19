<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit user within the context of profile --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<cfset stPropValues = structnew() />
<cfset stPropValues.userdirectory = "CLIENTUD" />

<ft:object stObject="#stObj#" typename="farUser" lfields="userid,password,userstatus,aGroups" stPropValues="#stPropValues#" legend="Security" />

<cfsetting enablecfoutputonly="false" />