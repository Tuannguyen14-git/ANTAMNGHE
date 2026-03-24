// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:antamnghe_app/screens/privacy_center_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'privacy center explains on-device processing',
    (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyCenterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trung tâm Quyền riêng tư'), findsOneWidget);
    expect(find.text('Những gì được xử lý trên thiết bị'), findsOneWidget);
    expect(
      find.text('Trạng thái Smart Focus, danh sách chặn, lịch sử cục bộ và whitelist tạm thời đều được lưu trên máy.'),
      findsOneWidget,
    );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'privacy center describes backend-synced VIP boundaries',
    (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyCenterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Những gì không nên bị tải lên máy chủ'), findsOneWidget);
    expect(
      find.text('Danh sách ưu tiên có thể được lưu ở backend nếu bạn chọn mô hình đồng bộ tài khoản, nhưng không cần chứa nội dung SMS hay lịch sử cuộc gọi.'),
      findsOneWidget,
    );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
