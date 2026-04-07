import 'package:flutter_test/flutter_test.dart';
import 'package:kz_servicos_app/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:kz_servicos_app/main.dart';

void main() {
  testWidgets('KzServicosApp renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KzServicosApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
