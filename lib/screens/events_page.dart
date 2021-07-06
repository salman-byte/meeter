import 'package:cr_calendar/cr_calendar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:provider/provider.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';

import '../res/colors.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/day_events_bottom_sheet.dart';
import '../widgets/day_item_widget.dart';
import '../widgets/event_widget.dart';
import '../widgets/week_days_widget.dart';
import 'authUI.dart';

/// Main calendar page.
class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _currentDate = DateTime.now();
  // bool isUserAuthenticated = false;

  late CrCalendarController _calendarController;
  List<EventModel> eventList = [];
  ValueNotifier<String> _dateToShow =
      ValueNotifier<String>(DateTime.now().format(kMonthFormatWidthYear));

  @override
  void initState() {
    _setTexts(_currentDate.year, _currentDate.month);

    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStatusNotifier>(
      builder: (context, authStatusNotifier, child) {
        return !authStatusNotifier.isUserAuthenticated
            ? Scaffold(
                body: SignInSignUpFlow(
                inDialogMode: false,
              ))
            : FutureBuilder<CrCalendarController>(
                future: _createEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Scaffold(body: LinearProgressIndicator());
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    floatingActionButton: FloatingActionButton(
                      tooltip: 'Go to current date',
                      child: const Icon(Icons.calendar_today),
                      onPressed: _showCurrentMonth,
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          /// Calendar control row.
                          buildRowForNavigatorButtonsAndMonthNameDisplay(),

                          /// Calendar view.
                          buildCalendarViewExpanded(snapshot),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  Row buildRowForNavigatorButtonsAndMonthNameDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _changeCalendarPage(showNext: false);
          },
        ),
        ValueListenableBuilder(
          builder: (BuildContext context, String date, Widget? child) {
            return Text(
              date,
              style: const TextStyle(
                  fontSize: 16, color: violet, fontWeight: FontWeight.w600),
            );
          },
          valueListenable: _dateToShow,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            _changeCalendarPage(showNext: true);
          },
        ),
      ],
    );
  }

  Expanded buildCalendarViewExpanded(
      AsyncSnapshot<CrCalendarController> snapshot) {
    return Expanded(
      child: CrCalendar(
        firstDayOfWeek: WeekDay.monday,
        eventsTopPadding: 32,
        initialDate: DateTime.now(),
        maxEventLines: 4,
        controller: snapshot.data ??
            CrCalendarController(onSwipe: _onCalendarPageChanged),
        forceSixWeek: false,
        dayItemBuilder: (builderArgument) =>
            DayItemWidget(properties: builderArgument),
        weekDaysBuilder: (day) => WeekDaysWidget(day: day),
        eventBuilder: (drawer) => EventWidget(drawer: drawer),
        onDayClicked: (List<CalendarEventModel> events, DateTime day) {
          List<EventModel> eventModelList = [];
          events.forEach((element) {
            eventModelList.add(eventList.singleWhere((listElement) =>
                listElement.eventSubject == element.name &&
                listElement.eventColorCode ==
                    eventColors.indexOf(element.eventColor)));
          });
          _showDayEventsInModalSheet(eventModelList, day);
        },
        minDate: DateTime.now().subtract(const Duration(days: 180)),
        maxDate: DateTime.now().add(const Duration(days: 180)),
      ),
    );
  }

  /// Control calendar with arrow buttons.
  void _changeCalendarPage({required bool showNext}) => showNext
      ? _calendarController.swipeToNextMonth()
      : _calendarController.swipeToPreviousPage();

  void _onCalendarPageChanged(int year, int month) {
    // setState(() {
    _setTexts(year, month);
    // });
  }

  /// Set app bar text and month name over calendar.
  void _setTexts(int year, int month) {
    final date = DateTime(year, month);
    _dateToShow.value = date.format(kMonthFormatWidthYear);
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

  Future<CrCalendarController> _createEvents() async {
    eventList = await FirestoreService.instance.getEventDoc();
    // final now = _currentDate;

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
    return _calendarController;
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
