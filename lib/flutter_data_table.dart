library flutter_data_table;

import 'package:flutter/material.dart';
import 'flutter_data_table_style.dart';

class DQDataTable extends StatefulWidget {
  final int rowLength; //行数，不包含标题行
  final int columnLength; //列数，不包含标题列
  final Widget topLeftCell; //左上角Cell，固定不滚动
  final Widget Function(int colulmnIndex) columnTitleBuilder; //构造列标题cell
  final Widget Function(int rowIndex) rowTitleBuilder; //构造行标题cell
  final Widget Function(int columnIndex, int rowIndex) contentCellBuilder; //构造内容标题cell
  final DQDataTableStyle tableStyle; //列表高度、宽度等样式
  final BoxFit cellFit;
  final VoidCallback scrolledToBottomCallBack;//滚动到底部时的回调，可以加载更多

  DQDataTable(
      {Key key,
        @required this.rowLength,
        @required this.columnLength,
        @required this.columnTitleBuilder,
        @required this.rowTitleBuilder,
        @required this.contentCellBuilder,
        this.topLeftCell = const Text(''),
        this.cellFit = BoxFit.scaleDown,
        this.tableStyle = DQDataTableStyle.base,
        this.scrolledToBottomCallBack})
      : super(key: key) {
    assert(columnLength != null);
    assert(rowLength != null);
    assert(columnTitleBuilder != null);
    assert(rowTitleBuilder != null);
    assert(contentCellBuilder != null);
  }

  @override
  _DQDataTableState createState() => _DQDataTableState();
}

class _DQDataTableState extends State<DQDataTable> {
  final ScrollController _verticalTitleController = ScrollController();
  final ScrollController _verticalContentController = ScrollController();

  final ScrollController _horizontalContentController = ScrollController();
  final ScrollController _horizontalTitleController = ScrollController();

  _SyncScrollController _verticalSyncController;
  _SyncScrollController _horizontalSyncController;

  @override
  void initState() {
    _verticalSyncController = _SyncScrollController([_verticalTitleController, _verticalContentController]);
    _horizontalSyncController = _SyncScrollController([_horizontalTitleController, _horizontalContentController]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    _verticalContentController.jumpTo(0);
//    _horizontalContentController.jumpTo(0);
//    _verticalTitleController.jumpTo(0);
//    _horizontalTitleController.jumpTo(0);

    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              topLeftCell(),
              columnTitleRow(), //列表标题 行
            ],
          ),
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    rowTitleColumn(), //行标题 列
                    tableContentBody(), //内容行、列
                  ])),
        ],
      ),
    );
  }

  /*左上角单独的Cell*/
  Widget topLeftCell() {
    return Container(
      width: widget.tableStyle.rowTitleWidth,
      height: widget.tableStyle.columnTitleHeight,
      decoration: BoxDecoration(
          color: widget.tableStyle.rowTitleColor,
          border: Border.all(
            color: widget.tableStyle.splitLineColor,
            width: widget.tableStyle.splitLineWidth,
          )),
      child: FittedBox(
        fit: widget.cellFit,
        child: widget.topLeftCell,
      ),
    );
  }

  /*列标题 的行*/
  Widget columnTitleRow() {
    return Expanded(
        child: NotificationListener<ScrollNotification>(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.columnLength, (int index) {
                return Container(
                  decoration: BoxDecoration(
                      color: widget.tableStyle.columnTitleColor,
                      border: Border.all(
                        color: widget.tableStyle.splitLineColor,
                        width: widget.tableStyle.splitLineWidth,
                      )),
                  width: widget.tableStyle.contentCellWidth,
                  height: widget.tableStyle.columnTitleHeight,
                  child: Center(
                    child: widget.columnTitleBuilder(index),
                  ),
                );
              }),
            ),
            controller: _horizontalTitleController,
          ),
          onNotification: (ScrollNotification notification) {
            _horizontalSyncController.processNotification(notification, _horizontalTitleController);
            return true;
          },
        ));
  }

  /*行标题 的列*/
  Widget rowTitleColumn() {
    return NotificationListener<ScrollNotification>(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(widget.rowLength, (int index) {
              return Container(
                decoration: BoxDecoration(
                    color: widget.tableStyle.columnTitleColor,
                    border: Border.all(
                      color: widget.tableStyle.splitLineColor,
                      width: widget.tableStyle.splitLineWidth,
                    )),
                width: widget.tableStyle.rowTitleWidth,
                height: widget.tableStyle.contentCellHeight,
                child: FittedBox(
                  fit: widget.cellFit,
                  child: widget.rowTitleBuilder(index),
                ),
              );
            }),
          ),
          controller: _verticalTitleController,
        ),
        onNotification: (ScrollNotification notification) {
          _verticalSyncController.processNotification(notification, _verticalTitleController);
          return true;
        });
  }

  /*内容区域行和列*/
  Widget tableContentBody() {
    return Expanded(
        child: NotificationListener<ScrollNotification>(onNotification: (ScrollNotification notification) {
          _horizontalSyncController.processNotification(notification, _horizontalContentController);
          return true;
        },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalContentController,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                _verticalSyncController.processNotification(notification, _verticalContentController);
                handleContentScrollDown(notification);
                return true;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _verticalContentController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.rowLength, (int rowIndex) {
                    return Row(
                      children:
                      List.generate(widget.columnLength, (int columnIndex) {
                        return Container(
                          decoration: BoxDecoration(
                              color: widget.tableStyle.contentColor,
                              border: Border.all(
                                color: widget.tableStyle.splitLineColor,
                                width: widget.tableStyle.splitLineWidth,
                              )),
                          width: widget.tableStyle.contentCellWidth,
                          height: widget.tableStyle.contentCellHeight,
                          child: FittedBox(
                            fit: widget.cellFit,
                            child: widget.contentCellBuilder(columnIndex, rowIndex),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ));
  }

  /*处理内容区域滚动到底部*/
  void handleContentScrollDown(ScrollNotification notification){
    if(notification is ScrollEndNotification && _verticalContentController.offset >= notification.metrics.maxScrollExtent){
      if(widget.scrolledToBottomCallBack != null){
        widget.scrolledToBottomCallBack();
      }
    }
  }
}

/// 同步滚动方向
class _SyncScrollController {
  _SyncScrollController(List<ScrollController> controllers) {
    controllers.forEach((controller) => _registeredScrollControllers.add(controller));
  }

  final List<ScrollController> _registeredScrollControllers = [];

  ScrollController _scrollingController;
  bool _scrollingActive = false;

  processNotification(ScrollNotification notification, ScrollController sender) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = sender;
      _scrollingActive = true;
      return;
    }

    if (identical(sender, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return;
      }

      if (notification is ScrollUpdateNotification) {
        for (ScrollController controller in _registeredScrollControllers) {
          if (identical(_scrollingController, controller)) continue;
          controller.jumpTo(_scrollingController.offset);
        }
      }
    }
  }
}