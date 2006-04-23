<!--- This is a test case object which has no purpose other 
than to demonstrate and test the capabilities of the system. --->
<cfcomponent extends="types" displayname="testobject">
	<!--- This property will have a form field created for it, but it will not be 
	added to the database. The addToDb attribute determines if a column will be
	created by the deploy method of 4q, and if data will be added to the database
	by the processForm method of object. The most common use of this attribute is
	for file uploads where the result of processing is added to the database, but 
	not necessarily with the same name as the property. This could also be used when
	2 or more properties are combined to form a single database entry. --->
	<cfproperty name="noDBEntry" type="string" addToDb="false">
	<!--- This property has a validationtype attribute. This will cause a javascript
	validation function call to be generated in the output from the edit method. --->
	<cfproperty name="title" type="string" validationtype="required" validationmessage="You must enter a value for the name">
	<!--- This property has a createFormField attribute which is set to false. This suppresses form field
	creation. If there is a default attribute it will be evaluated by the processForm method and added to 
	the database. The createFormField attribute would also be used without a default value
	if the value of the property was created from another property. For example, a news article
	may have 4 properties. imagefile, originalimagepath, optimizedimagepath, thumbnailimagepath. 
	only imagefile would generate a form field. It would also have addToDb set to false. 
	The other 3 properties would have createFormField set to false, but they would be created
	by the processField method of the image property. --->
	<cfproperty name="author" type="string" createFormField="false" default="getAuthUser()">
	<!--- This property must exist for all objects and is used as the primary key
	for the database table for this type --->
	<cfproperty name="objectid" type="uuid" required="true">
	<!--- This property demonstrates specifying a custom 
	method to create the form field for editing and some
	parameters which are passed to the edit method --->
	<cfproperty name="bodytext" type="longchar" editmethod="richedit" editprops="width:300;height:400">
</cfcomponent>