import 'package:flutter/material.dart';

import '../direction.dart';


class DirectionView extends StatefulWidget
{
  const DirectionView({Key? key}) : super(key: key);

  @override
  State<DirectionView> createState() => _DirectionViewState();
}


class _DirectionViewState extends State<DirectionView>
  with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context)
  {
    super.build(context);
    return const DirectionPage();
  }
}
