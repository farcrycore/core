<cfcomponent displayname="FQ Audit" extends="schema" hint="Definition of audit table (deprecated)" output="false">
	<cfproperty name="AuditID" type="uuid" dbNullable="false" dbPrimaryKey="true" />
	<cfproperty name="objectid" type="uuid" dbNullable="true" />
	<cfproperty name="datetimeStamp" type="datetime" dbNullable="true" />
	<cfproperty name="username" type="string" dbNullable="false" />
	<cfproperty name="location" type="string" dbNullable="false" />
	<cfproperty name="auditType" type="string" dbPrecision="50" dbNullable="true" />
	<cfproperty name="note" type="string" dbNullable="true" />
	
</cfcomponent>