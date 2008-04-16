<cfcomponent displayname="Form Spam Protection Configuration" hint="Configuration of the form spam protection that can be attached to a farcry button" extends="forms" output="false" key="formProtection">
	<cfproperty ftSeq="10" ftFieldset="Mouse Movement" name="mouseMovement" type="boolean" default="true" hint="Tests the distance the mouse travels" ftLabel="Test mouse movement" />
	<cfproperty ftSeq="11" ftFieldset="Mouse Movement" name="mouseMovementPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	
	<cfproperty ftSeq="20" ftFieldset="Used Keyboard" name="usedKeyboard" type="boolean" default="true" hint="Tests if the user used the key board" ftLabel="Test used keyboard" /> 
	<cfproperty ftSeq="21" ftFieldset="Used Keyboard" name="usedKeyboardPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	
	<cfproperty ftSeq="30" ftFieldset="Timed Form Submission" name="timedFormSubmission" type="boolean" default="true" hint="Tests the time taken for the form submission" ftLabel="Test timed form submission" />
	<cfproperty ftSeq="31" ftFieldset="Timed Form Submission" name="timedFormPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	<cfproperty ftSeq="32" ftFieldset="Timed Form Submission" name="timedFormMinSeconds" type="integer" default="5" ftLabel="Minimum Seconds" hint="The minimum number of seconds for the form submission" />
	<cfproperty ftSeq="33" ftFieldset="Timed Form Submission" name="timedFormMaxSeconds" type="integer" default="3600" ftLabel="Maximum Seconds" hint="The maximum number of seconds for the form submission" />
		
	<cfproperty ftSeq="40" ftFieldset="Hidden Form Field" name="hiddenFormField" type="boolean" default="true" hint="Tests if a hidden form field is populated" ftLabel="Test hidden form field" />
	<cfproperty ftSeq="41" ftFieldset="Hidden Form Field" name="hiddenFieldPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	
	<cfproperty ftSeq="50" ftFieldset="Akismet" name="akismet" type="boolean" default="false" hint="Tests for spam using Akismet service" ftLabel="Test using Akismet service" />
	<cfproperty ftSeq="51" ftFieldset="Akismet" name="akismetPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	<cfproperty ftSeq="52" ftFieldset="Akismet" name="akismetAPIKey" type="string" ftLabel="Akismet API Key" hint="The Akismet APIKey" />
	<cfproperty ftSeq="53" ftFieldset="Akismet" name="akismetBlogURL" type="string" ftLabel="Akismet Blog URL" hint="The Akismet Blog URL" />
	<cfproperty ftSeq="54" ftFieldset="Akismet" name="akismetFormNameField" type="string" ftLabel="Akismet Form Name Field" hint="The Akismet Form Name Field" />
	<cfproperty ftSeq="55" ftFieldset="Akismet" name="akismetFormEmailField" type="string" ftLabel="Akismet Form Email Field" hint="The Akismet Form Email Field" />
	<cfproperty ftSeq="56" ftFieldset="Akismet" name="akismetFormURLField" type="string" ftLabel="Akismet Form URL Field" hint="The Akismet Form URL Field" />
	<cfproperty ftSeq="57" ftFieldset="Akismet" name="akismetFormBodyField" type="string" ftLabel="Akismet Form Body Field" hint="The Akismet Form Body Field" />

	<cfproperty ftSeq="60" ftFieldset="Too many URLs" name="tooManyUrls" type="boolean" default="true" hint="Tests the number of urls submitted in the form post" ftLabel="Test too many Urls" />
	<cfproperty ftSeq="61" ftFieldset="Too many URLs" name="tooManyUrlsPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	<cfproperty ftSeq="62" ftFieldset="Too many URLs" name="tooManyUrlsMaxUrls" type="integer" default="6" ftLabel="Maximim URLs" hint="The maximum number of urls allowed in the post" />

	<cfproperty ftSeq="70" ftFieldset="Test Strings" name="teststrings" type="boolean" default="true" hint="Tests for spam based on list of strings" ftLabel="Test Strings" />
	<cfproperty ftSeq="71" ftFieldset="Test Strings" name="spamStringPoints" type="integer" default="true" hint="Points that will be assigned if test fails" ftLabel="Failure Points" />
	<cfproperty ftSeq="72" ftFieldset="Test Strings" name="spamstrings" type="longchar" ftLabel="Spam Strings" hint="The list of spam strings that will flag a post as spam" 
		ftDefault="free music,download music,music downloads,viagra,phentermine,viagra,tramadol,ultram,prescription soma,cheap soma,cialis,levitra,weight loss,buy cheap" />

	<cfproperty ftSeq="100" ftFieldset="Failure Settings" name="failureLimit" type="integer" default="3" hint="The total points that will flag a post as spam" ftLabel="Failure Limit" />
	
	<cfproperty ftSeq="110" ftFieldset="Logging" name="logFailedTests" type="boolean" default="1" ftLabel="Log Failed Tests" hint="Log the results of a failed test" />
	<cfproperty ftSeq="111" ftFieldset="Logging" name="showSpamInfoBubble" type="boolean" default="1" ftLabel="Show Spam Info Bubble" hint="Display bubble with the failed results information." />	
	<cfproperty ftSeq="112" ftFieldset="Logging" name="logFile" type="string" default="form-protection-log" ftLabel="Log File Name" hint="Name of the log file in CF Administrator. The Project name will be appended." />

	<cfproperty ftSeq="120" ftFieldset="Failure Email Settings" name="emailFailedTests" type="boolean" default="0" ftLabel="Email Failed Tests" hint="Email the results of a failed test" />
	<cfproperty ftSeq="121" ftFieldset="Failure Email Settings" name="emailServer" type="string" default="" ftLabel="Email Server" hint="emailServer" />
	<cfproperty ftSeq="122" ftFieldset="Failure Email Settings" name="emailUserName" type="string" default="" ftLabel="Email User Name" hint="emailUserName" />
	<cfproperty ftSeq="123" ftFieldset="Failure Email Settings" name="emailPassword" type="string" default="" ftLabel="Email Password" hint="emailPassword" />
	<cfproperty ftSeq="124" ftFieldset="Failure Email Settings" name="emailFromAddress" type="string" default="" ftLabel="Email From Address" hint="emailFromAddress" />
	<cfproperty ftSeq="125" ftFieldset="Failure Email Settings" name="emailToAddress" type="string" default="" ftLabel="Email To Address" hint="emailToAddress" />
	<cfproperty ftSeq="126" ftFieldset="Failure Email Settings" name="emailSubject" type="string" default="" ftLabel="Email Subject" hint="emailSubject" />

	
</cfcomponent>