import 'package:cr_calendar/cr_calendar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/services/firestoreService.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';

import '../res/colors.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/day_events_bottom_sheet.dart';
import '../widgets/day_item_widget.dart';
import '../widgets/event_widget.dart';
import '../widgets/week_days_widget.dart';

/// Main calendar page.
class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _currentDate = DateTime.now();

  late CrCalendarController _calendarController;
  late String _appbarTitle;
  late String _monthName;
  List<EventModel> eventList = [];

  @override
  void initState() {
    _setTexts(_currentDate.year, _currentDate.month);
    // _createEvents();
    _calendarController = CrCalendarController(
      onSwipe: _onCalendarPageChanged,
      // events: calendreEvents,
    );
    FirestoreService.instance.getEventDoc().then((data) {
      eventList = data;

      _createEvents();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EventPage oldWidget) {
    FirestoreService.instance.getEventDoc().then((data) {
      eventList = data;

      _createEvents();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   centerTitle: false,
      //   title: Text(_appbarTitle),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Go to current date',
      //       icon: const Icon(Icons.calendar_today),
      //       onPressed: _showCurrentMonth,
      //     ),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// Calendar control row.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    _changeCalendarPage(showNext: false);
                  },
                ),
                Text(
                  _monthName,
                  style: const TextStyle(
                      fontSize: 16, color: violet, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    _changeCalendarPage(showNext: true);
                  },
                ),
              ],
            ),

            /// Calendar view.
            Expanded(
              child: CrCalendar(
                firstDayOfWeek: WeekDay.monday,
                eventsTopPadding: 32,
                initialDate: _currentDate,
                maxEventLines: 3,
                controller: _calendarController,
                forceSixWeek: true,
                dayItemBuilder: (builderArgument) =>
                    DayItemWidget(properties: builderArgument),
                weekDaysBuilder: (day) => WeekDaysWidget(day: day),
                eventBuilder: (drawer) => EventWidget(drawer: drawer),
                onDayClicked: (List<CalendarEventModel> events, DateTime day) {
                  List<EventModel> eventList = [];
                  events.forEach((element) {
                    eventList.add(eventList.singleWhere((listElement) =>
                        listElement.eventSubject == element.name &&
                        listElement.eventColorCode ==
                            eventColors.indexOf(element.eventColor)));
                  });
                  _showDayEventsInModalSheet(eventList, day);
                },
                minDate: DateTime.now().subtract(const Duration(days: 1000)),
                maxDate: DateTime.now().add(const Duration(days: 180)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Control calendar with arrow buttons.
  void _changeCalendarPage({required bool showNext}) => showNext
      ? _calendarController.swipeToNextMonth()
      : _calendarController.swipeToPreviousPage();

  void _onCalendarPageChanged(int year, int month) {
    setState(() {
      _setTexts(year, month);
    });
  }

  /// Set app bar text and month name over calendar.
  void _setTexts(int year, int month) {
    final date = DateTime(year, month);
    _appbarTitle = date.format(kAppBarDateFormat);
    _monthName = date.format(kMonthFormat);
  }

  /// Show current month page.
  void _showCurrentMonth() {
    _calendarController.goToDate(_currentDate);
  }

  /// Show [CreateEventDialog] with settings for new event.
  Future<void> _addEvent() async {
    final event = await showDialog(
        context: context, builder: (context) => const CreateEventDialog());
    if (event != null) {
      _calendarController.addEvent(event);
    }
  }

  Future<void> _createEvents() async {
    eventList = await FirestoreService.instance.getEventDoc();
    final now = _currentDate;

    List<CalendarEventModel> calendreEvents = [];

    calendreEvents = eventList.fold(
        calendreEvents,
        (previousValue, element) => [
              ...previousValue,
              CalendarEventModel(
                  begin:
                      DateTime.fromMillisecondsSinceEpoch(element.eventBegin!),
                  end: DateTime.fromMillisecondsSinceEpoch(element.eventEnd!),
                  name: element.eventSubject!,
                  eventColor: eventColors[element.eventColorCode!])
            ]);
    _calendarController = CrCalendarController(
      onSwipe: _onCalendarPageChanged,
      events: calendreEvents,
    );
    setState(() {});
  }

  void _showDayEventsInModalSheet(List<EventModel> events, DateTime day) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        isScrollControlled: true,
        context: context,
        builder: (context) => DayEventsBottomSheet(
              events: events,
              day: day,
              screenHeight: MediaQuery.of(context).size.height,
            ));
  }
}
