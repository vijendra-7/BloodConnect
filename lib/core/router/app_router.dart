import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/donor_details_screen.dart';
import '../../features/auth/presentation/screens/donor_contact_screen.dart';
import '../../features/auth/presentation/screens/medical_eligibility_screen.dart';
import 'package:blood_connect/features/home/presentation/screens/main_layout.dart';
import 'package:blood_connect/features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/seeker_details_screen.dart';
import '../../features/auth/presentation/screens/org_details_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:blood_connect/features/requests/presentation/screens/donation_thankyou_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/donor-details',
      builder: (context, state) => const DonorDetailsScreen(),
    ),
    GoRoute(
      path: '/seeker-details',
      builder: (context, state) => const SeekerDetailsScreen(),
    ),
    GoRoute(
      path: '/org-details',
      builder: (context, state) => const OrgDetailsScreen(),
    ),
    GoRoute(
      path: '/donor-contact',
      builder: (context, state) => const DonorContactScreen(),
    ),
    GoRoute(
      path: '/medical-eligibility',
      builder: (context, state) => const MedicalEligibilityScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/donation-thankyou',
      builder: (context, state) {
        final request = state.extra as Map<String, dynamic>;
        return DonationThankYouScreen(request: request);
      },
    ),
  ],
);
