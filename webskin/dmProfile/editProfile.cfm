<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit form for profile --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,phone,fax,position,department,locale" includeFieldSet="false" />

<cfsetting enablecfoutputonly="false" />