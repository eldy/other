
var reqSearch;
var inputSearch='';

function InitializeSearch(){
	try { 
		reqSearch=new ActiveXObject("Msxml2.XMLHTTP");
	} catch(e) {
		try { 
			reqSearch=new ActiveXObject("Microsoft.XMLHTTP");
		} catch(oc) {
			reqSearch=null;
		}
	}
	if(!reqSearch && typeof XMLHttpRequest!="undefined"){
		reqSearch=new XMLHttpRequest();
	}
}
function SendQuerySearch(key){
	if(key!=''){
		inputSearch=key;
		setTimeout("performSearch('" + key + "')",500);
	} else { 
		inputSearch='';
		document.getElementById("searchresults").innerHTML = '';		
		document.getElementById("searchresults").style.display = "none";
	}
} 

function performSearch(key){
	if(key==inputSearch){
		InitializeSearch();
		var url="/search.cgi?Search=" + key;
		if(reqSearch!=null){
			reqSearch.onreadystatechange = ProcessSearch;
			reqSearch.open("GET", url, true);
			reqSearch.send(null);
		}
	}
}
function ProcessSearch(){
	if(reqSearch.readyState == 4) {
		var resultsfound = false;
		if(reqSearch.status == 200) {
			if(reqSearch.responseText!=""){		
				resultsfound = true;
				document.getElementById("searchresults").innerHTML = reqSearch.responseText;
				document.getElementById("searchresults").style.display = "block";
			}
		}
		if(!resultsfound) {
			document.getElementById("searchresults").innerHTML = '<ul><li><i>Sorry, no results found</i></li></ul>';
			document.getElementById("searchresults").style.display = "block";
		}
	}
}
