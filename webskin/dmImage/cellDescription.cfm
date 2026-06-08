<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Image Description Cell --->

<cfoutput>
    #encodeForHTML(stObj.title)#
    <cfif len(stObj.alt)>
        <br><em>#encodeForHTML(stObj.alt)#</em>
    </cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">