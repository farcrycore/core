<cfcomponent displayname="MFA Enrolment" hint="Second factor enrolment confirmation form (scan the QR code, then prove one valid code). Shared MFA infrastructure." extends="forms" output="false">
	<cfproperty name="code" type="string" default="" hint="The first code from the authenticator app, confirming enrolment" ftSeq="1" ftFieldset="" ftLabel="Confirmation code" ftType="string" ftAutoComplete="one-time-code" ftIgnorePasswordManager="true" />
	<cfproperty name="emailcode" type="string" default="" hint="The one-time code emailed during email OTP enrolment" ftSeq="2" ftFieldset="" ftLabel="Email code" ftType="string" ftAutoComplete="one-time-code" ftIgnorePasswordManager="true" />

</cfcomponent>
