<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Image Description Cell --->

<cfoutput>
    #stObj.title#
    <cfif len(stObj.alt)>
        <br><em>#stObj.alt#</em>
    </cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">