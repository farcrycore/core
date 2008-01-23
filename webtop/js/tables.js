var backgroundColor = '#F9E6D4';
function setRowBackground (childCheckbox) {
var row = childCheckbox.parentNode;
while (row && row.tagName.toLowerCase() != 'tr') {
row = row.parentNode;
}
if (row && row.style) {
if (childCheckbox.checked) {
row.style.backgroundColor = backgroundColor;
}
else {
row.style.backgroundColor = '';
}
}
}
window.onload=function(){tableruler();}