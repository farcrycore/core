<cfparam name="attributes.objectId">
<cfparam name="attributes.complete" default="1">

<cfoutput>

<script>
if( window.opener && window.opener.parent ) theparent=window.opener.parent;
	else theparent=parent;

theparent["treeFrame"].getObjectDataAndRender( '#attributes.objectId#' );

<Cfif attributes.complete eq 1>
if( window.opener && window.opener.parent ) window.close();
	else theparent["editFrame"].location="#application.url.farcry#/navajo/complete.cfm";
</CFIF>
</script>

</cfoutput>