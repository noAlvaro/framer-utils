{FramerUtils} = require '../FramerUtils.coffee'


class exports.MockButton extends Layer

	constructor: (options = {}) ->
		@hoverBlur = options.hoverBlue or 30
		@clickScale = options.clickScale or .98

		super _.defaults options,
			borderRadius: 8
			shadowColor: 'black'
			shadowBlur: 0
		@name = 'button' unless options.name?

		@onMouseOver (e) -> @animate scale: 1, shadowBlur: @hoverBlur
		@onMouseOut (e) -> @animate scale: 1, shadowBlur: 0
		@onMouseDown (e) -> @animate scale: @clickScale, shadowBlur: @hoverBlur / 2
		@onMouseUp (e) -> @animate scale: 1, shadowBlue: @hoverBlur


class exports.MockWord extends Layer

	@Defaults:
		wordWidth: 200
		wordHeight: 20
		autoFade: false
		write: 1

	@minWidthFor: (wordHeight) -> Math.round (wordHeight * 1.5)

	@define 'wordColor',
		get: -> @backgroundColor
		set: (v) -> @backgroundColor = v

	@define 'fadeValue', get: -> Number Boolean (@_write or @_write is undefined)

	@define 'minWidth', get: ->
		@_minWidth or @_minWidth = MockWord.minWidthFor if @wordHeight is undefined then MockWord.Defaults.wordHeight else @wordHeight

	@define 'wordWidth',
		get: -> @_wordWidth
		set: (v) ->
			unless @_wordWidth is (v = Math.max @minWidth, v)
				@width = (@_wordWidth = v); @doWrite()
			@_wordWidth

	@define 'wordHeight',
		get: -> @_wordHeight
		set: (v) ->
			unless @_wordHeight is v
				@height = (@_wordHeight = v)
				@borderRadius = @_wordHeight / 2
				@_minWidth = undefined
				@wordWidth = @_wordWidth
			@_wordHeight

	@define 'autoFade',
		get: -> @_autoFade
		set: (v) ->
			@checkFade() if @_autoFade isnt @_autoFade = v
			@_autoFade

	@define 'write',
		get: -> @_write
		set: (v) ->
			@_write = v unless @_write is v
			@doWrite()

	constructor: (options = {}) ->
		super _.defaults options,
			name: 'word'
			wordColor: Utils.randomColor()
			wordWidth: MockWord.Defaults.wordWidth
			wordHeight: MockWord.Defaults.wordHeight
			autoFade: MockWord.Defaults.autoFade
			write: MockWord.Defaults.write

	doWrite: ->
		@width = Math.max @minWidth, @wordWidth * @_write
		@checkFade()

	checkFade: ->
		_opacity = @fadeValue
		if @_autoFade and @opacity isnt _opacity and (not @fadeAnimation or @fadeAnimation.properties.opacity isnt _opacity)
			@visible = true unless @visible
			@fadeAnimation = @animate opacity: _opacity, {time: .1}
			@fadeAnimation.on Events.AnimationEnd, => @fadeAnimation = null; @visible = Boolean @opacity


class AnchorWord extends exports.MockWord

	@Defaults: padding: exports.MockWord.wordHeight / 2

	@define 'fadeValue', get: -> Number Boolean (@width >= @minWidth * .9 or @_write is undefined)

	@define 'padding',
		get: -> @_padding
		set: (v) -> @emit 'change:width' unless @_padding is @_padding = v; @_padding

	constructor: (@anchor, options={}) ->
		super _.defaults options, autoFade: true, padding: AnchorWord.Defaults.padding
		@anchor.on event, @reposition for event in ['change:x', 'change:width'] if @anchor

	reposition: => @x = @anchor.x + @anchor.width + @anchor.padding

	doWrite: ->
		@width = @wordWidth * @_write
		@checkFade()


class exports.MockLine extends Layer

	@Defaults:
		lineWidth: 200
		lineHeight: 20
		justify: false
		write: 1

	@define 'lineWidth',
		get: -> @_lineWidth
		set: (v) ->
			unless @_lineWidth is v
				@width = (@_lineWidth = v)
				( child.destroy() for child in @children; @createWords() ) if @children.length
			@_lineWidth

	@define 'lineHeight',
		get: -> @_lineHeight
		set: (v) ->
			unless @_lineHeight is v
				@height = (@_lineHeight = v)
				@whiteSpace = @height / 2
				if @children.length
					whiteSpaceToCut = ( @whiteSpace - (@whiteSpace = @height / 2) ) * (@children.length - 1)
					reducedWhiteSpace = 0
					smallerFirst = @children.sort @compareWidths
					for child, index in smallerFirst
						reductionQuota = (whiteSpaceToCut - reducedWhiteSpace) / (@children.length - index)
						maxReduction = child.wordWidth - exports.MockWord.minWidthFor @height
						possibleReduction = Math.min reductionQuota, maxReduction
						child.wordWidth -= possibleReduction
						child.wordHeight = @_lineHeight
						reducedWhiteSpace += possibleReduction
					nextX = 0
					for child in @children
						child.x = nextX
						nextX += (child.wordWidth + @whiteSpace)
						child.destroy() if (child.x + child.wordWidth) > @_lineWidth
					@checkChildren()
			@_lineHeight

	@define 'lineColor',
		get: -> @_lineColor
		set: (v) -> unless @_lineColor is v
			@_lineColor = v; child.wordColor = @_lineColor for child in @children

	@define 'write',
		get: -> @_write
		set: (v) ->
			@doWrite() if (@_write isnt @_write = v) and @children.length

	@define 'justify',
		get: -> @_justify
		set: (v) ->
			@doWrite() if (@_justify isnt @_justify = v) and @children.length
			@_justify

	constructor: (options = {}) ->
		super _.defaults options,
			name: 'line'
			lineWidth: MockLine.Defaults.lineWidth
			lineHeight: MockLine.Defaults.lineHeight
			justify: MockLine.Defaults.justify
			write: MockLine.Defaults.write
			lineColor: Utils.randomColor()
			backgroundColor: 'transparent'
		# @on Events.Click, -> print 'line ' + @y / (@lineHeight + 10), 'y ' + @y, 'fx ' + @opacity, 'id ' + @id
		@createWords()

	createWords: ->
		@wordIndex = []
		minWordWidth = exports.MockWord.minWidthFor @height
		offset = 0; @totalWordVolume = 0
		while (spaceLeft = @width - offset) > minWordWidth
			candidateWidth = Math.round (Math.random() * spaceLeft)
			@totalWordVolume += wordWidth = Math.min spaceLeft, Math.max minWordWidth, candidateWidth
			@wordIndex.push wordWidth: wordWidth, anchorWord: previousWord, initPosition: offset#, proportion: wordWidth / @width
			offset += (wordWidth + @whiteSpace)
		currentWord = previousWord = undefined
		for wordInfo in @wordIndex
			wordInfo.proportion = wordInfo.wordWidth / @totalWordVolume
			currentWord = new AnchorWord previousWord,
				x: wordInfo.initPosition, parent: @
				wordHeight: @height
				padding: @whiteSpace
				wordColor: @_lineColor
			previousWord = currentWord
		@checkChildren()
		@doWrite()

	doWrite: ->
		spaceToJustify = @width - ( (@children.length - 1) * @whiteSpace + @totalWordVolume )
		toErase = (1 - @_write) * (@width - if @_justify then 0 else spaceToJustify)
		for index in [@wordIndex.length - 1..0]
			wordInfo = @wordIndex[index]; word = @children[index]
			word.wordWidth = if @_justify then Math.round wordInfo.wordWidth + wordInfo.proportion * spaceToJustify else wordInfo.wordWidth
			finalSize = Math.max 0, word.wordWidth - toErase
			word.write = finalSize / word.wordWidth
			toErase -= word.wordWidth - finalSize
		@checkExactFit() if @_justify

	checkExactFit: ->
		lastWord = @children.last()
		exactSizeOffset = @_lineWidth - (lastWord.x + lastWord.width)
		lastWord.wordWidth += exactSizeOffset

	compareWidths: (a, b) ->
		if a.wordWidth < b.wordWidth then 1
		else if a.wordWidth > b.wordWidth then -1
		else 0

	checkChildren: -> throw new Error "MockLine couldn't write inside #{@width} pixel space." if not @children.length


class exports.MockLines extends Layer

	@Defaults:
		numLines: 2
		lineWidth: 200
		lineHeight: 20
		linePadding: 10
		paragraph: true
		justify: false
		write: 1

	@define 'numLines',
		get: -> @_numLines
		set: (v) ->
			if @_numLines isnt (@_numLines = Math.max 2, v) and @children.length
				@height = (@_lineHeight + @_linePadding) * @_numLines - @_linePadding
				destroyedLines = 0
				for index in [0...Math.max @children.length, @_numLines]
					line = @children[index - destroyedLines]
					if index < @_numLines
						@addLine index unless line
					else line.destroy(); destroyedLines++
			@_numLines

	@define 'lastWidth',
		get: -> @_lineWidth * .4 + Math.random() * @_lineWidth * .4

	@define 'lineWidth',
		get: -> @_lineWidth
		set: (v) ->
			if @_lineWidth isnt (@_lineWidth = @width = v) and @children.length
				lastLine = @children.last()
				for line in @children
					try (line.lineWidth = if @_paragraph and line is lastLine then @lastWidth else @_lineWidth)
					catch error then throw new Error "MockLines couldn't write inside #{@width} pixel space."
			@_lineWidth

	@define 'lineHeight',
		get: -> @_lineHeight
		set: (v) ->
			if @_lineHeight isnt (@_lineHeight = v) and @children.length
				@height = (@_lineHeight + @_linePadding) * @_numLines - @_linePadding
				for line, index in @children
					line.y += (@_lineHeight - line.lineHeight) * index
					try (line.lineHeight = @_lineHeight)
					catch error then throw new Error Error "MockLines couldn't write inside #{@width} pixel space."
			@_lineHeight

	@define 'linePadding',
		get: -> @_linePadding
		set: (v) ->
			unless @_linePadding is (@_linePadding = Math.max 0, v) and @children.length
				@height = (@_lineHeight + @_linePadding) * @_numLines - @_linePadding
				offset = 0
				for line, index in @children
					line.y = index * (@_lineHeight + @_linePadding)
					offset = line.y + @_lineHeight
			@_linePadding

	@define 'paragraph',
		get: -> @_paragraph
		set: (v) ->
			unless @_paragraph is @_paragraph = v
				sameWidth = @_lineWidth; @_lineWidth = undefined; @lineWidth = sameWidth
			@_paragraph

	@define 'lineColor',
		get: -> @_lineColor
		set: (v) ->
			unless @_lineColor is (@_lineColor = v) and @children.length
				line.lineColor = @_lineColor for line in @children
			@_lineColor

	@define 'justify',
		get: -> @_justify
		set: (v) ->
			unless @_justify is (@_justify = v) and @children.length
				line.justify = @_justify for line in @children
			@_justify

	@define 'write',
		get: -> @_write
		set: (v) ->
			@doWrite() if @_write isnt (@_write = v) and @children.length
			@_write

	constructor: (options = {}) ->
		super _.defaults options,
			name: 'lines'
			numLines: exports.MockLines.Defaults.numLines
			lineWidth: exports.MockLines.Defaults.lineWidth
			lineHeight: exports.MockLines.Defaults.lineHeight
			linePadding: exports.MockLines.Defaults.linePadding
			paragraph: exports.MockLines.Defaults.paragraph
			justify: exports.MockLines.Defaults.justify
			write: exports.MockLines.Defaults.write
			lineColor: Utils.randomColor()
			backgroundColor: 'transparent'
		@addLine index for index in [0...@_numLines]
		@doWrite()

	addLine: (index) ->
		new exports.MockLine
			y: index * (@_lineHeight + @_linePadding), parent: @
			lineWidth: if @_paragraph and index is @_numLines - 1 then @lastWidth else @_lineWidth
			lineHeight: @_lineHeight
			justify: @_justify
			lineColor: @_lineColor

	doWrite: (index) ->
		lineAmount = if @_paragraph then (@_numLines - 1) + @children.last().lineWidth / @_lineWidth else @_numLines
		toErase = (1 - @_write) * (@_lineWidth * lineAmount)
		for index in [@children.length - 1..0]
			line = @children[index]
			finalSize = Math.max 0, line.lineWidth - toErase
			line.write = finalSize / line.lineWidth
			toErase -= line.lineWidth - finalSize
