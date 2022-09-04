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

  set elmInkBorderFormat(format) {
    this._borderFormat = format
    this._yogaNode.setBorder(yoga.EDGE_ALL, 1)

    function addBorder(node) {
      node._yogaNode.setHeight(node._yogaNode.getHeight() + 2)
      node._yogaNode.setWidth(node._yogaNode.getWidth() + 2)
      if (node.parentNode) {
        addBorder(node.parentNode)
      }
    }

    if (this._type === 'elm-ink-text-container') {
      addBorder(this)
    }

    renderDocument()
  }

  render() {
    switch (this._type) {
      // case 'TEXT':
      //   rect = this._yogaNode.getComputedLayout()
      //   return [ansiEscapes.cursorTo(rect.left, rect.top), this._data].join('')
      case 'body':
        // this._yogaNode.setJustifyContent(yoga.JUSTIFY_CENTER)
        this._yogaNode.calculateLayout(
          process.stdout.columns,
          process.stdout.rows,
          yoga.DIRECTION_LTR,
        )
        // var rect = this._yogaNode.getComputedLayout()
        // console.log(rect, 'body')
        return this._children.reduce((res, child) => res + child.render(), '')
      case 'elm-ink-column':
        return (
          drawBorder(this._attributes, this._borderFormat, this._yogaNode) +
          drawYogaNode(
            this._yogaNode,
            this._borderFormat,

            this._children
              .map((child) => applyFontStyles(this._attributes, child.render()))
              .join(''),
          )
        )
      case 'elm-ink-row':
        return (
          drawBorder(this._attributes, this._borderFormat, this._yogaNode) +
          drawYogaNode(
            this._yogaNode,
            this._borderFormat,

            this._children
              .map((child) => applyFontStyles(this._attributes, child.render()))
              .join(''),
          )
        )
      case 'elm-ink-text-container':
        return (
          drawBorder(this._attributes, this._borderFormat, this._yogaNode) +
          drawYogaNode(
            this._yogaNode,
            this._borderFormat,

            applyFontStyles(this._attributes, this._attributes['text']),
          )
        )
    }
  }
}

function drawYogaNode(yogaNode, border, content) {
  var rect = yogaNode.getComputedLayout()
  console.log(rect)
  return [
    ansiEscapes.cursorSavePosition,
    ansiEscapes.cursorMove(
      border ? rect.left + 1 : rect.left,
      border ? rect.top + 1 : rect.top,
    ),
    content,
    ansiEscapes.cursorRestorePosition,
  ].join('')
}

function drawBorder(attributes, format, yogaNode) {
  if (format) {
    const styles = [
      attributes['elm-ink-border-color'],
      attributes['elm-ink-border-background-color'],
    ]
      .filter((s) => s)
      .join(';')
    function applyStyleToBorder(str) {
      if (styles) {
        return '\x1B[' + styles + 'm' + str + '\x1B[0m'
      } else {
        return str
      }
    }

    var rect = yogaNode.getComputedLayout()

    return [
      ansiEscapes.cursorSavePosition,
      ansiEscapes.cursorMove(rect.left, rect.top),
      applyStyleToBorder(format.topLeft),
      applyStyleToBorder(format.top.repeat(rect.width - 2)),
      applyStyleToBorder(format.topRight),
      arrayOfSize(rect.height - 2)
        .map(() =>
          [
            ansiEscapes.cursorBackward(1),
            ansiEscapes.cursorDown(1),
            applyStyleToBorder(format.right),
          ].join(''),
        )
        .join(''),
      ansiEscapes.cursorDown(1),
      ansiEscapes.cursorBackward(rect.width),
      applyStyleToBorder(format.bottomLeft),
      applyStyleToBorder(format.bottom.repeat(rect.width - 2)),
      applyStyleToBorder(format.bottomRight),
      ansiEscapes.cursorBackward(rect.width - 1),
      arrayOfSize(rect.height - 2)
        .map(() =>
          [
            ansiEscapes.cursorBackward(1),
            ansiEscapes.cursorUp(1),
            applyStyleToBorder(format.left),
          ].join(''),
        )
        .join(''),
      ansiEscapes.cursorRestorePosition,
    ].join('')
  } else {
    return ''
  }
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

function arrayOfSize(size) {
  return new Array(size).fill(null)
}
