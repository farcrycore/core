<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<nj:delete>
<cfparam name="objectid" default="UNKNOWN">
<cfsetting enablecfoutputonly="No">
<script type="text/javascript"><cfoutput>
// reload the default content page
window.location = "#application.url.farcry#/inc/content_overview.html?sec=site";</cfoutput>
</script>
