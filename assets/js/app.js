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
    // Get the current URL
    var currentUrl = document.location.href;
    console.log(currentUrl)
    // Use the URL constructor to parse the URL
    var urlObject = new URL(currentUrl);

    // Get the pathname from the URL object
    var pathname = urlObject.pathname;

    // Split the pathname by '/' to get an array of path components
    var pathComponents = pathname.split('/');

    // The todo id is the third component in this case
    var todoId = pathComponents[2];

    // Log or use the extracted todo id as needed
    console.log("Todo ID:", todoId);

    // Check if todoId is not null or undefined before using it
    if (todoId) {
      console.log('Todo ID:', todoId);
      let socket = new Socket("/socket", {params: {token: window.userToken}})

      socket.connect()

      let channel = socket.channel(`room:${todoId}`, {})

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
        channel.push("title_input_value", {body: titleInput.value})
      })
        
      descInput.addEventListener("input", event => {
        console.log(descInput.value)
        channel.push("desc_input_value", {body: descInput.value})
      })

      statusInput.addEventListener("input", event => {
        console.log(statusInput.value)
        channel.push("status_input_value", {body: statusInput.value})
      })

      categoryInput.addEventListener("input", event => {
        console.log(categoryInput.value)
        channel.push("category_input_value", {body: categoryInput.value})
      })

      likeInput.addEventListener("input", event => {
        console.log(likeInput.checked)
        // console.log(likeInput.value)
        channel.push("like_input_value", {body: likeInput.checked})
      })
        
      channel.on("title_input_value", payload => {
        titleInput.value = `${payload.body}`
      })
        
      channel.on("desc_input_value", payload => {
        descInput.value = `${payload.body}`
      })

      channel.on("status_input_value", payload => {
        statusInput.value = `${payload.body}`
      })

      channel.on("category_input_value", payload => {
        categoryInput.value = `${payload.body}`
      })

      channel.on("like_input_value", payload => {
        likeInput.value = payload.body
        likeInput.checked = payload.body
      })
    } else {
      console.error('Todo ID not found in the URL.');
    }   
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

