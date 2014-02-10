<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Display Standard Image --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfoutput><img src="#getFileLocation(stobject=stObj, fieldname="standardImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.title)#"></cfoutput>

<cfsetting enablecfoutputonly="false">