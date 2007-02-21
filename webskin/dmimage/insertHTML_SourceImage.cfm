<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Source Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.url.webroot##stobj.sourceImage#" alt="#stObj.title#" /></cfoutput>

<cfsetting enablecfoutputonly="false">