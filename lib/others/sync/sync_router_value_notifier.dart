import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';
import '../../models/user.dart';

// Yet another possible approach.
//
// In here we build a `Listenable` object through `ValueNotifier`, which is
// just a simple `ChangeNotifier`, which calls `notifyListeners` when the value
// changes, and that allows us to implement our custom logic.
//
// This implementation is a shorthand version of the first example, while still
// maintaining some easy-to-introduce customizations.
//
// However, it has a less readable implementation and I'd discourage this.
// Here, ValueNotifier exposes a **useless** (not actually being used) value.
// Furthermore, we are forced to write onto the listenable to trigger rebuilds,
// which just _feels_ like a workaround, which doesn't makes much sense.
//
// Simply put - this is not clean code - this works because of side effects..
final valueNotifierRouterProvider = Provider<GoRouter>((ref) {
  final listenable = ValueNotifier<bool>(true);

  final subscription = ref.listen<User?>(authProvider, (oldUser, next) {
    // This is just to trigger `notifyListeners` within the `ValueNotifier`
    listenable.value = !listenable.value;
  });
  ref.onDispose(subscription.close);

  return GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // We want to READ the state, here.
      // GoRouter is already aware of state changes through `refreshListenable`
      // We don't want to trigger a rebuild of this provider.
      final user = ref.read(authProvider);

      // From here we can use the state and implement our custom logic
      final areWeLoggingIn = state.location == LoginPage.routeLocation;

      if (user == null) {
        // We're not logged in
        // So, IF we aren't in the login page, go there.
        return areWeLoggingIn ? null : LoginPage.routeLocation;
      }
      // We're logged in

      // At this point, IF we're in the login page, go to the home page
      if (areWeLoggingIn) return HomePage.routeLocation;

      // There's no need for a redirect at this point.
      return null;
    },
    // This is crucial to make the router work with Riverpod.
    refreshListenable: listenable,
    routes: [
      GoRoute(
        name: HomePage.routeName,
        path: HomePage.routeLocation,
        builder: (context, _) => const HomePage(),
      ),
      GoRoute(
        name: LoginPage.routeName,
        path: LoginPage.routeLocation,
        builder: (context, _) => const LoginPage(),
      ),
    ],
  );
});