// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analog_clock/clock_face.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureUnit = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  var _degreeSign = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString.split('.')[0];
      _temperatureUnit = widget.model.temperatureString.substring(
          widget.model.temperatureString.length - 1,
          widget.model.temperatureString.length);
      _degreeSign = widget.model.temperatureString.substring(
          widget.model.temperatureString.length - 2,
          widget.model.temperatureString.length - 1);
      _temperatureRange =
          '${widget.model.low} - ${widget.model.highString.split('°')[0]}';

      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF343334),
            // Minute hand.
            highlightColor: Color(0xFFFF3C3E),
            // Second hand.
            accentColor: Color(0xFFFF3C3E),
            backgroundColor: Color(0xFFF2F0F2),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFF2F0F2),
            highlightColor: Color(0xFFFF3C3E),
            accentColor: Color(0xFFFF3C3E),
            backgroundColor: Color(0xFF343334),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: _temperature,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: customTheme.primaryColor,
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                TextSpan(
                  text: _degreeSign,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: customTheme.highlightColor,
                      fontSize: 60,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextSpan(
                  text: _temperatureUnit,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: customTheme.primaryColor,
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ]),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: _temperatureRange,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: customTheme.primaryColor.withOpacity(0.75),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                TextSpan(
                  text: _degreeSign,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: customTheme.highlightColor.withOpacity(0.75),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextSpan(
                  text: _temperatureUnit,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: customTheme.primaryColor.withOpacity(0.75),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          _condition[0].toUpperCase() + _condition.substring(1),
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: customTheme.highlightColor,
              fontSize: 50,
              fontWeight: FontWeight.w700,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _location.replaceAll(", ", "\n"),
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: customTheme.primaryColor.withOpacity(0.75),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        // alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            weatherInfo,
            Container(
              // color: Colors.red.withOpacity(0.1),
              height: MediaQuery.of(context).size.width * 0.4,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClockFace(
                    width: MediaQuery.of(context).size.width * 0.4,
                    color: customTheme.backgroundColor,
                  ),
                  // Example of a hand drawn with [CustomPainter].
                  DrawnHand(
                    color: customTheme.accentColor,
                    thickness: 1,
                    size: 0.75,
                    angleRadians: _now.second * radiansPerTick,
                  ),
                  DrawnHand(
                    color: customTheme.highlightColor,
                    thickness: 2,
                    size: 0.7,
                    angleRadians: _now.minute * radiansPerTick,
                  ),
                  // Example of a hand drawn with [Container].
                  ContainerHand(
                    color: Colors.transparent,
                    size: 0.5,
                    angleRadians: _now.hour * radiansPerHour +
                        (_now.minute / 60) * radiansPerHour,
                    child: Transform.translate(
                      offset: Offset(0.0, -40.0),
                      child: Container(
                        width: 7,
                        height: 120,
                        decoration: BoxDecoration(
                          color: customTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: customTheme.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          spreadRadius: 1,
                          color: customTheme.primaryColor.withOpacity(0.1),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
