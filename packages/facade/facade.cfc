<cfcomponent name="facade" output="false" hint="facade for flash & flex remoting calls">

	<cffunction name="init" access="public" output="false" returntype="facade" hint="constructor for facade">
		<cfreturn this>
	</cffunction>

	<cffunction name="checkConnection" access="remote" output="false" returntype="boolean" hint="basic boolean return method to check remote connection">
		<cfreturn true>
	</cffunction>

</cfcomponent>