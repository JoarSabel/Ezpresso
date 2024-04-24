// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

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
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let hooks = {
  canvas: {
    updated() {
      // TODO: Clean this mess up, hella bloat-y
      let canvas = this.el;
      let ctx = canvas.getContext("2d");
      // Calculate size based on viewport dimensions
      var sizeWidth = 100 * window.innerWidth / 100;
      var sizeHeight = 70 * window.innerHeight / 100 || 766;

      // Set the canvas width and height
      canvas.width = sizeWidth;
      canvas.height = sizeHeight;
      ctx.lineWidth = 3;
      ctx.strokeStyle = "red";
    }, 
    mounted() {
      // TODO: Clean this mess up, hella bloat-y
      let canvas = this.el;
      let ctx = canvas.getContext("2d");
      // Calculate size based on viewport dimensions
      var sizeWidth = 100 * window.innerWidth / 100;
      var sizeHeight = 70 * window.innerHeight / 100 || 766;

      // Set the canvas width and height
      canvas.width = sizeWidth;
      canvas.height = sizeHeight;
      ctx.lineWidth = 3;
      ctx.strokeStyle = "red";
      let isActive = false;
      let plots = [];

      canvas.addEventListener('mousedown', startDraw, false);
      canvas.addEventListener('mousemove', draw, false);
      canvas.addEventListener('mouseup', endDraw, false);

      function startDraw(e) {
        isActive = true;
      }

      function draw(e) {
        if (!isActive) return;
        let rect = canvas.getBoundingClientRect();
        let x = e.clientX - rect.left - window.scrollX;
        let y = e.clientY - rect.top - window.scrollY;
        plots.push({ x: x, y: y });
        drawOnCanvas(plots);
      }

      function endDraw(e) {
        isActive = false;
        plots = [];
      }

      function drawOnCanvas(plots) {
        ctx.beginPath();
        ctx.moveTo(plots[0].x, plots[0].y);
        for (let i = 1; i < plots.length; i++) {
          ctx.lineTo(plots[i].x, plots[i].y);
        }
        ctx.stroke();
      }
    }
  },
  clear_canvas_button: {
    mounted() {
      this.el.addEventListener("click", () => {
        let canvas = document.getElementById("presentation_canvas");
        let ctx = canvas.getContext("2d");
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      });
    }
  }
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

