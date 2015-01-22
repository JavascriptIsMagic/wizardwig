$.fn.wizardwig = (options) ->
  new $.Wizardwig @[0], options
  @
$.Wizardwig = class Wizardwig
  constructor: (@element, options = {}) ->
    @element = $ element
        .css 'max-height', '20rem'
    @$iframe = $ '<iframe></iframe>'
  			.css
    			'width': '100%'
    			'height': '100%'
    			'border-collapse': 'separate'
    			'border': '1px solid rgb(204, 204, 204)'
    			'box-sizing': 'content-box'
    			'box-shadow': 'rgba(0, 0, 0, 0.0745098) 0px 1px 1px 0px inset'
    			'border-top-right-radius': '3px;'
    			'border-bottom-right-radius': '3px'
    			'border-bottom-left-radius': '3px'
    			'border-top-left-radius': '3px'
    			'outline': 'none'
    @$iframe
      .on 'load', =>
        @window = @$iframe[0].contentWindow
        @document = @window.document
        @$editor = $ '<div></div>'
          .attr 'contentEditable', true
          .appendTo @document.body
          .on 'mouseup keyup mouseout', =>
            @update()
          .on 'dragenter dragover', false
          .on 'blur', =>
            @selectedRange = @getCurrentRange()
            @markSelection true
        @addHead options.head if options.head
        @addHead '<style>html, body, body > div {position: absolute; top:0; left 0; min-width:100%; min-height: 100%; padding: 0; margin: 0;} </style>'
        setTimeout =>
          @update()
      .appendTo @element
    @element
      .keydown (event) ->
        event.stopPropagation() if event.keyCode is 13
    $ @document
      .on 'touchend', (event) =>
        currentRange = @getCurrentRange()
        @update true if not
          (currentRange and
            currentRange.startContainer is currentRange.endContainer and
            currentRange.startOffset is currentRange.endOffset) or
          (@$editor.is(event.target) or
          @$editor.has(event.target).length > 0)
  markSelection: (mark) ->
    @restoreSelection()
    @document.execCommand 'hiliteColor', if mark then 'darkgrey' else 'transparent'
    @selectedRange = @getCurrentRange()
  command: (command, args) ->
    @restoreSelection()
    @$editor.focus()
    @document.execCommand command, args
    @update()
    @selectedRange = @getCurrentRange()
  getSelectionState: () ->
    state = {}
    for command in @commandStates
      state[command] = @document.queryCommandState command
    for command in @commandValues
      state[command] = @document.queryCommandValue command
    state
  addHead: (includes) ->
    $ 'head', @document
      .append if Array.isArray includes then includes.join() else includes
  update: (saveSelection) ->
    state = @getSelectionState()
    stateString = JSON.stringify state
    @element.css 'height', @$editor.height()
    if saveSelection
      @selectedRange = @getCurrentRange()
    unless @cachedStateString is stateString
      @cachedStateString = stateString
      if not state.justifyLeft and not state.justifyCenter and not state.justifyRight and not state.justifyFull
        state.justifyLeft = true
      @element.trigger 'selectionStateChange', [state]
  restoreSelection: ->
    selection = @window.getSelection()
    if @selectedRange
      try
        selection.removeAllRanges()
      catch
        @document.body.createTextRange().select()
        @document.selection.empty()
      selection.addRange @selectedRange
  getCurrentRange: ->
    selection = @window.getSelection()
    if selection.getRangeAt and selection.rangeCount
      selection.getRangeAt 0
  commandStates: [
    'bold'
    'italic'
    'justifyCenter'
    'justifyFull'
    'justifyLeft'
    'JustifyRight'
    'strikeThrough'
    'subscript'
    'superscript'
    'underline'
  ]
  commandValues: [
    'backColor'
    'fontName'
    'fontSize'
    'foreColor'
  ]
