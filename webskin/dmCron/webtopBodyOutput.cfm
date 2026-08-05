<cfsetting enablecfoutputonly="true">
<!--- @@fuAlias: output --->

<!--- task output renders as a document, in a tokenless sandboxed frame so it stays isolated from the webtop --->
<cfoutput><iframe class="fc-task-output" title="Last execution output" sandbox srcdoc="#encodeForHTMLAttribute(stObj.lastExecutionOutput)#"></iframe></cfoutput>

<cfsetting enablecfoutputonly="false">