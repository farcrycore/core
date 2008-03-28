<cfparam name="url.showdraft" default="0" />
<cfparam name="url.flushcache" default="0" />

<!--- We need to simply reloacate to the download page. --->
<cflocation url="#application.url.webroot#/download.cfm?downloadfile=#stobj.objectid#&typename=#stobj.typename#&fieldname=filename&showdraft=#url.showdraft#&flushcache=#url.flushcache#" addtoken="false" />