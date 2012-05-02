<cfcomponent hint="An example of an event listener" output="false">

	<cffunction name="dummyEvent" access="public" hint="Append this event to an event queue in the request scope">
		<cfargument name="randomNumber" type="numeric" required="false" hint="Random data for some unit test assertions">
		
		<cfset var stEvent = { eventName="dummyEvent", eventParams=arguments }>
		
		<cfparam name="request._dummy_events_queue" type="array" default="#arrayNew(1)#">
		
		<cfset arrayAppend(request._dummy_events_queue,stEvent)>
		
	</cffunction>

	<cffunction name="clearEvents" access="public" hint="Clear the event queue that dummyEvent uses">
		<cfset request._dummy_events_queue = arrayNew(1)>
	</cffunction>
	
</cfcomponent>
