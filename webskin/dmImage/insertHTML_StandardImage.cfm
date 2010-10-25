<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.fapi.getImageWebRoot()##stobj.standardImage#" alt="#HTMLEditFormat(stObj.title)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">