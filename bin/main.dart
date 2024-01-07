import 'dart:io';

import 'package:all_sponsors_maker/all_sponsors_maker.dart';

Future<void> main(List<String> args) async {
  final allSponsorsMaker = AllSponsorsMaker(
    githubToken: Platform.environment['GITHUB_TOKEN'],
  );
  await allSponsorsMaker.make();
}
