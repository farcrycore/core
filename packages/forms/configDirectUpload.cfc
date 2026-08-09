<cfcomponent displayname="CDN Direct Upload Configuration" hint="Direct browser-to-bucket upload settings" extends="forms" output="false" key="directupload">

	<cfproperty ftSeq="1" ftFieldset="Signing" ftLabel="Upload Signing Key"
				name="signingKey" type="string" ftDefault="generateSecretKey('AES',256)" ftDefaultType="Evaluate"
				ftHint="Signs the authorization a direct upload carries from its sign request to its finalize request. Generated on first use, so nothing has to be configured for uploads to work."
				ftHelpSection="Every node that might answer a finalize has to hold the same key, which the generated default satisfies by living with the rest of this configuration. Set FARCRY_CONFIG_DIRECTUPLOAD_SIGNINGKEY to supply it from the environment instead, keeping it out of the database and its backups. Changing it means an upload in flight at that moment has to be repeated." />

	<cfproperty ftSeq="2" ftFieldset="Signing" ftLabel="Finalize Grace"
				name="graceMinutes" type="integer" default="10"
				ftHint="Extra minutes an upload may be finalized for after the signing policy window closes. Covers a file that finished sending just before its policy expired." />

</cfcomponent>
