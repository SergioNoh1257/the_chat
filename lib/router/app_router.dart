import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:the_chat/pages/account/account.dart';
import 'package:the_chat/pages/chat/chat.dart';
import 'package:the_chat/pages/not_found.dart';
import 'package:the_chat/pages/home/home.dart';
import 'package:the_chat/main.dart';
import 'package:the_chat/pages/log_in/log_in.dart';
import 'package:the_chat/pages/pre_sign_out/pre_sign_out.dart';
import 'package:the_chat/pages/profile/profile.dart';
import 'package:the_chat/pages/home/search_view/search.dart';
import 'package:the_chat/pages/settings.dart';
import 'package:the_chat/pages/sign_up.dart';
import 'package:the_chat/pages/status/new.dart';
import 'package:the_chat/pages/status/status.dart';
import 'package:the_chat/keys.dart';

class Routes {
  Routes._();
  static const login = "log-in";

  static const signup = "sign-up";
  static const preSignOut = "pre-signout";

  static const home = "home";

  static const chat = "chat";
  static const group = "group";

  static const chatProfile = "chat_profile";
  static const profile = "profile";

  static const status = "status";

  static const settings = "settings";

  static const account = "account";

  static const search = "search";

  static const newStatus = "new-status";
}

mixin RouterMixin on State<Main> {
  final _router = GoRouter(
    navigatorKey: navKey,
    initialLocation: "/log-in",
    errorBuilder: (_, __) => const NotFound(),
    routes: [
      // Home
      GoRoute(
        name: Routes.home,
        path: "/",
        builder: (_, __) => const Home(),
        redirect: (_, state) {
          final user = Supabase.instance.client.auth.currentUser;

          if (user == null) {
            return "/log-in";
          }

          return null;
        },
        routes: [
          //Account
          GoRoute(
            name: Routes.account,
            path: "account",
            builder: (_, __) => const Account(),
            redirect: (_, __) {
              final user = Supabase.instance.client.auth.currentUser;

              if (user == null) {
                return "/log-in";
              }

              return null;
            },
          ),

          //Chat
          GoRoute(
            name: Routes.chat,
            path: "chat",
            builder: (_, state) => Chat(
              id: state.extra as String,
            ),
            redirect: (_, state) {
              final user = Supabase.instance.client.auth.currentUser;
              final id = state.extra;

              if (user == null) return "/log-in";

              if (id == null) return "/";

              if (id is! String) return "/";

              if (id.isEmpty) return "/";

              if (!id.contains(RegExp(
                r'[a-z0-9]{8}-[a-z0-9]{4}-4[a-z0-9]{3}-[a-z0-9]{4}-[a-z0-9]{12}',
                caseSensitive: false,
              ))) return "/";

              return null;
            },
          ),

          //New Status
          GoRoute(
            name: Routes.newStatus,
            path: "new-status",
            builder: (_, __) => const NewStatus(),
            redirect: (_, state) {
              final user = Supabase.instance.client.auth.currentUser;

              if (user == null) return "/log-in";

              return null;
            },
          ),

          //Profile (Redundant)
          GoRoute(
            name: Routes.profile,
            path: "profile/:id",
            builder: (_, state) {
              return Profile(id: state.pathParameters["id"]!);
            },
            redirect: (_, state) {
              final user = Supabase.instance.client.auth.currentUser;
              final id = state.pathParameters["id"];

              if (user == null) {
                return "/log-in";
              }

              if (id == user.id) {
                return "/account";
              }

              if (id == null) {
                return "/";
              }

              return null;
            },
          ),

          //Search
          GoRoute(
            name: Routes.search,
            path: "search",
            builder: (_, __) => const Search(),
          ),

          //Settings
          GoRoute(
            name: Routes.settings,
            path: "settings",
            builder: (_, __) => const Settings(),
          ),

          //Status
          GoRoute(
            name: Routes.status,
            path: "status",
            builder: (_, state) {
              return Status(
                data: state.extra as Map<dynamic, dynamic>,
              );
            },
            redirect: (_, state) {
              final user = Supabase.instance.client.auth.currentUser;
              final data = state.extra;

              if (user == null) return "/log-in";

              if (data == null) return "/";

              if (data is! Map<dynamic, dynamic>) return "/";

              if (data.isEmpty) return "/";

              if (!data["sender_id"].contains(RegExp(
                r'[a-z0-9]{8}-[a-z0-9]{4}-4[a-z0-9]{3}-[a-z0-9]{4}-[a-z0-9]{12}',
                caseSensitive: false,
              ))) {
                return "/";
              }

              return null;
            },
          ),
        ],
      ),

      //SignUp
      GoRoute(
        name: Routes.signup,
        path: "/sign-up",
        builder: (_, __) => const SignUp(),
        redirect: (_, __) {
          final user = Supabase.instance.client.auth.currentUser;

          if (user != null) {
            return "/";
          }

          return null;
        },
      ),

      //Pre-SignOut
      GoRoute(
          name: Routes.preSignOut,
          path: "/sign-out",
          builder: (_, state) => PreSignOut(status: state.extra as int),
          redirect: (_, state) {
            final user = Supabase.instance.client.auth.currentUser;
            final dynamic status = state.extra;

            if (user == null) return "/";

            if (status == null) return "/";

            if (status is! int) return "/";

            if (status != 1) return "/";

            return null;
          }),

      //LogIn
      GoRoute(
        name: Routes.login,
        path: "/log-in",
        builder: (_, __) => const LogIn(),
        redirect: (_, __) {
          final user = Supabase.instance.client.auth.currentUser;

          if (user != null) {
            return "/";
          }

          return null;
        },
      ),
    ],
  );

  GoRouter get router => _router;
}
