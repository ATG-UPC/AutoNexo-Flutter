import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../offers/presentation/cubit/cubit.dart';
import '../../../../core/services/notifications_service.dart';
import '../../../../core/navigation/app_router.dart';

/// Widget que muestra el icono de campana con badge de notificaciones
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersCubit()..loadMyOffers(),
      child: _NotificationBellContent(),
    );
  }
}

class _NotificationBellContent extends StatefulWidget {
  @override
  State<_NotificationBellContent> createState() =>
      _NotificationBellContentState();
}

class _NotificationBellContentState extends State<_NotificationBellContent> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Cargar contador inicial después de un pequeño delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<OffersCubit>().loadMyOffers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OffersCubit, OffersState>(
      listener: (context, state) {
        if (state.status == OffersStatus.loaded) {
          _updateUnreadCount(state);
        }
      },
      child: BlocBuilder<OffersCubit, OffersState>(
        builder: (context, state) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRouter.notifications);
                  // Recargar ofertas al volver para actualizar el contador
                  if (mounted) {
                    context.read<OffersCubit>().loadMyOffers();
                  }
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUnreadCount(OffersState state) async {
    final offerIds = state.offers
        .where((o) => o.isPending && !o.isExpired)
        .map((o) => o.id)
        .toList();
    
    final count = await NotificationsService.getUnreadOffersCount(offerIds);
    
    if (mounted && count != _unreadCount) {
      setState(() {
        _unreadCount = count;
      });
    }
  }
}
