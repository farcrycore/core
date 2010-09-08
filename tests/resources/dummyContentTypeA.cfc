<cfcomponent displayname="Dummy Content Type A" extends="farcry.core.packages.types.types" hint="Contains various properties for testing of metadata generation" output="false">
	<cfproperty name="a" type="array" />
	<cfproperty name="b" type="array" arrayProps="q:string;r:numeric;s:boolean;t:datetime" />
	<cfproperty name="c" type="array" />
	
	<cfproperty name="d" type="boolean" />
	<cfproperty name="e" type="datetime" dbIndex="Y_index" />
	<cfproperty name="f" type="datetime" dbNullable="true" />
	<cfproperty name="g" type="numeric" />
	<cfproperty name="h" type="numeric" dbPrecision="8,0" />
	<cfproperty name="i" type="string" default="hello" />
	<cfproperty name="j" type="string" required="false" />
	<cfproperty name="k" type="string" dbPrecision="100" />
	<cfproperty name="l" type="uuid" />
	<cfproperty name="m" type="longchar" />
	
	
</cfcomponent>