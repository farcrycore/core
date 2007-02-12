<cfcomponent name="fourq_test" output="false" extends="farcry.farcry_core.packages.types.types" hint="Test component to ensure that the fourq persistence layer works correctly.">

	<!--- TODO: Create a set of properties that allows for testing of _all_ the capabilities of the fourq system --->
	<cfproperty type="string" name="foo" default="bar" required="true" />
	<cfproperty type="array" name="arraytest" arrayProps="fname:string;lname:string;age:numeric;" required="true" />
</cfcomponent>