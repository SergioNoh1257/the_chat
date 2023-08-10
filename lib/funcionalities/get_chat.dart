import 'package:provider/provider.dart';
import 'package:the_chat/app_data/app_data.dart';
import 'package:the_chat/keys.dart';

List<String> getChat(String otherId) {
  final id = (navKey.currentContext)?.read<AppData>().userId;

  if (id == null) {
    throw Exception();
  }

  final int difference = id.compareTo(otherId);

  if (difference >= 0) {
    return [id, otherId];
  }
  return [otherId, id];
}
