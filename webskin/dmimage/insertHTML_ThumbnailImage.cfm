<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.url.webroot##stobj.thumbnailImage#" alt="#stObj.title#" /></cfoutput>

<cfsetting enablecfoutputonly="false">