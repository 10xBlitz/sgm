import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:sgm/widgets/calendar_view/calendarview_controller.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:sgm/widgets/calendar_view/widget/day_calendar_view.dart';

/// Theme configuration for the calendar view
class CalendarTheme {
  static const headerBackgroundColor = Color(0xFFF1E6CF);
  static const weekdayHeaderColor = Color(0xFFD2B771);
  static const taskBackgroundColor = Color(0xFFBEDAB7);
  static const borderColor = Color(0xFFECECEC);

  static const weekHeight = 86.0;
  static const daySpacing = 0.0;
  static const headerHeight = 0.0;
  static const eventHeight = 25.0;
  static const eventSpacing = 2.0;
  static const spaceBetweenHeaderAndEvents = 6.0;

  static const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const maxVisibleTasks = 3;
}

/// Main calendar view widget
class CalendarView extends StatelessWidget {
  final String? projectId;

  const CalendarView({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    // Create a controller that manages the calendar state and data
    return Scaffold(
      body: ChangeNotifierProvider(
        create:
            (_) => CalendarViewController(
              projectId: projectId,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            ),
        child: const _CalendarViewContent(),
      ),
    );
  }
}

/// The main content of the calendar view.
class _CalendarViewContent extends StatelessWidget {
  const _CalendarViewContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<CalendarViewController>(context);
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: mediaQuery.size.height,
      child: Column(
        children: [
          // Month header with navigation buttons
          _buildMonthHeader(theme, controller),
          // Calendar grid showing days and events
          _buildCalendarBody(controller),
        ],
      ),
    );
  }

  /// Builds the month header with navigation controls.
  Widget _buildMonthHeader(ThemeData theme, CalendarViewController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CalendarTheme.headerBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Display current month and year
          Text(
            DateFormat('MMMM yyyy').format(controller.currentMonth),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Navigation buttons row
          _NavigationButtons(controller: controller),
        ],
      ),
    );
  }

  Widget _buildCalendarBody(CalendarViewController controller) {
    return Expanded(
      child:
          controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const _MonthCalendarView(),
    );
  }
}

/// Navigation buttons for the calendar
class _NavigationButtons extends StatelessWidget {
  final CalendarViewController controller;

  const _NavigationButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavigationButton(
          icon: Icons.arrow_back_ios,
          size: 16,
          tooltip: 'Previous Month',
          onPressed: controller.previousMonth,
        ),
        _NavigationButton(
          icon: Icons.today,
          tooltip: 'Today',
          onPressed: controller.goToToday,
        ),
        _NavigationButton(
          icon: Icons.arrow_forward_ios,
          size: 16,
          tooltip: 'Next Month',
          onPressed: controller.nextMonth,
        ),
        _NavigationButton(
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: controller.loadTasks,
        ),
      ],
    );
  }
}

/// Individual navigation button
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final double? size;
  final String tooltip;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    this.size,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: Colors.black87),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

class _MonthCalendarView extends StatefulWidget {
  const _MonthCalendarView();

  @override
  State<_MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends State<_MonthCalendarView> {
  // We'll use the CalendarViewController's eventsController instead of creating our own
  final GlobalKey<State> _calendarKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _MonthCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final calendarController = Provider.of<CalendarViewController>(context);

    return Column(
      children: [
        // Weekday header (S, M, T, W, T, F, S)
        _WeekdayHeader(),

        // Month calendar from infinite_calendar_view
        Expanded(
          child: _CalendarGrid(
            gKey: _calendarKey,
            controller: calendarController,
          ),
        ),
      ],
    );
  }
}

/// Weekday header showing S, M, T, W, T, F, S
class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CalendarTheme.weekdayHeaderColor,
      child: Row(
        children: List.generate(
          7,
          (index) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                CalendarTheme.weekdayLabels[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Calendar grid showing days and events
class _CalendarGrid extends StatelessWidget {
  final GlobalKey<State> gKey;
  final CalendarViewController controller;

  const _CalendarGrid({required this.gKey, required this.controller})
    : super(key: gKey);

  @override
  Widget build(BuildContext context) {
    return EventsMonths(
      key: gKey,
      controller: controller.eventsController,
      initialMonth: controller.currentMonth,
      onMonthChange: (month) => _handleMonthChange(month, controller),
      weekParam: const WeekParam(
        weekHeight: CalendarTheme.weekHeight,
        daySpacing: CalendarTheme.daySpacing,
        headerHeight: CalendarTheme.headerHeight,
        weekDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CalendarTheme.borderColor, width: 1.0),
          ),
        ),
      ),
      daysParam: DaysParam(
        headerHeight: 30,
        eventHeight: CalendarTheme.eventHeight,
        eventSpacing: CalendarTheme.eventSpacing,
        spaceBetweenHeaderAndEvents: CalendarTheme.spaceBetweenHeaderAndEvents,
        dayHeaderBuilder: (day) => CustomDayHeader(day: day),
        dayEventBuilder:
            (event, width, height) =>
                TaskEventWidget(event: event, height: height, width: width),
        // TODO put it back
        // dayMoreEventsBuilder: (count) => MoreEventsIndicator(count: count),
        onDayTapUp: (day) => _showDayDetail(context, controller, day),
      ),
    );
  }

  void _handleMonthChange(DateTime month, CalendarViewController controller) {
    if (month.month != controller.currentMonth.month ||
        month.year != controller.currentMonth.year) {
      MyLogger.d(
        "DEBUG/MONTH: Month changed from ${DateFormat('yyyy-MM').format(controller.currentMonth)} to ${DateFormat('yyyy-MM').format(month)}",
      );
      controller.updateMonth(month);
    }
  }

  void _showDayDetail(
    BuildContext context,
    CalendarViewController controller,
    DateTime day,
  ) {
    MyLogger.d(
      "Navigating to day view for ${DateFormat('yyyy-MM-dd').format(day)}",
    );

    // Navigate to the day view page and pass the task data through the controller
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DayCalendarView(
              initialDate: day,
              projectId: controller.projectId,
              tasksByDay: controller.tasksByDay,
            ),
      ),
    );
  }
}

/// Custom header for each day in the calendar
/// Displays the day number with appropriate styling
class CustomDayHeader extends StatelessWidget {
  final DateTime day;

  const CustomDayHeader({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final isCurrentMonth = day.month == DateTime.now().month;

    // Simple day number display
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        day.day.toString(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _getDayColor(isToday, isCurrentMonth),
        ),
      ),
    );
  }

  Color _getDayColor(bool isToday, bool isCurrentMonth) {
    if (isToday) return Colors.black;
    return isCurrentMonth ? Colors.black87 : Colors.grey.shade400;
  }
}

/// Widget to display events in the calendar
/// Shows a task with icon and title
class TaskEventWidget extends StatelessWidget {
  final Event event;
  final double? width;
  final double? height;

  const TaskEventWidget({
    super.key,
    required this.event,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Light green background for events as shown in the image
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: CalendarTheme.taskBackgroundColor,
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.title ?? 'Untitled Event',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to show "x others" indicator for days with many events
class MoreEventsIndicator extends StatelessWidget {
  final int count;

  const MoreEventsIndicator({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      alignment: Alignment.centerLeft,
      child: Text(
        '$count others',
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}

// ignore_for_file: must_be_immutable
// ignore: unused_element
class _CalendarDayCell extends StatelessWidget {
  final DateTime day;

  const _CalendarDayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarViewController>(context);
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final isCurrentMonth = day.month == DateTime.now().month;
    final List<TaskRow> tasks =
        controller.tasksByDay[DateTime(day.year, day.month, day.day)] ?? [];

    return InkWell(
      onTap: () => _showDayDetail(context, controller, tasks),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          color: _getCellBackgroundColor(isToday, isCurrentMonth),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayNumber(isToday, isCurrentMonth),
            _buildTasksList(tasks),
            if (tasks.length > CalendarTheme.maxVisibleTasks)
              _buildOverflowIndicator(tasks),
          ],
        ),
      ),
    );
  }

  /// Shows the day detail bottom sheet.
  void _showDayDetail(
    BuildContext context,
    CalendarViewController controller,
    List<TaskRow> tasks,
  ) {
    MyLogger.d(
      "Navigating to day view for ${DateFormat('yyyy-MM-dd').format(day)}",
    );

    // Navigate to the day view page and pass the task data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DayCalendarView(
              initialDate: day,
              projectId: controller.projectId,
              tasksByDay: controller.tasksByDay,
            ),
      ),
    );
  }

  /// Builds the day number indicator.
  Widget _buildDayNumber(bool isToday, bool isCurrentMonth) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        day.day.toString(),
        style: TextStyle(
          color: _getDayColor(isToday, isCurrentMonth),
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// Builds the list of task indicators.
  Widget _buildTasksList(List<TaskRow> tasks) {
    return Expanded(
      child:
          tasks.isEmpty
              ? const SizedBox() // Empty placeholder when no tasks
              : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount:
                    tasks.length > CalendarTheme.maxVisibleTasks
                        ? CalendarTheme.maxVisibleTasks
                        : tasks.length,
                itemBuilder: (context, taskIndex) {
                  return _TaskIndicator(task: tasks[taskIndex]);
                },
              ),
    );
  }

  /// Builds the "n others" overflow indicator.
  Widget _buildOverflowIndicator(List<TaskRow> tasks) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        '${tasks.length - CalendarTheme.maxVisibleTasks} others',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
      ),
    );
  }

  Color _getCellBackgroundColor(bool isToday, bool isCurrentMonth) {
    if (isToday) return Colors.grey.shade200;
    return isCurrentMonth ? Colors.transparent : Colors.grey.shade50;
  }

  Color _getDayColor(bool isToday, bool isCurrentMonth) {
    if (isToday) return Colors.black;
    return isCurrentMonth ? Colors.black87 : Colors.grey.shade400;
  }
}

/// A visual indicator for a task in the calendar.
class _TaskIndicator extends StatelessWidget {
  final TaskRow task;

  const _TaskIndicator({required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarViewController>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: controller.getStatusColor(task.status),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              task.title ?? 'Untitled Task',
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
