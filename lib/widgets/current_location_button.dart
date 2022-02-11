// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';


class CurrentLocationButtonPluginOption extends LayerOptions
{
  final MapController controller;
  final LatLng targetLocation;
  final double? targetZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? backgroundColor;
  final Color? iconColor;

  CurrentLocationButtonPluginOption({
    Key? key,
    required this.controller,
    required this.targetLocation,
    this.targetZoom,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.bottomRight,
    this.backgroundColor,
    this.iconColor,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class CurrentLocationButtonPlugin implements MapPlugin
{
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is CurrentLocationButtonPluginOption) {
      return CurrentLocationButton(options, mapState, stream);
    }
    throw Exception(
      'Unknown options type for CurrentLocationButtonPlugin: $options'
    );
  }

  @override
  bool supportsLayer(LayerOptions options)
  {
    return options is CurrentLocationButtonPluginOption;
  }
}


class CurrentLocationButton extends StatefulWidget
{
  final CurrentLocationButtonPluginOption options;
  final MapState map;
  final Stream<Null> stream;

  CurrentLocationButton(
    this.options,
    this.map,
    this.stream,
  ): super(key: options.key);

  @override
  State<CurrentLocationButton> createState() => _CurrentLocationButtonState();
}

class _CurrentLocationButtonState extends State<CurrentLocationButton>
  with TickerProviderStateMixin
{
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));

  @override
  void initState() {
    super.initState();

    mapEventSubscription =
        widget.options.controller.mapEventStream.listen(onMapEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.options.alignment,
      child: Padding(
        padding: EdgeInsets.only(
            left: widget.options.padding,
            top: widget.options.padding,
            right: widget.options.padding),
        child: FloatingActionButton(
          heroTag: 'CurrentLocationButton',
          mini: widget.options.mini,
          backgroundColor:
              widget.options.backgroundColor
                ?? Theme.of(context).primaryColor,
          onPressed: () => _animatedMapMoveToCurrent(),
          child: Icon(_icon,
            color: widget.options.iconColor ?? IconTheme.of(context).color
          ),
        ),
      ),
    );
  }

  void _animatedMapMoveToCurrent()
  {
    _eventKey++;
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
      begin: widget.options.controller.center.latitude,
      end: widget.options.targetLocation.latitude,
    );
    final _lngTween = Tween<double>(
      begin: widget.options.controller.center.longitude,
      end: widget.options.targetLocation.longitude,
    );
    final _zoomTween = Tween<double>(
      begin: widget.options.controller.zoom,
      end: widget.options.targetZoom ?? widget.options.controller.zoom,
    );

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      try {
        var moved = widget.options.controller.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation),
          id: _eventKey.toString(),
        );

        if (moved) {
          setIcon(Icons.gps_fixed);
        } else {
          setIcon(Icons.gps_not_fixed);
        }
      } catch (e) {
        setIcon(Icons.gps_off);
      }
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void onMapEvent(MapEvent mapEvent) {
    if (mapEvent is MapEventMove && mapEvent.id != _eventKey.toString()) {
      setIcon(Icons.gps_not_fixed);
    }
  }

  void setIcon(final IconData newIcon)
  {
    if (newIcon != _icon && mounted) {
      setState(() {
        _icon = newIcon;
      });
    }
  }

  late final StreamSubscription<MapEvent> mapEventSubscription;

  int _eventKey = 0;
  IconData _icon = Icons.gps_not_fixed;
}
