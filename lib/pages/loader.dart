import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../global.dart';
import '../routing/router.dart';
import 'loader_state.dart';


class LoaderPage extends StatefulWidget
{
  final Function(LoaderState) worker;

  const LoaderPage(this.worker, { final Key? key })
  : super(key: key);

  @override
  LoaderPageState createState() => LoaderPageState();
}


class LoaderPageState extends State<LoaderPage> with LoaderState
{
  @override
  void initState()
  {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.worker(this);
    });
  }

  @override
  Widget build(final BuildContext context)
  {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        Routing.hideToasts();
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(color: theme.primaryColor, child: loader),
      ),
    );
  }

  Widget get loader
  {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Hero(
              tag: 'loaderLogo',
              child: Global.images.logo(
                color: theme.cardColor,
                width: 80.0,
                height: 80.0
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(theme.canvasColor),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(message ?? '',
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                ],
              )
            ),
          ),
        ],
      )
    );
  }
}
