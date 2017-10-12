class exports.Ease

  @QuadIn     : 'bezier-curve(0.550,  0.085, 0.680, 0.530)'
  @QuadOut    : 'bezier-curve(0.250,  0.460, 0.450, 0.940)'
  @QuadInOut  : 'bezier-curve(0.455,  0.030, 0.515, 0.955)'
  @CubicIn    : 'bezier-curve(0.550,  0.055, 0.675, 0.190)'
  @CubicOut   : 'bezier-curve(0.215,  0.610, 0.355, 1.000)'
  @CubicInOut : 'bezier-curve(0.645,  0.045, 0.355, 1.000)'
  @QuartIn    : 'bezier-curve(0.895,  0.030, 0.685, 0.220)'
  @QuartOut   : 'bezier-curve(0.165,  0.840, 0.440, 1.000)'
  @QuartInOut : 'bezier-curve(0.770,  0.000, 0.175, 1.000)'
  @QuintIn    : 'bezier-curve(0.755,  0.050, 0.855, 0.060)'
  @QuintOut   : 'bezier-curve(0.230,  1.000, 0.320, 1.000)'
  @QuintInOut : 'bezier-curve(0.860,  0.000, 0.070, 1.000)'
  @SineIn     : 'bezier-curve(0.470,  0.000, 0.745, 0.715)'
  @SineOut    : 'bezier-curve(0.390,  0.575, 0.565, 1.000)'
  @SineInOut  : 'bezier-curve(0.445,  0.050, 0.550, 0.950)'
  @ExpoIn     : 'bezier-curve(0.950,  0.050, 0.795, 0.035)'
  @ExpoOut    : 'bezier-curve(0.190,  1.000, 0.220, 1.000)'
  @ExpoInOut  : 'bezier-curve(1.000,  0.000, 0.000, 1.000)'
  @CircIn     : 'bezier-curve(0.600,  0.040, 0.980, 0.335)'
  @CircOut    : 'bezier-curve(0.075,  0.820, 0.165, 1.000)'
  @CircInOut  : 'bezier-curve(0.785,  0.135, 0.150, 0.860)'
  @BackIn     : 'bezier-curve(0.600, -0.280, 0.735, 0.045)'
  @BackOut    : 'bezier-curve(0.175,  0.885, 0.320, 1.275)'
  @BackInOut  : 'bezier-curve(0.680, -0.550, 0.265, 1.550)'

  # Robert Penner abstractions
  begin = 0; change = 1; duration = 1
  _overshoot = 1.70158; _amplitude = null; _period = null

  @modulation:

    quad:
      in: (progress) -> change * (progress = progress / duration) * progress + begin
      out: (progress) -> -change * (progress = progress / duration) * (progress - 2) + begin
      inOut: (progress) ->
        if ( progress = progress / (duration / 2) ) < 1 then change / 2 * progress * progress + begin
        else -change / 2 * ( (progress -= 1) * (progress - 2) - 1 ) + begin

    cubic:
      in: (progress) -> change * (progress /= duration) * progress * progress + begin
      out: (progress) -> change * ( (progress = progress / duration - 1) * progress * progress + 1 ) + begin
      inOut: (progress) ->
        if ( progress = progress / (duration / 2) ) < 1 then change / 2 * progress * progress * progress + begin
        else change / 2 * ( (progress -= 2) * progress * progress + 2) + begin

    quart:
      in: (progress) -> change * (progress = progress / duration) * progress * progress * progress + begin
      out: (progress) -> -change * ( (progress = progress / duration - 1) * progress * progress * progress - 1 ) + begin
      inOut: (progress) ->
        if ( progress = progress / (duration / 2) ) < 1 then change / 2 * progress * progress * progress * progress + begin
        else -change / 2 * ( (progress -= 2) * progress * progress * progress - 2) + begin

    quint:
      in: (progress) -> change * (progress = progress / duration) * progress * progress * progress * progress + begin
      out: (progress) -> change * ( (progress = progress / duration - 1) * progress * progress * progress * progress + 1 ) + begin
      inOut: (progress) ->
        if ( progress = progress / (duration / 2) ) < 1 then change / 2 * progress * progress * progress * progress * progress + begin
        else change / 2 * ( (progress -= 2) * progress * progress * progress * progress + 2 ) + begin

    sine:
      in: (progress) -> -change * Math.cos( progress / duration * (Math.PI / 2) ) + change + begin
      out: (progress) -> change * Math.sin( progress / duration * (Math.PI / 2) ) + begin
      inOut: (progress) -> -change / 2 * (Math.cos(Math.PI * progress / duration) - 1) + begin

    expo:
      in: (progress) -> if progress is 0 then begin else change * Math.pow( 2, 10 * (progress / duration - 1) ) + begin
      out: (progress) -> if progress is duration then begin + change else change * (-Math.pow(2, -10 * progress / duration) + 1) + begin
      inOut: (progress) ->
        if progress is 0 then begin
        else if progress is duration then begin + change
        else if ( progress = progress / (duration / 2) ) < 1 then change / 2 * Math.pow( 2, 10 * (progress - 1) ) + begin
        else change / 2 * (-Math.pow( 2, -10 * (progress - 1) ) + 2) + begin

    circ:
      in: (progress) -> -change * (Math.sqrt(1 - (progress = progress / duration) * progress) - 1) + begin
      out: (progress) -> change * Math.sqrt(1 - (progress = progress / duration - 1) * progress) + begin
      inOut: (progress) ->
        if ( progress = progress / (duration / 2) ) < 1 then -change / 2 * (Math.sqrt(1 - progress * progress) - 1) + begin
        else change / 2 * (Math.sqrt(1 - (progress -= 2) * progress) + 1) + begin

    back:
      in: (progress, overshoot = _overshoot) ->
        change * (progress /= duration) * progress * ( (overshoot + 1) * progress - overshoot ) + begin
      out: (progress, overshoot = _overshoot) ->
        change * ( (progress = progress / duration - 1) * progress * ( (overshoot + 1) * progress + overshoot ) + 1 ) + begin
      inOut: (progress, overshoot = _overshoot) ->
        if ( ( progress = progress / (duration / 2) ) < 1 ) then change / 2 * (progress * progress * ( ( ( overshoot *= (1.525) ) + 1 ) * progress - overshoot) ) + begin
        else change / 2 * ( (progress -= 2) * progress * ( ( ( overshoot *= (1.525) ) + 1 ) * progress + overshoot ) + 2 ) + begin

    bounce:
      in: (progress) -> change - exports.Ease.modulation.bounce.out(duration - progress) + begin
      out: (progress) ->
        if (progress /= duration) < 1 / 2.75 then change * (7.5625 * progress * progress) + begin
        else if progress < 2 / 2.75 then change * (7.5625 * (progress -= (1.5 / 2.75) ) * progress + 0.75) + begin
        else if progress < 2.5/2.75 then change * (7.5625 * (progress -= (2.25 / 2.75) ) * progress + 0.9375) + begin
        else change * (7.5625 * ( progress -= (2.625 / 2.75) ) * progress + 0.984375) + begin
      inOut: (progress) ->
        if progress < duration / 2 then exports.Ease.modulation.bounce.in(progress * 2) * 0.5 + begin
        else exports.Ease.modulation.bounce.out(progress * 2 - duration) * 0.5 + change * 0.5 + begin

    elastic:
      in: (progress, amplitude = _amplitude, period = _period) ->
        if progress is 0 then begin
        else if (progress = progress / duration) is 1 then begin + change
        else
          if not period? then period = duration * 0.3
          if not amplitude? or amplitude < Math.abs(change) then (amplitude = change; overshoot = period / 4)
          else overshoot = period / (2 * Math.PI) * Math.asin(change / amplitude)
          progress -= 1; -( amplitude * Math.pow(2, 10 * progress) ) * Math.sin( (progress * duration - overshoot) * (2 * Math.PI) / period ) + begin
      out: (progress, amplitude = _amplitude, period = _period) ->
        if progress is 0 then begin
        else if (progress = progress / duration) is 1 then begin+change
        else
          if not period? then period = duration * 0.3
          if not amplitude? or amplitude < Math.abs(change) then (amplitude = change; overshoot = period / 4)
          else overshoot = period / (2 * Math.PI) * Math.asin(change / amplitude)
          ( amplitude * Math.pow(2, -10 * progress) ) * Math.sin( (progress * duration - overshoot) * (2 * Math.PI) / period ) + change + begin
      inOut: (progress, amplitude = _amplitude, period = _period) ->
        if progress is 0 then begin
        else if ( progress = progress / (duration / 2) ) == 2 then begin+change
        else
          if not period? then period = duration * (0.3 * 1.5)
          if not amplitude? or amplitude < Math.abs(change) then (amplitude = change; overshoot = period / 4)
          else overshoot = period / (2 * Math.PI) * Math.asin(change / amplitude)
          if progress < 1 then -0.5 * ( amplitude * Math.pow( 2, 10 * (progress -= 1) ) ) * Math.sin( (progress * duration - overshoot) * ( (2 * Math.PI) / period ) ) + begin
          else amplitude * Math.pow( 2, -10 * (progress -= 1) ) * Math.sin( (progress * duration - overshoot) * (2 * Math.PI) / period ) + change + begin
