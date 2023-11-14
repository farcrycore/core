<cfcomponent extends="farcry.core.proxyApplication" displayname="Application" output="false" hint="Extends proxy which in turn in extends core Application.cfc.">

    <cffunction name="OnRequestStart" access="public" returntype="boolean" output="false">
        <cfargument name="TargetPage" type="string" required="true" />

        <cfset oError = createobject("component","farcry.core.packages.lib.error") />
        <cfset oError.showErrorPage("404 Page missing", oError.create404Error("Bad request"), true) />

        <cfreturn true />
    </cffunction>

</cfcomponent>