import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../data/models/models.dart';

/// Calendario de horarios que muestra las ofertas aceptadas y bookings agendados
class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key});

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
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
          // Título y selector de mes/año
          _buildHeader(),
          const SizedBox(height: 12),

          // Calendario
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, homeState) {
              return _buildCalendar(homeState.scheduleSlots);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final monthName = _formatMonthYear(_selectedDate);

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            'Calendario',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B7C99),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: 3,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                    _loadScheduleForMonth();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 16,
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2D42),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                    _loadScheduleForMonth();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(List<ScheduleSlotModel> scheduleSlots) {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;

    // Obtener el día de la semana del primer día (0 = domingo, 6 = sábado)
    // Ajustar para que lunes sea 0
    int firstDayWeekday = firstDayOfMonth.weekday - 1;

    // Calcular cuántas semanas necesitamos
    final totalCells = firstDayWeekday + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();

    return Column(
      children: [
        // Encabezados de días de la semana
        Row(
          children: _weekDays.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D99AE),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Divider(height: 1),

        // Días del calendario
        ...List.generate(weeksNeeded, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - firstDayWeekday + 1;

              // Celda vacía antes del primer día del mes
              if (cellIndex < firstDayWeekday || dayNumber > daysInMonth) {
                return Expanded(
                  child: Container(height: 50, margin: const EdgeInsets.all(1)),
                );
              }

              final currentDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                dayNumber,
              );
              final slotsForDay = _getSlotsForDay(currentDate, scheduleSlots);
              final hasScheduledItems = slotsForDay.isNotEmpty;

              return Expanded(
                child: _buildDayCell(
                  dayNumber,
                  currentDate,
                  hasScheduledItems,
                  slotsForDay,
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildDayCell(
    int dayNumber,
    DateTime date,
    bool hasScheduledItems,
    List<ScheduleSlotModel> slots,
  ) {
    final isToday = _isSameDay(date, DateTime.now());
    final isPast = date.isBefore(DateTime.now()) && !isToday;

    return InkWell(
      onTap: hasScheduledItems
          ? () => _showDayDetails(context, date, slots)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isToday
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : hasScheduledItems
              ? Colors.green.shade50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isPast
                      ? Colors.grey.shade400
                      : isToday
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
              ),
            ),
            if (hasScheduledItems)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<ScheduleSlotModel> _getSlotsForDay(
    DateTime date,
    List<ScheduleSlotModel> scheduleSlots,
  ) {
    return scheduleSlots
        .where(
          (slot) =>
              slot.scheduledDate != null &&
              _isSameDay(slot.scheduledDate!, date) &&
              slot.isActive,
        )
        .toList()
      ..sort((a, b) {
        if (a.scheduledDate == null || b.scheduledDate == null) return 0;
        return a.scheduledDate!.compareTo(b.scheduledDate!);
      });
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    List<ScheduleSlotModel> slots,
  ) {
    final dateStr = _formatDate(date);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dateStr, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: slots.isEmpty
                ? const Text('No hay servicios agendados para este día.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hora
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    slot.formattedTime,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B2D42),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Servicios
                              if (slot.servicesToPerform.isNotEmpty) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.build,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: slot.servicesToPerform.map((
                                          service,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Text(
                                              service,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF2B2D42),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Descripción si existe
                              if (slot.description != null &&
                                  slot.description!.isNotEmpty) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        slot.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final weekDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    final weekDay = weekDays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekDay, ${date.day} de $month de ${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _loadScheduleForMonth() {
    context.read<HomeCubit>().refreshSchedule(
      month: _selectedDate.month.toString(),
      year: _selectedDate.year.toString(),
    );
  }
}
