<!--- first need to export feed --->
<cfset generate(stargs.objectid)>

<!--- validate --->
<cflocation url="http://feeds.archive.org/validator/check?url=http://#cgi.http_host##application.url.webroot#/rss/#stargs.objectid#.xml" addtoken="no">