<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Mobile Page --->
<!--- @@author: Justin Carter (justin@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="mobileHeaderStandard" pageTitle="#stObj.label#" />

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="#url.bodyView#" />

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="mobileFooterStandard" />

<cfsetting enablecfoutputonly="false">