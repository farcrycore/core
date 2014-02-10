<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Image --->
<!--- @@author: Matthew Bryant --->

<cfoutput><img src="#getFileLocation(stobject=stObj, fieldname="standardImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">