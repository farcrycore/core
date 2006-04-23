<cfoutput>
<h3>Acceptable file types are:</h3>
<p><cfloop list="#application.config.file.filetype#" index="i">#listlast(i, '/')#<cfif not listlast(application.config.file.filetype) eq i>,</cfif></cfloop></p>
<h3>Maximum file size is:</h3><p>#application.config.file.filesize/1024#kb</p></cfoutput>