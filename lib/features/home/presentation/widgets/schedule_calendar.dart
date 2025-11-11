import 'package:flutter/material.dart';

/// Calendario de horarios
class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key});

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  String selectedMonth = 'October';
  int selectedYear = 2025;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday'];

  final List<String> timeSlots = [
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B7C99),
            ),
          ),

          const SizedBox(height: 16),

          // Selector de mes y año
          _buildMonthYearSelector(),

          const SizedBox(height: 16),

          // Tabla de horarios
          _buildScheduleTable(),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3E50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dropdown de mes
          DropdownButton<String>(
            value: selectedMonth,
            dropdownColor: const Color(0xFF2B3E50),
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            items: months.map((String month) {
              return DropdownMenuItem<String>(value: month, child: Text(month));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedMonth = newValue;
                });
              }
            },
          ),

          // Año con icono de calendario
          Row(
            children: [
              Text(
                selectedYear.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
        columnSpacing: 20,
        horizontalMargin: 0,
        columns: [
          const DataColumn(label: Text('', style: TextStyle(fontSize: 12))),
          ...weekDays.map(
            (day) => DataColumn(
              label: Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ),
          ),
        ],
        rows: timeSlots.map((time) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8D99AE),
                  ),
                ),
              ),
              ...List.generate(
                weekDays.length,
                (index) => DataCell(
                  Container(
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
