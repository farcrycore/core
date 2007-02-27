<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.url.imageRoot##stobj.thumbnailImage#" alt="#stObj.title#" /></cfoutput>

<cfsetting enablecfoutputonly="false">