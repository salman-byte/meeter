import 'package:cr_calendar/cr_calendar.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/res/colors.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Draggable bottom sheet with events for the day.
class DayEventsBottomSheet extends StatelessWidget {
  const DayEventsBottomSheet({
    required this.screenHeight,
    required this.events,
    required this.day,
    Key? key,
  }) : super(key: key);

  final List<EventModel> events;
  final DateTime day;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) {
          return events.isEmpty
              ? const Center(child: Text('No events for this day'))
              : ListView.builder(
                  controller: controller,
                  itemCount: events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Text(day.format('dd/MM/yy')),
                      );
                    } else {
                      final event = events[index - 1];
                      return Container(
                          height: 100,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      Container(
                                        color:
                                            eventColors[event.eventColorCode!],
                                        width: 6,
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    event.eventSubject!,
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: CustomButton(
                                                        text:
                                                            'join this meeting',
                                                        autoSize: true,
                                                        onPressed: () => launch(
                                                            '${event.eventMeetLink}')),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${DateTime.fromMillisecondsSinceEpoch(event.eventBegin!).format(kDateRangeFormat)} - '
                                                '${DateTime.fromMillisecondsSinceEpoch(event.eventEnd!).format(kDateRangeFormat)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ))
                                    ],
                                  ))));
                    }
                  });
        });
  }
}
