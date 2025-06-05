<cfcomponent 
	displayname="FarCry Login Specific Log" 
	hint="Manages FarCry Login Events" 
	extends="types" output="false" 
	bRefObjects="false" fuAlias="fc-session-log" bObjectBroker="0" bSystem="true" bArchive="false"
	icon="fa-list">

  

	<cfproperty name="event" type="string" default="" 
		ftSeq="1" ftFieldset="" ftLabel="Event" 
		ftType="string"
		hint="The event this log item is associated with (login, logout, sessionEnd)">

	<cfproperty name="profileID" type="uuid" default="" 
		ftSeq="2" ftFieldset="" ftLabel="profile" 
		ftType="uuid" ftJoin="dmProfile">

	<cfproperty name="ipaddress" type="string" default="" 
		ftSeq="3" ftFieldset="" ftLabel="IP address" 
		ftType="string"
		hint="IP address of user">

	<cfproperty name="jsonProfile" type="json" default="" 
		ftSeq="4" ftFieldset="" ftLabel="Object type" 
		ftType="json"
		hint="a snapshot of the profile at the time of the event">

</cfcomponent>