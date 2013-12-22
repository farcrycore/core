<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@displayname: Display Thumbnail Image --->

<cfoutput>
<img src="#getFileLocation(stobject=stobj, fieldname="thumbnailImage").path#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stobj.alt)#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stobj.title)#" />
</cfoutput>

<cfsetting enablecfoutputonly="false">