import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list.dart';
import 'package:flutter/material.dart';

class TappableDragAndDropList extends DragAndDropList {
  /// The widget that is displayed at the top of the list.
  final Widget header;

  /// The widget that is displayed at the bottom of the list.
  final Widget footer;

  /// The widget that is displayed to the left of the list.
  final Widget leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final List<DragAndDropItem> children = <DragAndDropItem>[];

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;

  final Function onTap;

  final Function onLongPress;

  final EdgeInsetsGeometry padding;

  TappableDragAndDropList({
    List<DragAndDropItem> children,
    this.header,
    this.footer,
    this.leftSide,
    this.rightSide,
    this.contentsWhenEmpty,
    this.lastTarget,
    this.decoration,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.canDrag = true,
    this.onTap,
    this.onLongPress,
    this.padding = EdgeInsets.zero,
  }) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    return Material(
        child: Padding(
            padding: this.padding, child: super.generateWidget(params)));
  }
}
