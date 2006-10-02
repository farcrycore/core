

<cfcomponent extends="field" name="arrayList" displayname="string" hint="Field component to liase with all arrayList types"> 
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.arrayList" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
</cfcomponent> 