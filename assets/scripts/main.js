function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i <ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
};
if (getCookie("unn_session")!="") {
    document.getElementById("isLogged").innerHTML = "Estas logueado! :D"
} else { document.getElementById("isLogged").innerHTML = "Probablemente no estas logueado" };

let OpenMenu = true;
let Options = ["Home","My Profile","Search","Play"]
function click() {
    document.getElementById("menu").style.width = (OpenMenu && "50px" || "200px")
    let count;
    for (count=1;count<5;count++) {
        console.log(count)
        document.getElementById(`hboption${count}`).innerHTML = (OpenMenu && `<img src="/assets/images/hboption${count}.png" style="max-width: 100%;max-height: 100%;height: auto;">` || Options[count-1])
    }
    OpenMenu = !OpenMenu
}
document.getElementById("hamburgerbutton").addEventListener("click",click)
click()