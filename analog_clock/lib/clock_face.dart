// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ClockFace extends StatelessWidget {
  const ClockFace({Key key, this.color, this.width}) : super(key: key);

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: width - 20,
                height: width - 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 2.5,
                        blurRadius: 30,
                        color: Colors.white,
                        offset: Offset(-10, -10))
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: width - 30,
                height: width - 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 30,
                      color: Colors.black.withOpacity(0.18),
                      offset: Offset(10, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
