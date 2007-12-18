<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />

<farcry:farcryInit 
	name="[siteName]"
	projectURL="[projectURL]" 
	dsn="[appDSN]"
	dbType="[dbType]" 
	plugins="[plugins]" />

<cfsetting enablecfoutputonly="false">