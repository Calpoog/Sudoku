import 'package:flutter/material.dart';

double relativeWidth(BuildContext context, double factor) {
  return MediaQuery.of(context).size.width * factor;
}

double relativeHeight(BuildContext context, double factor) {
  return MediaQuery.of(context).size.height * factor;
}
