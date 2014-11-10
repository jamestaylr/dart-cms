window.onload = function() {
    document.getElementById("sidebar").style.height = (window.innerHeight - 55).toString() + "px";
    document.getElementById("content").style.height = (window.innerHeight - 55).toString() + "px";
    document.getElementById("content").style.width = (window.innerWidth - 200).toString() + "px";
    document.getElementById("sidebar").style.visibility = "visible";

};

window.onresize = function(event) {
    document.getElementById("sidebar").style.height = (window.innerHeight - 55).toString() + "px";
    document.getElementById("content").style.height = (window.innerHeight - 55).toString() + "px";
    document.getElementById("content").style.width = (window.innerWidth - 200).toString() + "px";

};