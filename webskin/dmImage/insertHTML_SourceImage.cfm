<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Source Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#getFileLocation(stObject=stObj,fieldname='sourceImage').path#" alt="#HTMLEditFormat(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">