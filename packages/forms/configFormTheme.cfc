<cfcomponent displayname="Form Theme Configuration" hint="Configuration for the markup rendering of forms" extends="forms" output="false" key="formtheme">

<!--- form theme properties --->
	<cfproperty ftSeq="1" ftFieldset="Form Theme Properties" name="webtop" type="string" default="bootstrap" hint="???" ftLabel="Webtop" ftType="string" />
	<cfproperty ftSeq="2" ftFieldset="Form Theme Properties" name="site" type="string" default="uniform" hint="???" ftLabel="Site" ftType="string" />
	
</cfcomponent>