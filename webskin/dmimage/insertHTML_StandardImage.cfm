<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.url.webroot##stobj.standardImage#" alt="#stObj.title#" /></cfoutput>

<cfsetting enablecfoutputonly="false">