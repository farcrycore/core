<cfcomponent displayname="MFA Challenge" hint="Second factor challenge form for the login interstitial. Shared MFA infrastructure - any credential-owning user directory may return this typename from getMFAForm()." extends="forms" output="false">
	<cfproperty name="code" type="string" default="" hint="Authenticator code or recovery code" ftSeq="1" ftFieldset="" ftLabel="Verification code" ftType="string" ftAutoComplete="one-time-code" />

</cfcomponent>
