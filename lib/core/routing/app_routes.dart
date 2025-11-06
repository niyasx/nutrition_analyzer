import 'package:go_router/go_router.dart';
import 'package:nutrition_app/features/nutrition/presentation/pages/home_page.dart';
import 'package:nutrition_app/features/nutrition/presentation/pages/results_page.dart';
import 'package:nutrition_app/features/nutrition/presentation/pages/history_page.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) => HistoryDetailPage(
          analysisId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}