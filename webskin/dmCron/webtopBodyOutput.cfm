<cfsetting enablecfoutputonly="true">
<!--- @@fuAlias: output --->

<!--- task output renders as a document, in a tokenless sandboxed frame so it stays isolated from the webtop --->
<!--- the frame inherits no styling, so the base css is linked inside the document itself --->
<cfset outputStyle = '<link rel="stylesheet" href="#application.url.webtop#/css/taskoutput.css">' />

<cfoutput><iframe class="fc-task-output" title="Last execution output" sandbox srcdoc="#encodeForHTMLAttribute(outputStyle & stObj.lastExecutionOutput)#"></iframe></cfoutput>

<cfsetting enablecfoutputonly="false">