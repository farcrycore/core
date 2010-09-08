<cfcomponent displayname="Object Reference" extends="schema" hint="Definition of the refObjects table" output="false">
	<cfproperty name="objectid" type="uuid" dbNullable="false" />
	<cfproperty name="typename" type="string" dbNullable="false" />
	
</cfcomponent>