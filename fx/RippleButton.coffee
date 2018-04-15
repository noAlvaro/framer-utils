{FramerUtils} = require 'framer-utils/FramerUtils'
{Ease} = require 'framer-utils/Ease'

class exports.RippleButton extends Layer

	constructor: (@_color='black', @_opacity=.2, time=2, options={}) ->
		super _.defaults options, clip: true
		@animationParams = {time: time, curve: Ease.ExpoOut}
		@on 'change:size', @calculateCorners; @calculateCorners()
		@onMouseDown @onRipple

	calculateCorners: (e) -> @corners = FramerUtils.Geometry.cornersOf @

	calculateRadius: (p) ->
		d = []
		d.push FramerUtils.Geometry.distanceBetween(p, c) for c in @corners
		Math.max d...

	newRippleContainer: (position) -> new Layer
		name: 'ripple', parent: @, scale: 0, size: 0
		point: position, backgroundColor: null

	onRipple: (e) ->
		ripple = @newRippleContainer e.point
		radius = @calculateRadius e.point
		fx = new Layer
			name: 'fx', parent: ripple, x: -radius, y: -radius
			size: 2 * radius, borderRadius: radius, opacity: 0
			backgroundColor: @_color
		fx.birth = Date.now()
		a = new Animation ripple, scale: 1, @animationParams
		a.onAnimationStop -> fx.off Events.MouseUp, @vanishFX; ripple.destroy()
		fx.on Events.MouseUp, @vanishFX; a.start()
		fx.animate opacity: @_opacity, @animationParams

	vanishFX: ->
		time = @animations()[0].options.time - (Date.now() - @birth) / 1000
		@animateStop(); @animate opacity: 0, {time: time, curve: Ease.ExpoOut}
