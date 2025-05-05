import 'dart:async';

import 'package:flutter/material.dart';

class PaginatedData extends StatefulWidget {
  const PaginatedData({
    super.key,
    required this.getPage,

    required this.getCount,
    required this.initialPage,
    required this.builder,
    this.bottomPadding = 64,
  });

  final FutureOr<List> Function(int page, int pageSize) getPage;
  final FutureOr<int> Function() getCount;
  final int initialPage;
  final Widget Function(BuildContext context, List data, bool isLoading)
  builder;
  final double bottomPadding;

  @override
  State<PaginatedData> createState() => _PaginatedDataState();
}

class _PaginatedDataState extends State<PaginatedData> {
  int currentPage = 1;
  int pageSize = 10;

  List pageData = [];
  int itemCount = 0;

  bool isLoading = true;

  // init

  @override
  void initState() {
    super.initState();
    initPageData();
    initCount();
  }

  initPageData() async {
    pageData = await widget.getPage(currentPage, pageSize);
    isLoading = false;
    setState(() {});
  }

  initCount() async {
    itemCount = await widget.getCount();
    setState(() {});
  }

  void _nextPage() async {
    setState(() {
      currentPage++;
    });
    pageData = await widget.getPage(currentPage, pageSize);
    setState(() {});
  }

  void _previousPage() async {
    setState(() {
      if (currentPage > 1) currentPage--;
    });

    pageData = await widget.getPage(currentPage, pageSize);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        widget.builder(context, pageData, false),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            SizedBox(width: 16.0),
            // Dropdown for number of items per page
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: pageSize,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 20, child: Text('20')),
                    DropdownMenuItem(value: 50, child: Text('50')),
                    DropdownMenuItem(value: 100, child: Text('100')),
                    DropdownMenuItem(value: 250, child: Text('250')),
                    DropdownMenuItem(value: 500, child: Text('500')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      pageSize = value;
                      currentPage = 1;
                      initPageData();
                    });
                  },
                ),
              ),
            ),

            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentPage > 1 ? _previousPage : null,
            ),

            // 1-10 of total
            Text(
              '${(currentPage - 1) * pageSize + 1}-${currentPage * pageSize > itemCount ? itemCount : currentPage * pageSize} of $itemCount',
            ), // Display current page info

            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage * pageSize < itemCount ? _nextPage : null,
            ),
          ],
        ),
        SizedBox(height: widget.bottomPadding),
      ],
    );
  }
}
