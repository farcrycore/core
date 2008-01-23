<cfsetting enablecfoutputonly="true" />
<!--- Same as index.cfm except allows passing the display method in --->

<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />

<cfparam name="url.method" default="" />

<nj:display method="#url.method#" lmethods="#url.method#">

<cfsetting enablecfoutputonly="false" />