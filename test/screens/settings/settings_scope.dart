import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/app_version_info.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../../helpers/fake_stores.dart';

/// Re-provides [ProState], and the [AppVersionInfo] inside [AppServices],
/// for a Settings-area test that wants its own.
///
/// `pumpApp` (`test/helpers/test_app.dart`) already provides a free user's
/// [ProState] the way `main.dart` does; this scope builds a fresh one over
/// [proStore], or hands down [proState] as given. [ChangeNotifierProvider]'s
/// `create` form runs once however often an ancestor rebuilds, and disposes
/// the [ProState] with the tree when the test ends.
///
/// * [proState] and [versionInfo] replace the default fakes this scope builds,
///   for a test that wants to seed ownership, a price, a prompt already
///   dismissed, or a particular version string. Passing [proState] means the
///   caller has already called [ProState.load] on it; this scope does not
///   call it again.
/// * [proStore] seeds the [FakeKeyValueStore] a default [ProState] reads and
///   writes, for a test that wants to look behind it. Ignored when [proState]
///   is given directly.
class SettingsScope extends StatelessWidget {
  const SettingsScope({
    required this.child,
    this.proState,
    this.versionInfo,
    this.proStore,
    super.key,
  });

  final Widget child;
  final ProState? proState;
  final AppVersionInfo? versionInfo;
  final FakeKeyValueStore? proStore;

  @override
  Widget build(BuildContext context) {
    final ProState? seeded = proState;
    return MultiProvider(
      providers: [
        if (seeded != null)
          ChangeNotifierProvider<ProState>.value(value: seeded)
        else
          ChangeNotifierProvider<ProState>(
            create: (BuildContext context) {
              final AppServices services = context.read<AppServices>();
              final SuccessCounts successCounts = context.read<SuccessCounts>();
              final ProState pro = ProState(
                billing: services.billing,
                store: proStore ?? FakeKeyValueStore(),
                successCounts: successCounts,
              );
              unawaited(pro.load());
              return pro;
            },
          ),
        if (versionInfo case final AppVersionInfo info)
          Provider<AppServices>.value(
            value: context.read<AppServices>().copyWith(versionInfo: info),
          ),
      ],
      child: child,
    );
  }
}
