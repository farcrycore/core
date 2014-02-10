<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Display Source Image --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfoutput><img src="#getFileLocation(stobject=stObj, fieldname="sourceImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.title)#"></cfoutput>

<cfsetting enablecfoutputonly="false">