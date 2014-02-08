<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Page --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:view objectid="#stObj.objectid#" typename="#stObj.typename#" template="displayHeaderStandard" />

<skin:breadcrumb separator=" / ">

<skin:view typename="#stObj.typename#" objectid="#stObj.objectid#" webskin="#url.bodyView#" />

<skin:view objectid="#stObj.objectid#" typename="#stObj.typename#" template="displayFooterStandard" />

<cfsetting enablecfoutputonly="false">