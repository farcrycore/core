<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Display Thumbnail Image --->

<cfparam name="stParam.class" default="">

<cfoutput><img class="#stparam.class#" src="#getFileLocation(stobject=stObj, fieldname="thumbnailImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.title)#"></cfoutput>

<cfsetting enablecfoutputonly="false">