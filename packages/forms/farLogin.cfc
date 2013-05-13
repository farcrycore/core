<cfcomponent displayname="Farcry UD Login" hint="The login form for the Farcry User Directory" extends="forms" output="false" fuAlias="login">
	<cfproperty name="username" type="string" default="" hint="The user login" ftSeq="1" ftFieldset="" ftLabel="Username" ftType="string" />
	<cfproperty name="password" type="string" default="" hint="The login password" ftSeq="2" ftFieldset="" ftLabel="Password" ftType="password" ftRenderType="enterpassword" />
	
</cfcomponent>