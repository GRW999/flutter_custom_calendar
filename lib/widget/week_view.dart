import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/calendar_provider.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';
import 'package:provider/provider.dart';

/**
 * 周视图，只显示本周的日子
 */
class WeekView extends StatefulWidget {
  final int year;
  final int month;
  final DateModel firstDayOfWeek;
  final CalendarConfiguration configuration;

  const WeekView(
      {@required this.year,
      @required this.month,
      this.firstDayOfWeek,
      this.configuration});

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  List<DateModel> items;

  Map<DateModel, Object> extraDataMap; //自定义额外的数据

  @override
  void initState() {
    super.initState();
    extraDataMap = widget.configuration.extraDataMap;

    items = DateUtil.initCalendarForWeekView(
        widget.year, widget.month, widget.firstDayOfWeek.getDateTime(), 0,
        minSelectDate: widget.configuration.minSelectDate,
        maxSelectDate: widget.configuration.maxSelectDate,
        extraDataMap: extraDataMap,
        offset: widget.configuration.offset);

    //第一帧后,添加监听，generation发生变化后，需要刷新整个日历
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<CalendarProvider>(context, listen: false)
          .generation
          .addListener(() async {
        if (mounted) {
          items = DateUtil.initCalendarForWeekView(
              widget.year, widget.month, widget.firstDayOfWeek.getDateTime(), 0,
              minSelectDate: widget.configuration.minSelectDate,
              maxSelectDate: widget.configuration.maxSelectDate,
              extraDataMap: extraDataMap,
              offset: widget.configuration.offset);
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CalendarProvider calendarProvider =
        Provider.of<CalendarProvider>(context, listen: false);

    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;
    print(
        "WeekView Consumer:calendarProvider.selectDateModel:${calendarProvider.selectDateModel}");
    return new GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: configuration.verticalSpacing,
            childAspectRatio: configuration.aspectRatio),
        itemCount: 7,
        itemBuilder: (context, index) {
          DateModel dateModel = items[index];
          //判断是否被选择
          if (configuration.selectMode == CalendarConstants.MODE_MULTI_SELECT) {
            if (calendarProvider.selectedDateList.contains(dateModel)) {
              dateModel.isSelected = true;
            } else {
              dateModel.isSelected = false;
            }
          } else {
            if (calendarProvider.selectDateModel == dateModel) {
              dateModel.isSelected = true;
            } else {
              dateModel.isSelected = false;
            }
          }

          return ItemContainer(
            dateModel: dateModel,
//            configuration: configuration,
//            calendarProvider: calendarProvider,
          );
        });
  }
}
