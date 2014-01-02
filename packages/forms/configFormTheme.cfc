<cfcomponent 
	extends="forms"
	displayname="Form Theme Configuration" 
	hint="Configuration for the markup rendering of forms" 
	output="false" key="formtheme">
<!--- 
Currently support themes:
- https://github.com/draganbabic/uni-form/
- http://getbootstrap.com/2.3.2/
 --->
	<cfproperty name="webtop" type="string" required="false" default="bootstrap" 
		ftSeq="10" ftFieldset="Form Theme Properties" ftLabel="Webtop Forms" 
		ftType="list" 
		ftList="bootstrap:Bootstrap 2.3.2+ (by Twitter),uniform:Uni-Form (by Sprawsm)"
		fthint="Form markup for forms used in the webtop.">

	<cfproperty name="site" type="string" required="false" default="uniform" 
		ftSeq="20" ftFieldset="Form Theme Properties" ftLabel="Front End Forms" 
		ftType="list" 
		ftList="bootstrap:Bootstrap 2.3.2+ (by Twitter),uniform:Uni-Form (by Sprawsm)"
		fthint="Form markup for forms used in the front-end web site.">

</cfcomponent>