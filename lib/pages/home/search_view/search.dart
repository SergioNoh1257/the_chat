import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/enums/data_state.dart';
import 'package:the_chat/keys.dart';
import 'package:the_chat/router/app_router.dart';
import 'package:the_chat/state_info/error_info.dart';
import 'package:the_chat/state_info/loading_info.dart';
import 'package:the_chat/state_info/no_info.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  final _client = Supabase.instance.client;

  final TextEditingController _searchController = TextEditingController();

  late final AppData appData = context.watch<AppData>();

  DataState _searchState = DataState.none;

  List<dynamic> _searchData = [];

  Timer? _searchCooldown;

  @override
  void deactivate() {
    GlobalSnackBar.hideCurrent();
    super.deactivate();
  }

  @override
  void dispose() {
    _searchCooldown?.cancel();
    super.dispose();
  }

  _search(String query) {
    _searchCooldown?.cancel();

    if (query.isNotEmpty) {
      _searchCooldown = Timer(const Duration(seconds: 1), () async {
        if (mounted) {
          setState(() => _searchState = DataState.idle);
        }
        try {
          await _client
              .from("users")
              .select()
              .textSearch(
                "name",
                query,
                type: TextSearchType.phrase,
              )
              .neq("id", context.read<AppData>().userId)
              .then((data) {
            //Update
            if (mounted) {
              setState(() {
                _searchData = data;
                _searchState = DataState.done;
              });
            }
          });
        } catch (e) {
          if (mounted) {
            setState(() {
              _searchData = [];
              _searchState = DataState.error;
            });
          }
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _searchData = [];
          _searchState = DataState.none;
        });
      }
    }
  }

  _buildSearchResults() {
    switch (_searchState) {
      case DataState.error:
        return const ErrorInfo();
      case DataState.idle:
        return const LoadingInfo();
      case DataState.none:
        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.nature_people,
                  color: appData.themeColor.shade500,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text("¡Empieza a buscar usuarios por su nombre!"),
              ],
            ),
          ),
        );
      default:
        if (_searchData.isEmpty) {
          return const NoInfo();
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          shrinkWrap: true,
          itemCount: _searchData.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appData.themeColor.shade50,
                ),
                foregroundDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  _searchData[index]["profile_photo"] ?? "",
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    return AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      foregroundDecoration: BoxDecoration(
                        color: frame == null ? Colors.pink : Colors.transparent,
                      ),
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.person,
                        color: appData.determineColor(
                          background: appData.themeColor.shade50,
                          condition: "custom",
                        ),
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              title: Text(_searchData[index]["name"]),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _accessToChatWithId(_searchData[index]["id"]),
                    child: const Text("Ir al chat"),
                  ),
                  PopupMenuItem(
                    onTap: () => context.goNamed(
                      Routes.profile,
                      pathParameters: {
                        "id": _searchData[index]["id"],
                      },
                    ),
                    child: const Text("Ir al perfil"),
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  _accessToChatWithId(String requestedId) {
    context.goNamed(
      Routes.chat,
      extra: requestedId,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            cursorColor: appData.themeColor,
            controller: _searchController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
            ],
            decoration: InputDecoration(
              hintText: "Busca algo interesante...",
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: appData.themeColor,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (_) => _search(_searchController.value.text.trim()),
          ),
        ),
        _buildSearchResults(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
