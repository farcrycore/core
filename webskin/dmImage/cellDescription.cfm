<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<cfoutput>
    #stObj.title#
    <cfif len(stObj.alt)>
        <br><em>#stObj.alt#</em>
    </cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">