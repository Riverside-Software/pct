// Overridable file to define external link
function getCustomHyperlink (d) {
    if (d.startsWith("Progress.")){
        return '<a href="https://documentation.progress.com/output/ua/OpenEdge_latest/index.html#page/dvref/' +
            d.toLowerCase() +
            '-class.html" target="_blank">' +
            d +
            "</a>";
     }
     if (d.startsWith("Telerik.")){
        return '<a href="https://docs.telerik.com/devtools/winforms/api/' +
            d.toLowerCase() +
            '.html" target="_blank">' +
            d +
            "</a>";
     }
     if (d.startsWith("System.")){
        return '<a href="http://msdn.microsoft.com/en-us/library/' +
            d.toLowerCase() +
            '(v=vs.80).aspx" target="_blank">' +
            d +
            "</a>";
     }
     if (d.startsWith("Infragistics.")){

     	let packageElem = d.toLowerCase().split('.');
		let package = '';
		if(packageElem.length > 3)
    		package = packageElem[2];
        return '<a href="https://www.infragistics.com/help/winforms/infragistics.win.' +
            package + '~' + d.toLowerCase() +
            '.html" target="_blank">' +
            d +
            "</a>";
     }


     return null;
} 