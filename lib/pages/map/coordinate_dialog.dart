import 'package:flutter/material.dart';
import 'package:la_navigation/routing/router.dart';

import '../../utils/utm/utm.dart';


class CoordinateDialog extends StatelessWidget
{
  final UtmCoordinate coordinate;
  final String label;

  const CoordinateDialog({
    final Key? key,
    required this.coordinate,
    required this.label
  }) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    final theme = Theme.of(context);
    return Dialog(
      elevation: 5,
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
              style: theme.textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Row(children: [
              const Text('Зона:'),
              const SizedBox(width: 10),
              Expanded(child: Text(coordinate.zone)),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const Text('На север:'),
              const SizedBox(width: 10),
              Expanded(child: Text('${coordinate.northing.round()}')),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const Text('На восток:'),
              const SizedBox(width: 10),
              Expanded(child: Text('${coordinate.easting.round()}')),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const Text('Широта:'),
              const SizedBox(width: 10),
              Expanded(child: Text('${coordinate.lat}')),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const Text('Долгота:'),
              const SizedBox(width: 10),
              Expanded(child: Text('${coordinate.lon}')),
            ]),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text('ОК'),
              onPressed: () => Routing.goBack(context),
            ),
          ],
        ),
      ),
    );
  }
}
