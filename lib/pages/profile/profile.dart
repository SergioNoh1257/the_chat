import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/enums/data_state.dart';
import 'package:the_chat/pages/profile/profile_data.dart';
import 'package:the_chat/pages/profile/profile_images.dart';
import 'package:the_chat/scaffold/app_bar.dart';
import 'package:the_chat/state_info/error_info.dart';
import 'package:the_chat/state_info/loading_info.dart';
import 'package:the_chat/state_info/no_info.dart';

class Profile extends StatefulWidget {
  final String id;

  const Profile({
    super.key,
    required this.id,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //Client
  final SupabaseClient _client = Supabase.instance.client;

  late final AppData appData = context.watch<AppData>();

  Map<String, dynamic> _profileData = {};

  DataState _profileState = DataState.idle;

  @override
  void initState() {
    _init();

    super.initState();
  }

  _init() async {
    try {
      await _client
          .from("users")
          .select()
          .eq("id", widget.id)
          .limit(1)
          .single()
          .then((data) {
        if (context.mounted) {
          setState(() {
            _profileState = DataState.done;
            _profileData = data;
          });
        }
      });
    } catch (_) {
      if (context.mounted) {
        setState(() {
          _profileState = DataState.error;
          _profileData = {};
        });
      }
    }
  }

  Widget _buildUserProfile() {
    switch (_profileState) {
      case DataState.error:
        return const ErrorInfo();
      case DataState.idle:
        return const LoadingInfo();
      default:
        if (_profileData.isEmpty) {
          return const NoInfo();
        }
        return ListView(
          children: [
            ProfileImages(
              profilePhoto: _profileData["profile_photo"],
              coverPhoto: _profileData["cover_photo"],
            ),
            ProfileData(
              id: widget.id,
              name: _profileData["name"],
              email: _profileData["email"],
              info: _profileData["info"],
            ),
          ],
        );
    }
  }

  String _buildTitle() {
    switch (_profileState) {
      case DataState.error:
        return "Perfil - Oh no...";
      case DataState.idle:
        return "Perfil - Cargando...";
      default:
        if (_profileData.isEmpty) {
          return "¿Perfil?";
        }
        return "Perfil - ${_profileData["name"]}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _buildTitle(),
        backgroundColor: appData.themeColor,
      ),
      body: _buildUserProfile(),
    );
  }
}
