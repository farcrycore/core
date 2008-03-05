<cfoutput><!--- form validation --->
<script type="text/javascript">
<!--//
// initialize the qForm object
objForm = new qForm("editform");
qFormAPI.errorColor="##cc6633";
// make these fields required
//objForm.required("title");

// check whether has a title field or name field or label field, as they are used place of each other
if(objForm.title)
	objTitle = objForm.title
else if(objForm.name)
	objTitle = objForm.name
else if(objForm.label)
	objTitle = objForm.label

if(objTitle){
	objTitle.validateNotNull("#application.rb.getResource("pleaseEnterTitle")#");
	objTitle.validateNotEmpty("#application.rb.getResource("pleaseEnterTitle")#");
}

//-->
</script></cfoutput>