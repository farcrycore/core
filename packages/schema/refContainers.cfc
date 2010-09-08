<cfcomponent displayname="Object-Container Reference" extends="schema" hint="Definition of the refContainers table" output="false">
	<cfproperty name="objectid" type="uuid" dbNullable="false" dbPrimaryKey="true" />
	<cfproperty name="containerid" type="uuid" dbNullable="false" dbPrimaryKey="true" />
	
</cfcomponent>