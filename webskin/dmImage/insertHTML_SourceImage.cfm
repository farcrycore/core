<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Source Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#application.fapi.getImageWebRoot()##stobj.sourceImage#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">