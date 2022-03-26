import 'package:flutter/material.dart';
import 'package:la_navigation/services/storage/coordinates.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/storage/grid.dart';
import '../services/storage/map.dart';
import '../models.dart';
import '../routing.dart';
import 'common/styles.dart';


class DailyForecastPage extends StatefulWidget
{
  const DailyForecastPage({Key? key}) : super(key: key);

  @override
  State<DailyForecastPage> createState() => _DailyForecastPageState();
}


class _DailyForecastPageState extends State<DailyForecastPage>
{
  @override
  void initState()
  {
    super.initState();
    final mapService = context.read<MapService>();
    final gridService = context.read<GridService>();
    _showGrid = gridService.settings.showGrid;
    _useLocalMap = mapService.settings.useLocalMap;
    _swPanBoundaryLatController = TextEditingController(
      text: mapService.settings.swPanBoundary?.latitude.toString() ?? '',
    );
    _swPanBoundaryLongController = TextEditingController(
      text: mapService.settings.swPanBoundary?.longitude.toString() ?? '',
    );
    _nePanBoundaryLatController = TextEditingController(
      text: mapService.settings.nePanBoundary?.latitude.toString() ?? '',
    );
    _nePanBoundaryLongController = TextEditingController(
      text: mapService.settings.nePanBoundary?.longitude.toString() ?? '',
    );
    _gridStartLatController = TextEditingController(
      text: gridService.settings.startCoordinate?.latitude.toString() ?? ''
    );
    _gridStartLongController = TextEditingController(
      text: gridService.settings.startCoordinate?.longitude.toString() ?? ''
    );
    _gridStepController = TextEditingController(
      text: gridService.settings.gridStep?.toString() ?? ''
    );
    _verticalStepsCountController = TextEditingController(
      text: gridService.settings.verticalStepsCount?.toString() ?? ''
    );
    _horyzontalStepsCountController = TextEditingController(
      text: gridService.settings.horizontalStepsCount?.toString() ?? ''
    );
    _focusScopeNode = FocusScopeNode();
  }

  @override
  void dispose()
  {
    _swPanBoundaryLatController.dispose();
    _swPanBoundaryLongController.dispose();
    _nePanBoundaryLatController.dispose();
    _nePanBoundaryLongController.dispose();
    _gridStartLatController.dispose();
    _gridStartLongController.dispose();
    _gridStepController.dispose();
    _horyzontalStepsCountController.dispose();
    _verticalStepsCountController.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    final settings = <Widget>[];
    settings.addAll(gridSettings);
    settings. add(const Divider());
    settings.addAll(mapSettings);
    settings. add(const Divider());
    settings.addAll(ownTrackSettings);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки'), centerTitle: true),
      body: FocusScope(
        node: _focusScopeNode,
        child: GestureDetector(
          child: Padding(
            padding: AppStyle.pagePadding,
            child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: settings,
            )),
          ),
          onTap: () => FocusScope.of(context).unfocus(),
        ),
      ),
    );
  }

  List<Widget> get mapSettings
  {
    final theme = Theme.of(context);
    final mapSettings = [
      Text('Настройки локальной карты',
        style: theme.textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _nePanBoundaryLatController,
        decoration: InputDecoration(
          labelText: 'Широта северо-восточной границы карты:',
          errorText: _nePanBoundaryLatError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _nePanBoundaryLatError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _nePanBoundaryLongController,
        decoration: InputDecoration(
          labelText: 'Долгота северо-восточной границы карты:',
          errorText: _nePanBoundaryLongError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _nePanBoundaryLongError = null),
      ),
      const SizedBox(height: 5.0),
      TextField(
        controller: _swPanBoundaryLatController,
        decoration: InputDecoration(
          labelText: 'Широта юго-западной границы карты:',
          errorText: _swPanBoundaryLatError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _swPanBoundaryLatError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _swPanBoundaryLongController,
        decoration: InputDecoration(
          labelText: 'Долгота юго-западной границы карты:',
          errorText: _swPanBoundaryLongError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onChanged: (value) => setState(() => _nePanBoundaryLongError = null),
      ),
      const SizedBox(height: 15.0),
      Row(children: [
        const Expanded(child: Text('Использовать локальную карту')),
        Switch(
          value: _useLocalMap,
          onChanged: (value) => setState(() => _useLocalMap = !_useLocalMap),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: ElevatedButton(
          child: const Text('Сохранить'),
          onPressed: _saveMapSettings,
        ),
      ),
    ];
    return mapSettings;
  }

  List<Widget> get gridSettings
  {
    final theme = Theme.of(context);
    final gridSettings = [
      const SizedBox(height: 10.0),
      Text('Настройки сетки',
        style: theme.textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _gridStartLatController,
        decoration: InputDecoration(
          labelText: 'Широта начальной точки',
          errorText: _gridStartLatError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _gridStartLatError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _gridStartLongController,
        decoration: InputDecoration(
          labelText: 'Долгота начальной точки',
          errorText: _gridStartLongError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _gridStartLongError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _gridStepController,
        decoration: InputDecoration(
          labelText: 'Шаг сетки, м:',
          errorText: _gridStepError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _gridStepError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _horyzontalStepsCountController,
        decoration: InputDecoration(
          labelText: 'Количество ячеек по горизотнтали, шт:',
          errorText: _horyzontalStepsCountError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) => setState(() => _horyzontalStepsCountError = null),
      ),
      const SizedBox(height: 15.0),
      TextField(
        controller: _verticalStepsCountController,
        decoration: InputDecoration(
          labelText: 'Количество ячеек по вертикали, шт:',
          errorText: _verticalStepsCountError,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onChanged: (value) => setState(() => _verticalStepsCountError = null),
      ),
      const SizedBox(height: 15.0),
      Row(children: [
        const Expanded(child: Text('Отобразить сетку')),
        Switch(
          value: _showGrid,
          onChanged: (value) => setState(() => _showGrid = !_showGrid),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: ElevatedButton(
          child: const Text('Сохранить'),
          onPressed: _saveGridSettings,
        ),
      ),
    ];
    return gridSettings;
  }

  List<Widget> get ownTrackSettings
  {
    final coordinateService = context.watch<CoordinatesService>();
    final settings = [
      Row(children: [
        const Expanded(child: Text('Отображать собственный трек')),
        Switch(
          value: coordinateService.showOwnTrack,
          onChanged: (value)
            => coordinateService.showOwnTrack = !coordinateService.showOwnTrack
        ),
      ]),
    ];
    return settings;
  }

  Future<void> _saveMapSettings() async
  {
    final validated = _validateMapSettings();
    if (!validated) return;
    final mapService = context.read<MapService>();
    final swLat = double.tryParse(_swPanBoundaryLatController.text);
    final swLong = double.tryParse(_swPanBoundaryLongController.text);
    final neLat = double.tryParse(_nePanBoundaryLatController.text);
    final neLong = double.tryParse(_nePanBoundaryLongController.text);
    LatLng? swBoundary;
    LatLng? neBoundary;
    if (swLat != null && swLong != null) {
      swBoundary = LatLng(swLat, swLong);
    }
    if (neLat != null && neLong != null) {
      neBoundary = LatLng(neLat, neLong);
    }
    final settings = MapSettings(
      useLocalMap: _useLocalMap,
      swPanBoundary: swBoundary,
      nePanBoundary: neBoundary,
    );
    mapService.setMap(settings);
    Routing.showToast('Настройки карты сохранены.');
  }

  Future<void> _saveGridSettings() async
  {
    final validated = _validateGridSettings();
    if (!validated) return;
    final gridService = context.read<GridService>();
    final startLat = double.tryParse(_gridStartLatController.text);
    final startLong = double.tryParse(_gridStartLongController.text);
    LatLng? startCoordinate;
    if (startLat != null && startLong != null) {
      startCoordinate = LatLng(startLat, startLong);
    }
    final settings = GridSettings(
      showGrid: _showGrid,
      startCoordinate: startCoordinate,
      gridStep: double.tryParse(_gridStepController.text),
      horizontalStepsCount: int.tryParse(_horyzontalStepsCountController.text),
      verticalStepsCount: int.tryParse(_verticalStepsCountController.text),
    );
    gridService.setGrid(settings);
    Routing.showToast('Настройки ceтки сохранены.');
  }

  bool _validateMapSettings()
  {
    if (!_useLocalMap) return true;
    if (_nePanBoundaryLatController.text.isEmpty) {
      setState(() => _nePanBoundaryLatError = 'Введите широту');
      return false;
    }
    final nePanBoundaryLat = double.tryParse(_nePanBoundaryLatController.text);
    if (
      nePanBoundaryLat == null
      || nePanBoundaryLat > 89.9
      || nePanBoundaryLat < -89.9
    ) {
      setState(() => _nePanBoundaryLatError = 'Широта введена некорректно');
      return false;
    }
    if (_nePanBoundaryLongController.text.isEmpty) {
      setState(() => _nePanBoundaryLongError = 'Введите долготу');
      return false;
    }
    final nePanBoundaryLong = double.tryParse(_swPanBoundaryLongController.text);
    if (
      nePanBoundaryLong == null
      || nePanBoundaryLong > 179.9
      || nePanBoundaryLong < -179.9
    ) {
      setState(() => _nePanBoundaryLongError = 'Долгота введена некорректно');
      return false;
    }
    if (_swPanBoundaryLatController.text.isEmpty) {
      setState(() => _swPanBoundaryLatError = 'Введите широту');
      return false;
    }
    final swPanBoundaryLat = double.tryParse(_swPanBoundaryLatController.text);
    if (
      swPanBoundaryLat == null
      || swPanBoundaryLat > 89.9
      || swPanBoundaryLat < -89.9
    ) {
      setState(() => _swPanBoundaryLatError = 'Широта введена некорректно');
      return false;
    }
    if (_swPanBoundaryLongController.text.isEmpty) {
      setState(() => _swPanBoundaryLongError = 'Введите долготу');
      return false;
    }
    final swPanBoundaryLong = double.tryParse(_swPanBoundaryLongController.text);
    if (
      swPanBoundaryLong == null
      || swPanBoundaryLong > 179.9
      || swPanBoundaryLong < -179.9
    ) {
      setState(() => _swPanBoundaryLongError = 'Долгота введена некорректно');
      return false;
    }
    if (swPanBoundaryLong > nePanBoundaryLong) {
      setState(() {
        _swPanBoundaryLongError = 'Долгота введена некорректно';
        _nePanBoundaryLongError = 'Долгота введена некорректно';
      });
      return false;
    }
    if (swPanBoundaryLat > nePanBoundaryLat) {
      setState(() {
        _swPanBoundaryLatError = 'Широта введена некорректно';
        _nePanBoundaryLatError = 'Широта введена некорректно';
      });
      return false;
    }
    return true;
  }

  bool _validateGridSettings()
  {
    if (!_showGrid) return true;
    if (_gridStartLatController.text.isEmpty) {
      setState(() => _gridStartLatError = 'Введите широту');
      return false;
    }
    final gridStartLat = double.tryParse(_gridStartLatController.text);
    if (
      gridStartLat == null
      || gridStartLat > 89.9
      || gridStartLat < -89.9
    ) {
      setState(() => _gridStartLatError = 'Широта введена некорректно');
      return false;
    }
    if (_gridStartLongController.text.isEmpty) {
      setState(() => _gridStartLongError = 'Введите долготу');
      return false;
    }
    final gridStartLong = double.tryParse(_gridStartLongController.text);
    if (
      gridStartLong == null
      || gridStartLong > 179.9
      || gridStartLong < -179.9
    ) {
      setState(() => _gridStartLongError = 'Долгота введена некорректно');
      return false;
    }
    if (_gridStepController.text.isEmpty) {
      setState(() => _gridStepError = 'Введите длину шага');
      return false;
    }
    final gridStep = double.tryParse(_gridStepController.text);
    if (gridStep == null || gridStep <= 0.0) {
      setState(() => _gridStartLongError = 'Шаг введен некорректно');
      return false;
    }
    if (_horyzontalStepsCountController.text.isEmpty) {
      setState(() => _horyzontalStepsCountError = 'Введите количество шагов');
      return false;
    }
    final horyzontalStepsCount = int.tryParse(
      _horyzontalStepsCountController.text
    );
    if (horyzontalStepsCount == null || horyzontalStepsCount <= 0) {
      setState(
        () => _horyzontalStepsCountError = 'Количество шагов некорректно'
      );
      return false;
    }
    if (_verticalStepsCountController.text.isEmpty) {
      setState(() => _gridStepError = 'Введите количество шагов');
      return false;
    }
    final verticalStepsCount = int.tryParse(
      _verticalStepsCountController.text
    );
    if (verticalStepsCount == null || verticalStepsCount <= 0) {
      setState(
        () => _verticalStepsCountError = 'Количество шагов некорректно'
      );
      return false;
    }
    return true;
  }

  late final TextEditingController _swPanBoundaryLatController;
  late final TextEditingController _swPanBoundaryLongController;
  late final TextEditingController _nePanBoundaryLatController;
  late final TextEditingController _nePanBoundaryLongController;
  late final TextEditingController _gridStartLatController;
  late final TextEditingController _gridStartLongController;
  late final TextEditingController _gridStepController;
  late final TextEditingController _horyzontalStepsCountController;
  late final TextEditingController _verticalStepsCountController;

  late final FocusScopeNode _focusScopeNode;

  String? _swPanBoundaryLatError;
  String? _swPanBoundaryLongError;
  String? _nePanBoundaryLatError;
  String? _nePanBoundaryLongError;
  String? _gridStartLatError;
  String? _gridStartLongError;
  String? _gridStepError;
  String? _horyzontalStepsCountError;
  String? _verticalStepsCountError;

  late bool _useLocalMap;
  late bool _showGrid;
}
