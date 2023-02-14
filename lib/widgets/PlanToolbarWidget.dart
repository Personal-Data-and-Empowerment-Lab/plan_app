import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/bloc.dart';

class PlanToolbarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        children: _mapStateToToolbar(BlocProvider.of<EditorBloc>(context)));
  }

  List<Widget> _mapStateToToolbar(EditorBloc editorBloc) {
    Widget copyTool = _buildCopyTool(editorBloc);
    return [copyTool];
    // Widget newlineTool = _buildNewLineTool(editorBloc);
    // return [copyTool, newlineTool];
  }

  Widget _buildCopyTool(EditorBloc editorBloc) {
    return Expanded(
//                decoration: new BoxDecoration(
//                color: Theme.of(context).cardColor),
//                  fit: FlexFit.loose,
      child: IconButton(
        icon: Icon(Icons.content_copy),
        onPressed: () => editorBloc.add(CopyPlan()),
      ),
    );
  }

  /*
  Widget _buildNewLineTool(EditorBloc editorBloc) {
    return Expanded(
      child: IconButton(
        icon: Icon(Icons.content_copy),
        onPressed: () => editorBloc.add(AddTopNewLine()),
      ),
    );
  }
*/

}
