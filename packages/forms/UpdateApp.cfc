<cfcomponent displayname="Update App" hint="Provides a granular way to update parts of the application state" extends="forms" output="false">
	<cfproperty name="webtop" type="boolean" default="0" hint="Reload webtop data" ftSeq="1" ftFieldset="" ftLabel="Webtop" ftType="boolean" />
	
	<cffunction name="process" access="public" output="true" returntype="struct" hint="Performs application refresh according to options selected">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<!--- Webtop reload --->
		<cfif structkeyexists(arguments.fields,"webtop") and arguments.fields.webtop>
			<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
		</cfif>
		
		<cfreturn arguments.fields />
	</cffunction>
</cfcomponent>