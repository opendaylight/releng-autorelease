//Div Toggling Logic
var curDivType = window.location.hash.substr(1);
$(".singleElementDisplay").css({'display' : 'none'});

if(curDivType==="" || curDivType===null || (curDivType!==null && curDivType!=="version_skew" && curDivType!="dependency")) {
  curDivType = "dependency"
}

$("#"+curDivType).css({'display' : 'block'});

function changeDiv ( changeDivTo ){
  $("#"+curDivType).css({'display': 'none'});
  $("#"+changeDivTo).css({'display': 'block'});
  curDivType = changeDivTo;
}
