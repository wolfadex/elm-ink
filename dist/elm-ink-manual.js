import ansiEscapes from "ansi-escapes";
import yoga from "yoga-layout-prebuilt";
import stringWidth from "string-width";
import cliBoxes from "cli-boxes";

process.stdin.setRawMode(true);
process.stdin.resume();
process.stdin.setEncoding("utf-8");
var val;
process.stdin.on("data", function (data) {
  val = data.toString();

  if (val === "\x1B" || val === "\u0003") {
    process.stdin.setRawMode(true);
    process.exit(0);
  }
});

// An Ink <-> Blessed node wrapper
class InkNode {
  constructor(type, ...args) {
    this._type = type;
    this._children = [];
    this._attributes = {};

    switch (type) {
      case "TEXT":
        this._data = args[0];
        this._yogaNode = yoga.Node.create();
        this._yogaNode.setHeight(1);
        this._yogaNode.setWidth(stringWidth(this._data));

        break;
      case "body":
        this._yogaNode = yoga.Node.create();
        break;
      case "elm-ink-column":
        this._yogaNode = yoga.Node.create();
        this._yogaNode.setFlexDirection(yoga.FLEX_DIRECTION_COLUMN);
        break;
      case "elm-ink-textinput":
        break;
      default:
        console.log("UNKNOWN NODE TYPE", type);
    }
  }

  get nodeType() {
    switch (this._type) {
      case "TEXT":
        return 3;
      default:
        return 1;
    }
  }

  get childNodes() {
    return this._children;
  }

  // get length() {
  //   // return this._box.content.length;
  // }

  get parentNode() {
    return this._parent;
  }

  get attributes() {
    return Object.entries(this._attributes);
  }

  get tagName() {
    return this._type;
  }

  setAttribute(key, val) {
    this._attributes[key] = val;
  }

  // addEventListener(key, callback) {
  //   // this._box.on(key, callback);
  // }

  appendChild(node) {
    this._children.push(node);
    // console.log("node", node);
    this._yogaNode.insertChild(node._yogaNode, this._yogaNode.getChildCount());
    // console.log("append", this._type, this._yogaNode.getChild(0));
    node._parent = this;
    // console.log("this?\n\n", globalThis.document.body, "\n\n", this);
    renderDocument();
  }

  insertBefore(node, ref) {
    if (ref == null) {
      this._children.push(node);
      this._yogaNode.insertChild(
        node._yogaNode,
        this._yogaNode.getChildCount()
      );
    } else {
      var index = this._children.indexOf(function (n) {
        return n === ref;
      });

      this._children = [
        ...this._children.slice(0, index),
        node,
        ...this._children.slice(index),
      ];
      this._yogaNode.insertChild(node._yogaNode, index);
    }
    renderDocument();
  }

  replaceData(offset, length, newData) {
    this._data = newData;
    renderDocument();
  }

  // replaceChild(newNode, oldNode) {
  //   // if (newNode._box.parent === this._box) {
  //   //   newNode.detach();
  //   // }
  //   // this._box.insertAfter(newNode._box, oldNode._box);
  //   // this._box.remove(oldNode._box);
  //   // render(newNode._type, newNode.con, oldNode._type);
  //   renderDocument();
  // }

  // Custom stuff

  render() {
    switch (this._type) {
      case "TEXT":
        const rect = this._yogaNode.getComputedLayout();
        return [ansiEscapes.cursorTo(rect.left, rect.top), this._data].join("");
      case "body":
        this._yogaNode.setJustifyContent(yoga.JUSTIFY_CENTER);
        this._yogaNode.calculateLayout(
          process.stdout.columns,
          process.stdout.rows,
          yoga.DIRECTION_LTR
        );
        console.log(this._type, this._yogaNode.getComputedLayout());
        return this._children.reduce(
          (res, child) => res + child.render(),
          Object.values(this._attributes).join("")
        );
      case "elm-ink-column":
        console.log(this._type, this._yogaNode.getComputedLayout());
        return this._children.reduce(
          (res, child) => res + child.render(),
          Object.values(this._attributes).join("")
        );
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
    process.title = newTitle;
  }
}

globalThis.document = new InkDocument();

function renderDocument() {
  var output = [
    ansiEscapes.cursorHide,
    ansiEscapes.clearScreen,
    globalThis.document.body.render(),
  ].join("");

  process.stdout.write(output);
}
