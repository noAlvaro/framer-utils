{VRUtils} = require 'VRUtils'
{TextLayer} = require 'TextLayer'

class exports.FOV extends Layer

	constructor: (skybox, cursor, instructionColor = 'white') ->

		super
			x: -5000
			y: -5000
			z: VRUtils.unity.convertZ 9
			width: 10000
			height: 10000
			opacity: .5
			parent: cursor
			style: background: "-webkit-radial-gradient(center, circle cover, rgba(0,0,0,0) 320px, rgba(0,0,0,.6) 500px, rgba(0,0,0,.6) 100%)"

		@states.focused = scale: .5, opacity: 1

		document.addEventListener 'keydown', =>
			if String.fromCharCode event.which is " "
				@stateCycle(); @writeMessage()

		@instruction = new TextLayer
			name: 'fovInstruction'
			x: Screen.width - 300 - 20
			y: Screen.height - 22 - 10
			text: ""
			color: instructionColor
			fontSize: 16
			textAlign: "right"
			fontFamily: "SamsungInterface"
			width: 300
			height: 22
			parent: skybox

		@writeMessage()

	writeMessage: ->
		fovType = if @states.current.name is 'default' then 'Peripheral' else 'Focused'
		@instruction.text = "#{fovType} FOV [ press space to toggle ]"
