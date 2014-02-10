<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Source Image --->
<!--- @@author: Matthew Bryant --->

<cfoutput><img src="#getFileLocation(stobject=stObj, fieldname="sourceImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">