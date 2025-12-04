import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página que muestra las reviews de un taller
class WorkshopReviewsPage extends StatefulWidget {
  final int workshopId;
  final String? workshopName;
  final double? averageRating;
  final int? totalReviews;

  const WorkshopReviewsPage({
    super.key,
    required this.workshopId,
    this.workshopName,
    this.averageRating,
    this.totalReviews,
  });

  @override
  State<WorkshopReviewsPage> createState() => _WorkshopReviewsPageState();
}

class _WorkshopReviewsPageState extends State<WorkshopReviewsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ReviewsCubit>().loadWorkshopReviews(widget.workshopId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ReviewsCubit>().loadMoreReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas'),
        elevation: 0,
      ),
      body: BlocConsumer<ReviewsCubit, ReviewsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ReviewsCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<ReviewsCubit>().loadWorkshopReviews(widget.workshopId),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header con resumen
                SliverToBoxAdapter(
                  child: _buildHeader(context, state),
                ),

                // Lista de reviews o estados
                if (state.isLoading && state.reviews.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.reviews.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < state.reviews.length) {
                            return _ReviewCard(review: state.reviews[index]);
                          }
                          // Loading indicator al final
                          if (state.hasMorePages) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return null;
                        },
                        childCount: state.reviews.length + (state.hasMorePages ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReviewsState state) {
    final theme = Theme.of(context);
    final avgRating = widget.averageRating ?? state.averageRating;
    final totalReviews = widget.totalReviews ?? state.totalReviews;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
      ),
      child: Column(
        children: [
          // Nombre del taller
          Text(
            widget.workshopName ?? 'Taller #${widget.workshopId}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Rating promedio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < avgRating.floor()
                            ? Icons.star
                            : (index < avgRating ? Icons.star_half : Icons.star_border),
                        color: Colors.amber.shade600,
                        size: 20,
                      );
                    }),
                  ),
                  Text(
                    '$totalReviews reseña${totalReviews == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin reseñas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este taller aún no tiene reseñas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card para mostrar una review individual
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con rating y fecha
            Row(
              children: [
                // Estrellas
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade600,
                      size: 18,
                    );
                  }),
                ),
                const Spacer(),
                // Fecha
                Text(
                  review.formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            // Comentario
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium,
              ),
            ],

            // Usuario
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Usuario #${review.reviewerId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



