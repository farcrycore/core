<cfcomponent displayname="CDN Direct Upload Configuration" hint="Direct browser-to-bucket upload settings" extends="forms" output="false" key="directupload">

	<cfproperty ftSeq="1" ftFieldset="Pending Uploads" ftLabel="Maximum Uploads In Progress"
				name="maxPending" type="integer" default="32"
				ftHint="Most uploads one session may have signed but not yet finalized. A sign request beyond this is refused rather than cancelling an upload already in flight."
				ftHelpSection="A direct upload is signed just before its file is sent, so this bounds how many files a session can have in flight at once, not how many it can upload in total. Raise it only if a project genuinely uploads more files simultaneously than the default allows." />

	<cfproperty ftSeq="2" ftFieldset="Pending Uploads" ftLabel="Finalize Grace"
				name="graceMinutes" type="integer" default="10"
				ftHint="Extra minutes an upload may be finalized for after the signing policy window closes. Covers a file that finished sending just before its policy expired." />

	<cfproperty ftSeq="3" ftFieldset="Pending Uploads" ftLabel="Retry Window"
				name="replayMinutes" type="integer" default="10"
				ftHint="Minutes a completed upload's response is kept so a repeated finalize returns the same result instead of recording the file twice. After this the upload is reported as already used." />

</cfcomponent>
