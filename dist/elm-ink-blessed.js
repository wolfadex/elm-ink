var blessed = require("blessed");

var screen = blessed.screen({
  smartCSR: true,
});
screen.key(["escape", "q", "C-c"], function (ch, key) {
  return process.exit(0);
});

// An Ink <-> Blessed node wrapper
class InkNode {
  constructor(type, ...args) {
    this._type = type;
    this._attributes = [];

    switch (type) {
      case "TEXT":
        this._box = blessed.box({
          content: args[0],
          width: "100%",
          height: "10%",
          style: {
            fg: "white",
            bg: "green", // Blue background so you see this is different from body
          },
        });
        break;
      case "body":
        this._box = blessed.box({
          width: "100%",
          height: "10%",
        });
        screen.append(this._box);
        break;
      case "elm-ink-column":
        this._box = blessed.layout({
          width: "100%",
          height: "100%",
          style: {
            fg: "white",
            bg: "red", // Blue background so you see this is different from body
          },
        });
        break;
      case "elm-ink-textinput":
        this._box = blessed.textbox({
          width: "100%",
          height: "10%",
          keys: true,
          mouse: true,
          inputOnFocus: true,
          style: {
            fg: "white",
            bg: "blue", // Blue background so you see this is different from body
          },
        });
        // this._box.on("submit", function (input) {
        //   portIn.send({
        //     action: "INPUT",
        //     handlerId: el.handlerId,
        //     data: input,
        //   });
        // });
        break;
      default:
        console.log("UNKNOWN NODE TYPE", type);
    }
    this._box._elmInkNode = this;
    // this._box.on("remove", () => {
    //   console.log("removed!!!!!", this._type);
    // });
  }

  get nodeType() {
    switch (this._type) {
      case "TEXT":
        return 3;
      default:
        return -1;
    }
  }

  get childNodes() {
    return [...this._box.children.map((box) => box._elmInkNode)];
  }

  get length() {
    return this._box.content.length;
  }

  get parentNode() {
    return this._box.parent._elmInkNode;
  }

  get attributes() {
    return this._attributes;
  }

  get tagName() {
    return this._type;
  }

  // setAttribute(val) {
  //   this._box.setValue(val);
  // }

  addEventListener(key, callback) {
    this._box.on(key, callback);
  }

  appendChild(node) {
    this._box.append(node._box);
    renderDocument();
  }

  insertBefore(node, ref) {
    this._box.insertBefore(node._box, ref._box);
    renderDocument();
  }

  replaceData(offset, length, newData) {
    this._data = newData;
    renderDocument();
  }

  replaceChild(newNode, oldNode) {
    if (newNode._box.parent === this._box) {
      newNode.detach();
    }
    this._box.insertAfter(newNode._box, oldNode._box);
    this._box.remove(oldNode._box);
    // render(newNode._type, newNode.con, oldNode._type);
    renderDocument();
  }

  render() {
    switch (this._type) {
      case "TEXT":
        return this._data;
    }
  }
}

// The base Ink Document
class InkDocument {
  constructor() {
    this._body = new InkNode("body");
  }

  get body() {
    return this._body;
  }

  createElement(...args) {
    return new InkNode(...args);
  }

  createTextNode(...args) {
    return new InkNode("TEXT", ...args);
  }

  get title() {
    return this._title;
  }

  set title(newTitle) {
    this._title = newTitle;
    screen.title = newTitle;
  }
}

document = new InkDocument();

function renderDocument() {
  //   // screen.clearRegion(0, 0, 1000, 1000);
  screen.render();
  //   if (toLog.length > 0) {
  //     // console.log("toLog", ...toLog);
  //   }
  // document.body.children;
  // process.stdout.write(
  //   [ansiEscapes.cursorHide, ansiEscapes.clearScreen()].join("")
  // );
}
