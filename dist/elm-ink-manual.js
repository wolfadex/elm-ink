import ansiEscapes from 'ansi-escapes'
import yoga from 'yoga-layout-prebuilt'
import stringWidth from 'string-width'
import cliBoxes from 'cli-boxes'

process.stdin.setRawMode(true)
process.stdin.resume()
process.stdin.setEncoding('utf-8')
var val
process.stdin.on('data', function (data) {
  val = data.toString()

  if (val === '\x1B' || val === '\u0003') {
    process.stdin.setRawMode(true)
    process.exit(0)
  }
})

// An Ink <-> Blessed node wrapper
class InkNode {
  constructor(type, ...args) {
    this._type = type
    this._children = []
    this._attributes = {}

    switch (type) {
      case 'TEXT':
        this._data = args[0]
        this._yogaNode = yoga.Node.create()
        this._yogaNode.setHeight(1)
        this._yogaNode.setWidth(stringWidth(this._data))

        break
      case 'body':
        this._yogaNode = yoga.Node.create()
        break
      case 'elm-ink-column':
        this._yogaNode = yoga.Node.create()
        this._yogaNode.setFlexDirection(yoga.FLEX_DIRECTION_COLUMN)
        break
      case 'elm-ink-row':
        this._yogaNode = yoga.Node.create()
        this._yogaNode.setFlexDirection(yoga.FLEX_DIRECTION_ROW)
        break
      case 'elm-ink-textinput':
        break
      case 'elm-ink-text-container':
        this._yogaNode = yoga.Node.create()
        this._yogaNode.setHeight(1)
        break
      default:
        console.log('UNKNOWN NODE TYPE', type)
    }
  }

  get nodeType() {
    switch (this._type) {
      case 'TEXT':
        return 3
      default:
        return 1
    }
  }

  get childNodes() {
    return this._children
  }

  // get length() {
  //   // return this._box.content.length;
  // }

  get parentNode() {
    return this._parent
  }

  get attributes() {
    return Object.entries(this._attributes)
  }

  get tagName() {
    return this._type
  }

  setAttribute(key, val) {
    this._attributes[key] = val

    if (key === 'text') {
      this._yogaNode.setWidth(stringWidth(val))
    }

    renderDocument()
  }

  // addEventListener(key, callback) {
  //   // this._box.on(key, callback);
  // }

  appendChild(node) {
    this._children.push(node)
    this._yogaNode.insertChild(node._yogaNode, this._yogaNode.getChildCount())
    node._parent = this
    renderDocument()
  }

  insertBefore(node, ref) {
    if (ref == null) {
      this._children.push(node)
      this._yogaNode.insertChild(node._yogaNode, this._yogaNode.getChildCount())
    } else {
      var index = this._children.indexOf(function (n) {
        return n === ref
      })

      this._children = [
        ...this._children.slice(0, index),
        node,
        ...this._children.slice(index),
      ]
      this._yogaNode.insertChild(node._yogaNode, index)
    }
    renderDocument()
  }

  replaceData(offset, length, newData) {
    this._data = newData
    renderDocument()
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
      // case 'TEXT':
      //   rect = this._yogaNode.getComputedLayout()
      //   return [ansiEscapes.cursorTo(rect.left, rect.top), this._data].join('')
      case 'body':
        this._yogaNode.setJustifyContent(yoga.JUSTIFY_CENTER)
        this._yogaNode.calculateLayout(
          process.stdout.columns,
          process.stdout.rows,
          yoga.DIRECTION_LTR,
        )
        return this._children.reduce((res, child) => res + child.render(), '')
      case 'elm-ink-column':
        return drawYogaNode(
          this._yogaNode,
          this._children
            .map((child) => applyFontStyles(this._attributes, child.render()))
            .join(''),
        )
      case 'elm-ink-row':
        return drawYogaNode(
          this._yogaNode,
          this._children
            .map((child) => applyFontStyles(this._attributes, child.render()))
            .join(''),
        )
      case 'elm-ink-text-container':
        return drawYogaNode(
          this._yogaNode,
          applyFontStyles(this._attributes, this._attributes['text']),
        )
    }
  }
}

function drawYogaNode(yogaNode, content) {
  var rect = yogaNode.getComputedLayout()
  return [
    ansiEscapes.cursorSavePosition,
    ansiEscapes.cursorMove(rect.left, rect.top),
    content,
    ansiEscapes.cursorRestorePosition,
  ].join('')
}

function applyFontStyles(attributes, str) {
  const styles = [
    attributes['elm-ink-font-color'],
    attributes['elm-ink-font-bold'],
    attributes['elm-ink-font-faint'],
    attributes['elm-ink-font-italic'],
    attributes['elm-ink-font-underline'],
    attributes['elm-ink-background-color'],
  ]
    .filter((s) => s)
    .join(';')

  if (styles) {
    return '\x1B[' + styles + 'm' + str + '\x1B[0m'
  } else {
    return str
  }
}

// The base Ink Document
class InkDocument {
  constructor() {
    this._body = new InkNode('body')
  }

  get body() {
    return this._body
  }

  createElement(...args) {
    return new InkNode(...args)
  }

  createTextNode(...args) {
    return new InkNode('TEXT', ...args)
  }

  get title() {
    return this._title
  }

  set title(newTitle) {
    this._title = newTitle
    process.title = newTitle
  }
}

globalThis.document = new InkDocument()

function renderDocument() {
  var output = [
    ansiEscapes.cursorHide,
    ansiEscapes.clearScreen,
    ansiEscapes.cursorTo(0, 0),
    globalThis.document.body.render(),
  ].join('')

  process.stdout.write(output)
}
