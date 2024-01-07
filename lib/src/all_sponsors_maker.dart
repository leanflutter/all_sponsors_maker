import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';
import 'package:liquid_engine/liquid_engine.dart' as liquid;
import 'package:yaml/yaml.dart';

import 'models/all_sponsors.dart';
import 'models/entity.dart';
import 'utils/pretty_json.dart';

const _kMdMark = '<!-- ALL_SPONSORS_MAKER -->';

class AllSponsorsMaker {
  late GitHub ghClient;

  final File _ghCacheFile = File('.cache_gh_user.json');
  Map<String, dynamic> _ghUserCacheMap = {};

  AllSponsorsMaker({
    String? githubToken,
  }) {
    ghClient = GitHub(auth: Authentication.withToken(githubToken));
  }

  Future<User?> _getGhUser(String githubId) async {
    if (_ghCacheFile.existsSync()) {
      String jsonString = await _ghCacheFile.readAsString();
      _ghUserCacheMap = json.decode(jsonString);
    }
    User? user;
    if (_ghUserCacheMap.containsKey(githubId)) {
      user = User.fromJson(_ghUserCacheMap[githubId]);
    } else {
      user = await ghClient.users.getUser(githubId);
      _ghUserCacheMap.putIfAbsent(githubId, () => user!.toJson());

      String jsonString = prettyJsonString(_ghUserCacheMap);
      _ghCacheFile.writeAsStringSync(jsonString);
    }
    return user;
  }

  Future<void> make() async {
    final File tmplFile = File('all_sponsors.tmpl');
    final tmplString = tmplFile.readAsStringSync();

    final File yamlFile = File('all_sponsors.yaml');
    final yamlString = yamlFile.readAsStringSync();

    AllSponsors allSponsors = AllSponsors.fromYaml(loadYaml(yamlString));
    for (var i = 0; i < allSponsors.entities.length; i++) {
      Entity entity = allSponsors.entities[i];
      if (entity.github_id != null) {
        User? user = await _getGhUser(entity.github_id!);
        if (allSponsors.entities[i].image_url == null) {
          allSponsors.entities[i].image_url = user!.avatarUrl!;
        }
      }
    }

    liquid.Context context = liquid.Context.create()
      ..variables = allSponsors.toJson();
    liquid.Template template =
        liquid.Template.parse(context, liquid.Source.fromString(tmplString));
    String renderedString = await template.render(context)
      ..replaceAll('\n\n', '\n');

    File mdFile = File('README.md');
    String mdString = mdFile.readAsStringSync();

    int markIndexS = mdString.indexOf(_kMdMark) + _kMdMark.length;
    int markIndexE = mdString.lastIndexOf(_kMdMark);

    String newContent = '';
    newContent += mdString.substring(0, markIndexS);
    newContent += '\n$renderedString\n';
    newContent += mdString.substring(markIndexE);

    mdFile.writeAsStringSync(newContent);
  }
}
