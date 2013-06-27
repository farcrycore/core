<cfcomponent displayname="Task Queue" hint="Background task processing settings" extends="forms" output="false" key="taskqueue">

	<cfproperty ftSeq="1" ftFieldset="Task Queue" ftLabel="Maximum Number of Threads"
				name="maxThreads" type="integer" default="1"
				ftHint="Maximum number of simultaneous threads"
				ftHelpSection="By default task processing uses FarCry content types to manage tasks and task results. Both of these are intended to be transitory storage and NOT for long-term storage of queue history. For this reason tasks are removed immedietely on completion, and results are removed either as soon as they are reported to the original user or after the timeout specified below." />
	
	<cfproperty ftSeq="2" ftFieldset="Task Queue" ftLabel="Thread Timeout"
				name="threadTimeout" type="integer" default="15"
				ftHint="Number of minutes to give a thread to complete any single task before killing it. NOTE: this is a lazy process - threads are only checked when new tasks are added to the queue." />
				
	<cfproperty ftSeq="3" ftFieldset="Task Queue" ftLabel="Result Timeout"
				name="resultTimeout" type="integer" default="30"
				ftHint="Number of minutes to leave an unreported result in the database before removing it. NOTE: this is a lazy process - old results are only cleared when new results are added, or there existing results are requested." />
				

</cfcomponent>