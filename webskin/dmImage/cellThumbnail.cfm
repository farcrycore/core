<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<cfoutput>
    <img src="#application.fapi.getImageWebRoot()##stObj.thumbnailImage#" style="margin-right: 10px">
</cfoutput>

<cfsetting enablecfoutputonly="false">