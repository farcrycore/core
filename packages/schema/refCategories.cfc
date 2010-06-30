<cfcomponent displayname="Category References" hint="Category-Object associations" extends="schema" output="false">
	<cfproperty name="objectid" type="uuid" dbNullable="false" dbPrimaryKey="true" />
	<cfproperty name="categoryid" type="uuid" dbNullable="false" dbPrimaryKey="true" />
	
</cfcomponent>