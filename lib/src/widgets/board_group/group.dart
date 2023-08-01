import 'dart:collection';

import 'package:flow_board/src/widgets/reorder_flex/drag_state.dart';
import 'package:flutter/material.dart';
import '../../rendering/board_overlay.dart';
import '../../utils/log.dart';
import '../reorder_phantom/phantom_controller.dart';
import '../reorder_flex/reorder_flex.dart';
import '../reorder_flex/drag_target_interceptor.dart';
import 'group_data.dart';

typedef OnGroupDragStarted = void Function(int index);

typedef OnGroupDragEnded = void Function(String groupId);

typedef OnGroupReorder = void Function(
  String groupId,
  int fromIndex,
  int toIndex,
);

typedef OnGroupDeleted = void Function(String groupId, int deletedIndex);

typedef OnGroupInserted = void Function(String groupId, int insertedIndex);

typedef FlowBoardCardBuilder = Widget Function(
  BuildContext context,
  FlowBoardGroupData groupData,
  FlowBoardGroupItem item,
);

typedef FlowBoardHeaderBuilder = Widget? Function(
  BuildContext context,
  FlowBoardGroupData groupData,
);

typedef FlowBoardFooterBuilder = Widget Function(
  BuildContext context,
  FlowBoardGroupData groupData,
);

abstract class FlowBoardGroupDataDataSource with ReoderFlexDataSource {
  FlowBoardGroupData get groupData;

  List<String> get acceptedGroupIds;

  @override
  String get identifier => groupData.id;

  @override
  UnmodifiableListView<FlowBoardGroupItem> get items => groupData.items;

  void debugPrint() {
    String msg = '[$FlowBoardGroupDataDataSource] $groupData data: ';
    for (var element in items) {
      msg = '$msg$element,';
    }

    Log.debug(msg);
  }
}

/// A [FlowBoardGroup] represents the group UI of the Board.
///
class FlowBoardGroup extends StatefulWidget {
  final FlowBoardGroupDataDataSource dataSource;
  final ScrollController? scrollController;
  final ReorderFlexConfig config;
  final OnGroupDragStarted? onDragStarted;
  final OnGroupReorder onReorder;
  final OnGroupDragEnded? onDragEnded;

  final BoardPhantomController phantomController;

  String get groupId => dataSource.groupData.id;

  final FlowBoardCardBuilder cardBuilder;

  final FlowBoardHeaderBuilder? headerBuilder;

  final FlowBoardFooterBuilder? footerBuilder;

  final EdgeInsets margin;

  final EdgeInsets itemMargin;

  final double cornerRadius;

  final Color backgroundColor;

  final bool stretchGroupHeight;

  final DraggingStateStorage? dragStateStorage;

  final ReorderDragTargeKeys? dragTargetKeys;

  final ReorderFlexAction? reorderFlexAction;

  const FlowBoardGroup({
    Key? key,
    this.headerBuilder,
    this.footerBuilder,
    required this.cardBuilder,
    required this.onReorder,
    required this.dataSource,
    required this.phantomController,
    this.reorderFlexAction,
    this.dragStateStorage,
    this.dragTargetKeys,
    this.scrollController,
    this.onDragStarted,
    this.onDragEnded,
    this.margin = EdgeInsets.zero,
    this.itemMargin = EdgeInsets.zero,
    this.cornerRadius = 0.0,
    this.backgroundColor = Colors.transparent,
    this.stretchGroupHeight = true,
  })  : config = const ReorderFlexConfig(),
        super(key: key);

  @override
  State<FlowBoardGroup> createState() => _FlowBoardGroupState();
}

class _FlowBoardGroupState extends State<FlowBoardGroup> {
  final GlobalKey _columnOverlayKey =
      GlobalKey(debugLabel: '$FlowBoardGroup overlay key');
  late BoardOverlayEntry _overlayEntry;

  @override
  void initState() {
    _overlayEntry = BoardOverlayEntry(
      builder: (BuildContext context) {
        final children = widget.dataSource.groupData.items
            .map((item) => _buildWidget(context, item))
            .toList();

        final header =
            widget.headerBuilder?.call(context, widget.dataSource.groupData);

        final footer =
            widget.footerBuilder?.call(context, widget.dataSource.groupData);

        final interceptor = CrossReorderFlexDragTargetInterceptor(
          reorderFlexId: widget.groupId,
          delegate: widget.phantomController,
          acceptedReorderFlexIds: widget.dataSource.acceptedGroupIds,
          draggableTargetBuilder: PhantomDraggableBuilder(),
        );

        Widget reorderFlex = ReorderFlex(
          key: ValueKey(widget.groupId),
          dragStateStorage: widget.dragStateStorage,
          dragTargetKeys: widget.dragTargetKeys,
          scrollController: widget.scrollController,
          config: widget.config,
          onDragStarted: (index) {
            widget.phantomController.groupStartDragging(widget.groupId);
            widget.onDragStarted?.call(index);
          },
          onReorder: ((fromIndex, toIndex) {
            if (widget.phantomController.shouldReorder(widget.groupId)) {
              widget.onReorder(widget.groupId, fromIndex, toIndex);
              widget.phantomController.updateIndex(fromIndex, toIndex);
            }
          }),
          onDragEnded: () {
            widget.phantomController.groupEndDragging(widget.groupId);
            widget.onDragEnded?.call(widget.groupId);
            widget.dataSource.debugPrint();
          },
          dataSource: widget.dataSource,
          interceptor: interceptor,
          reorderFlexAction: widget.reorderFlexAction,
          children: children,
        );

        reorderFlex = Flexible(
          fit: widget.stretchGroupHeight ? FlexFit.tight : FlexFit.loose,
          child: Padding(padding: widget.itemMargin, child: reorderFlex),
        );

        return Container(
          margin: widget.margin,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.cornerRadius),
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header,
              reorderFlex,
              if (footer != null) footer,
            ],
          ),
        );
      },
      opaque: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BoardOverlay(
      key: _columnOverlayKey,
      initialEntries: [_overlayEntry],
    );
  }

  Widget _buildWidget(BuildContext context, FlowBoardGroupItem item) {
    if (item is PhantomGroupItem) {
      return PassthroughPhantomWidget(
        key: UniqueKey(),
        opacity: widget.config.draggingWidgetOpacity,
        passthroughPhantomContext: item.phantomContext,
      );
    } else {
      return widget.cardBuilder(context, widget.dataSource.groupData, item);
    }
  }
}
