class exports.GridArea extends Layer

	constructor: (cols = 1, rows = 1, options = {}) ->

		super options
		@currentCol = @currentCol = undefined
		@onMouseMove (e) ->
			col = Math.floor ( e.offsetX / (@width / cols) )
			row = Math.floor ( e.offsetY / (@height / rows) )
			unless (@currentCol is col and @currentRow is row)
				@currentCol = col; @currentRow = row
				info = {col: col, row: row}
				@emit 'change:area', info
