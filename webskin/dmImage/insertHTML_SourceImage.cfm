<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Source Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.fapi.getImageWebRoot()##stobj.sourceImage#" alt="#HTMLEditFormat(stObj.title)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">