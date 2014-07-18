<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image --->
<!--- @@author: Matthew Bryant --->

<cfparam name="stObj.title" default="" type="string" />

<cfoutput><img src="#getFileLocation(stObject=stObj,fieldname='thumbnailImage').path#" alt="#HTMLEditFormat(stObj.alt)#" /></cfoutput>

<cfsetting enablecfoutputonly="false">