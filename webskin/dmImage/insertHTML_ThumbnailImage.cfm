<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.fapi.getImageWebRoot()##stobj.thumbnailImage#" alt="#HTMLEditFormat(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">