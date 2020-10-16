<cfcomponent extends="farcry.core.packages.forms.forms" displayName="Scheduled Tasks" hint="Settings for control of scheduled tasks" key="tasks">

	<cfproperty name="bEnabled" type="boolean" required="true" default="true"
		ftSeq="1" ftWizardStep="" ftFieldset="" ftLabel="Enabled scheduled tasks"
		ftHint="Disable in order to turn off automatic execution of tasks in this instance. Running from the webtop will still work.">

	<cfproperty name="executionKey" type="string" required="false"
		ftSeq="2" ftWizardStep="" ftFieldset="" ftLabel="Execution key"
		ftHint="If specified, this key is added to the Lucee scheduled task URL, and the tasks themselves only run if it is in the URL and correct. Use this to ensure that tasks are not executed from external services or other environments.">

</cfcomponent>