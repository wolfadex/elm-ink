import * as elmInk from './elm-ink-manual.js'
import { Elm } from './elm.js'

const app = Elm.Main.init({
  flags: Date.now(),
})

elmInk.subscribeToStdin(function (data) {
  if (data === '\x1B' || data === '\u0003') {
    elmInk.exit()
  }

  app.ports.stdin.send(data)
})
