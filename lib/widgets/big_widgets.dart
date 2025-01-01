import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:music/common/theme.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class SwipeCallbackWidget extends StatefulWidget {
  final Function onSwipeLeft;
  final Function onSwipeRight;
  final Widget child;

  const SwipeCallbackWidget({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.child,
  });

  @override
  SwipeCallbackWidgetState createState() => SwipeCallbackWidgetState();
}

class SwipeCallbackWidgetState extends State<SwipeCallbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragDistance = 0.0;
  static const double _swipeThreshold = 100.0;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {
              _dragDistance = _controller.value;
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.primaryDelta ?? 0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragDistance.abs() > _swipeThreshold) {
      if (_dragDistance > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    }
    _controller.reverse(from: _dragDistance);
    _dragDistance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Transform.translate(
            offset: Offset(_dragDistance, 0), child: widget.child));
  }
}

class SearchWidget<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final bool Function(T item, String query) searchMatcher;

  const SearchWidget(
      {super.key,
      required this.items,
      required this.itemBuilder,
      required this.searchMatcher});

  @override
  State<SearchWidget<T>> createState() => _SearchWidgetState<T>();
}

class _SearchWidgetState<T> extends State<SearchWidget<T>> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<T> _searchResults = <T>[].obs;

  void _updateSearchResults(String query) {
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }
    _searchResults.value = widget.items
        .where((item) => widget.searchMatcher(item, query))
        .toList();
  }

  Widget searchP() {
    final iconButton = IconButton(
        icon: AppTheme.nI(Icons.clear, Colors.white, 25),
        onPressed: () {
          _searchController.clear();
          _updateSearchResults('');
        });
    return Scaffold(
        appBar: AppBar(
            title: _buildSearchBar(),
            centerTitle: true,
            backgroundColor: AppTheme.darkBlue,
            actions: [w(5.w), iconButton, w(10.w)],
            leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  _searchController.clear();
                  FocusManager.instance.primaryFocus?.unfocus();
                })),
        body: SearchPage(
          searchResults: _searchResults,
          itemBuilder: widget.itemBuilder,
        ));
  }

  Widget _buildSearchBar() {
    return KeyboardDismisser(
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "搜索",
                border: InputBorder.none,
              ),
              onChanged: _updateSearchResults,
              onTap: () {
                if (Get.currentRoute == "/") {
                  Get.to(() => searchP());
                }
              })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }
}

class SearchPage<T> extends StatefulWidget {
  final RxList<T> searchResults;
  final Widget Function(T item) itemBuilder;
  const SearchPage(
      {super.key, required this.searchResults, required this.itemBuilder});

  @override
  State<SearchPage<T>> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<SearchPage<T>> {
  @override
  Widget build(BuildContext context) {
    final list = widget.searchResults;
    return Scaffold(
        body: Stack(children: [
      Obx(() {
        return list.isEmpty
            ? AppTheme.bk("无搜索", 25).center()
            : ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.only(
                    left: 10.w, top: 10.h, right: 5.w, bottom: 20.h),
                itemBuilder: (context, index) {
                  return widget.itemBuilder(list[index]);
                });
      })
    ]));
  }
}
