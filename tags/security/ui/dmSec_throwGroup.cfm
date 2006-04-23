<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_throwGroup.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
Gets a dmSec error and throws it.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSec_throwGroup.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.1.1.1  2002/08/22 07:18:02  geoff
no message

Revision 1.1  2001/11/15 11:09:56  matson
no message

Revision 1.1  2001/09/20 17:34:57  matson
first import


|| END FUSEDOC ||
--->
<!--- populate the errors --->
<!--- this should be in the database in the end --->

<cfif thistag.executionMode eq "Start">

	<cfset request.dmSec.throw.CollectErrors="1">
	<cfset request.dmSec.throw.errorCollection="">
	
<cfelse>

	<cfif len(request.dmSec.throw.errorCollection) gt 0>
		<cfthrow message="#request.dmSec.throw.errorCollection#" type="dmSec" errorcode="dmSec_generic">
	</cfif>
	
	<cfset request.dmSec.throw.CollectErrors="0">
	<cfset request.dmSec.throw.errorCollection="">
	
</cfif>

<cfsetting enablecfoutputonly="No">