<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image --->
<!--- @@author: Matthew Bryant --->

<cfoutput><img src="#getFileLocation(stobject=stObj, fieldname="thumbnailImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">