// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
//import "./user_socket.js"
// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// let socket = new Socket("/socket", {params: {token: window.userToken}})

// socket.connect()

// let channel = socket.channel("room:lobby", {})

// console.log("Hitting on every route")

// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })


let Hooks = {}
Hooks.ChannelJoin = {
  mounted(){
    let socket = new Socket("/socket", {params: {token: window.userToken}})

    socket.connect()

    let channel = socket.channel("room:lobby", {})

    console.log("Hitting on every route")

    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
    
    let titleInput = document.querySelector("#title-input")
    let descInput = document.querySelector("#desc-input")
    let statusInput = document.querySelector("#status-input")
    let categoryInput = document.querySelector("#category-input")
    let likeInput = document.querySelector("#like-input")
      
    titleInput.addEventListener("input", event => {
      console.log(titleInput.value)
      channel.push("new_msg", {body: titleInput.value})
    })
      
    descInput.addEventListener("input", event => {
      console.log(descInput.value)
       channel.push("new_msg2", {body: descInput.value})
    })

    statusInput.addEventListener("input", event => {
      console.log(statusInput.value)
       channel.push("new_msg3", {body: statusInput.value})
    })

    categoryInput.addEventListener("input", event => {
      console.log(categoryInput.value)
       channel.push("new_msg4", {body: categoryInput.value})
    })

    likeInput.addEventListener("input", event => {
      console.log(likeInput.value)
       channel.push("new_msg5", {body: likeInput.value})
    })
      
    channel.on("new_msg", payload => {
      titleInput.value = `${payload.body}`
    })
      
    channel.on("new_msg2", payload => {
      descInput.value = `${payload.body}`
    })

    channel.on("new_msg3", payload => {
      statusInput.value = `${payload.body}`
    })

    channel.on("new_msg4", payload => {
      categoryInput.value = `${payload.body}`
    })

    channel.on("new_msg5", payload => {
      console.log(payload)
      //likeInput.checked = !likeInput.checked  // `${payload.body}`
    })
      
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

