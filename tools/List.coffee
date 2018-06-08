{Ease} = require 'framer-utils/Ease'
{FramerUtils} = require 'framer-utils/FramerUtils'

class exports.List extends Layer

	@DefaultAnimationOptions =
		time: .4, curve: Ease.ExpoOut

	@define 'chainDelay',
		get: -> @_chainDelay or .04
		set: (v) -> @_chainDelay = v

	constructor: (@itemWidth, @itemHeight, @paddingSize = 10, @numColumns = 1, options={}) ->
		super _.defaults options,
			name: 'List'
			backgroundColor: null
		@items = []
		@bundleSize =
			width: @itemWidth + @paddingSize
			height: @itemHeight + @paddingSize
		@refreshSize()

	refreshSize: =>
		@width = @bundleSize.width * @numColumns - @paddingSize
		@height = Math.max 0, @bundleSize.height * Math.ceil(@children.length / @numColumns) - @paddingSize

	addItem: (items...) ->
		for item in items
			item.frame = @getPosition @items.length
			@addChild item; @items.push item
		@refreshSize()

	addIndex: (index, items...) ->
		items = [ @newDummy() ] unless items.length
		for item in items
			item.frame = @getPosition index
			@addChild item; @items.splice index, 0, item
			@organize item, index
		@refreshSize()
		@updatePositions index

	newDummy: -> return new Layer
		name: 'DummyItem', backgroundColor: null
		width: @itemWidth, height: @itemHeight

	# TODO: implement a switcher from line to column based organization
	getPosition: (index) ->
		x: (index % @numColumns) * @bundleSize.width
		y: Math.floor(index / @numColumns) * @bundleSize.height

	removeItem: (item) -> @removeIndex @items.indexOf item

	removeIndex: (index) -> if index > -1
		item = @items[index]
		@removeChild item; @items.splice index, 1
		item.frame = x: 0, y: 0
		@updatePositions index

	updatePositions: (fromIndex) ->
		delay = 0
		while (index = fromIndex++) < @items.length
			item = @items[index]
			animationOptions = @getAnimationOptions item
			newDelay = @chainDelay * delay++
			a = item.animate (@getPosition index), _.defaults
				time: animationOptions.time * (1 + newDelay)
				delay: newDelay
				animationOptions
			a.onAnimationEnd @refreshSize

	replaceIndex: (index, item) ->
		toRemove = @items[index]
		@removeChild toRemove; @items.splice index, 1
		toRemove.frame = x: 0, y: 0
		item.frame = item.convertPointToLayer item.frame, @
		@addChild item; @items.splice index, 0, item
		a = item.animate (@getPosition index), @getAnimationOptions item
		a.onAnimationEnd => @organize item, index

	detach: (item, reparent=null) ->
		throw new Error 'Add this item to List before detaching it.' unless item in @items
		if reparent then item.frame = @convertPointToLayer reparent; item.parent = reparent
		item.bringToFront()

	reclaim: (item) ->
		throw new Error 'Add this item to List before reclaiming it.' unless item in @items
		index = @items.indexOf item
		if item.parent isnt @ then item.frame =
			if item.parent then parent.convertPointToLayer item.frame, @
			else Canvas.convertPointToLayer item.frame, @
		@addChild item
		a = item.animate (@getPosition index), @getAnimationOptions item
		a.onAnimationEnd => @organize item, index

	# localPoint:	{x,y} object referred to this list's pivot.
	# translator:	an optional function that receives an item to translate its center point.
	# note:			simplest center calculation will be used when the translator is null.
	convertPointToIndex: (localPoint, centerTranslator=null) ->
		distances = []
		for item in @items
			centerPoint = if centerTranslator then centerTranslator item
			else x: item.x + @itemWidth / 2, y: item.y + @itemHeight / 2
			distances.push i: item, d: FramerUtils.Geometry.distance localPoint, centerPoint
		( _.orderBy distances, ['d'], ['asc'] )[0].i

	swapWithIndex: (item, index) ->
		throw new Error 'Add this item to List before swapping it.' unless item in @items
		itemIndex = @items.indexOf item; indexItem = @items[index]
		FramerUtils.Array.swap @items, index, itemIndex
		@organize item, index; @organize indexItem, itemIndex
		item.animate (@getPosition index), @getAnimationOptions item
		indexItem.animate (@getPosition itemIndex), @getAnimationOptions indexItem

	swapWithItem: (itemA, itemB) -> @swapWithIndex itemA, @items.indexOf itemB


	organize: (item, index) ->
		if index < @items.length - 1 then item.placeBehind @items[++index]
		else item.placeBefore @items[--index]

	getAnimationOptions: (item) ->
		(item.animationOptions if Object.keys(item.animationOptions).length) or
		List.DefaultAnimationOptions

	getItem: (index) -> @items[index]

	getIndex: (item) -> @items.indexOf item
