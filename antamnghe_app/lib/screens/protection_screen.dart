import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/call_screening_channel.dart';
import '../services/focus_mode_service.dart';
import '../services/screening_sync_service.dart';
import '../services/spam_service.dart';
import '../theme/app_theme.dart';

class ProtectionScreen extends StatefulWidget {
  const ProtectionScreen({super.key});

  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> {
  bool _loading = true;
  bool _autoBlockEnabled = false;
  List<Map<String, dynamic>> _items = [];
  final _checkController = TextEditingController();
  FocusModeSnapshot _focusSnapshot = const FocusModeSnapshot(
    isEnabled: false,
    until: null,
  );
  List<String> _emergencyKeywords = const [];
  ScreeningSetupStatus? _setupStatus;
  FocusWidgetStatus? _widgetStatus;
  bool _setupBusy = false;

  bool get _supportsNativeScreening => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoad();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginAndLoad() async {
    final user = await AuthService.instance.currentUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SpamService.instance.getAll();
      final focusSnapshot = await FocusModeService.currentState();
      final emergencyKeywords = await FocusModeService.getEmergencyKeywords();
      final setupStatus = _supportsNativeScreening
          ? await CallScreeningChannel.getSetupStatus()
          : null;
      final widgetStatus = _supportsNativeScreening
          ? await CallScreeningChannel.getFocusWidgetStatus()
          : null;
      await ScreeningSyncService.setCommunitySpamNumbers(
        list
            .map((item) => (item['phoneNumber'] ?? '').toString())
            .where((phone) => phone.isNotEmpty)
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _items = list;
        _focusSnapshot = focusSnapshot;
        _emergencyKeywords = emergencyKeywords;
        _setupStatus = setupStatus;
        _widgetStatus = widgetStatus;
        _autoBlockEnabled = setupStatus?.isReady ?? false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _check() async {
    final phone = _checkController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập số điện thoại để kiểm tra')),
      );
      return;
    }
    try {
      final isSpam = await SpamService.instance.check(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpam ? 'Số này được báo spam' : 'Số này hiện chưa bị báo spam'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kiểm tra: ${e.toString()}')),
      );
    }
  }

  Future<void> _enableProtection() async {
    if (!_supportsNativeScreening) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng chặn cuộc gọi chỉ hỗ trợ trên Android.')),
      );
      return;
    }

    if (_setupStatus?.callScreeningSupported == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _setupStatus?.supportMessage.isNotEmpty == true
                ? _setupStatus!.supportMessage
                : 'Thiết bị này không hỗ trợ Call Screening đầy đủ.',
          ),
        ),
      );
      return;
    }

    await _runSetupAction(
      action: () async {
        final roleOk = await CallScreeningChannel.requestCallScreeningRole();
        if (roleOk) return true;
        final fallbackOk = await CallScreeningChannel.openDefaultAppsSettings();
        return fallbackOk;
      },
      successMessage: 'Đã mở bước bật Call Screening. Sau khi bật xong, kéo xuống để làm mới trạng thái.',
      failureMessage: 'Không thể mở cấu hình Call Screening trên thiết bị này.',
    );
  }

  Future<void> _toggleProtection(bool value) async {
    if (value) {
      await _enableProtection();
      return;
    }
    setState(() => _autoBlockEnabled = false);
  }

  Future<void> _runSetupAction({
    required Future<bool> Function() action,
    required String successMessage,
    required String failureMessage,
  }) async {
    setState(() => _setupBusy = true);
    final ok = await action();
    final setupStatus = await CallScreeningChannel.getSetupStatus();
    final widgetStatus = await CallScreeningChannel.getFocusWidgetStatus();
    if (!mounted) return;
    setState(() {
      _setupBusy = false;
      _setupStatus = setupStatus;
      _widgetStatus = widgetStatus;
      _autoBlockEnabled = setupStatus?.isReady ?? false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? successMessage : failureMessage)),
    );
  }

  Future<void> _requestSmsPermissions() async {
    await _runSetupAction(
      action: CallScreeningChannel.requestSmsPermissions,
      successMessage: 'Đã xử lý bước quyền SMS cho tin nhắn khẩn cấp.',
      failureMessage: 'Quyền SMS chưa được cấp.',
    );
  }

  Future<void> _requestNotificationPermission() async {
    await _runSetupAction(
      action: () async {
        final ok = await CallScreeningChannel.requestNotificationPermission();
        if (ok) return true;
        return CallScreeningChannel.openAppSettings();
      },
      successMessage: 'Đã xử lý bước quyền thông báo khẩn cấp.',
      failureMessage: 'Không thể bật thông báo khẩn cấp.',
    );
  }

  Future<void> _refreshSetupStatus() async {
    final setupStatus = await CallScreeningChannel.getSetupStatus();
    final widgetStatus = await CallScreeningChannel.getFocusWidgetStatus();
    if (!mounted) return;
    setState(() {
      _setupStatus = setupStatus;
      _widgetStatus = widgetStatus;
      _autoBlockEnabled = setupStatus?.isReady ?? false;
    });
  }

  Future<void> _requestPinWidget() async {
    if (_widgetStatus?.canRequestPin == true) {
      await _runSetupAction(
        action: CallScreeningChannel.requestPinFocusWidget,
        successMessage: 'Đã gửi yêu cầu ghim widget Smart Focus. Kiểm tra màn hình chính hoặc launcher của bạn.',
        failureMessage: 'Không thể gửi yêu cầu ghim widget từ launcher hiện tại.',
      );
      return;
    }

    setState(() => _setupBusy = true);
    final openedLauncherSettings = await CallScreeningChannel.openLauncherSettings();
    final setupStatus = await CallScreeningChannel.getSetupStatus();
    final widgetStatus = await CallScreeningChannel.getFocusWidgetStatus();
    if (!mounted) return;
    setState(() {
      _setupBusy = false;
      _setupStatus = setupStatus;
      _widgetStatus = widgetStatus;
      _autoBlockEnabled = setupStatus?.isReady ?? false;
    });

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ManualWidgetGuideSheet(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          openedLauncherSettings
              ? 'Đã mở cài đặt màn hình chính. Làm theo hướng dẫn để thêm widget Smart Focus.'
              : 'Launcher không mở được từ ứng dụng. Hãy làm theo hướng dẫn để thêm widget Smart Focus thủ công.',
        ),
      ),
    );
  }

  Future<void> _toggleFocusMode() async {
    if (_focusSnapshot.isEnabled) {
      await FocusModeService.disable();
      if (!mounted) return;
      setState(() {
        _focusSnapshot = const FocusModeSnapshot(isEnabled: false, until: null);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tắt Smart Focus Mode.')),
      );
      return;
    }

    final duration = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = <Duration>[
          const Duration(minutes: 30),
          const Duration(hours: 1),
          const Duration(hours: 2),
          const Duration(hours: 8),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bật Smart Focus Mode',
                  style: TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trong thời gian này, cuộc gọi lạ sẽ bị làm im lặng. Cuộc gọi lặp lại trong 5 phút hoặc số gửi SMS khẩn cấp sẽ được cho qua.',
                  style: TextStyle(
                    color: AppTheme.textBody,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_formatDuration(option)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (duration == null) return;
    final snapshot = await FocusModeService.enableFor(duration);
    if (!mounted) return;
    setState(() => _focusSnapshot = snapshot);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã bật Smart Focus Mode trong ${_formatDuration(duration)}.')),
    );
  }

  Future<void> _editEmergencyKeywords() async {
    final controller = TextEditingController(text: _emergencyKeywords.join(', '));
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ khóa SMS khẩn cấp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ví dụ: khan cap, cuu me, goi lai. Khi tin nhắn chứa từ khóa, số đó sẽ được cho qua tạm thời.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập các từ khóa, cách nhau bằng dấu phẩy',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final keywords = FocusModeService.normalizeKeywords(controller.text.split(','));
    await FocusModeService.saveEmergencyKeywords(keywords);
    if (!mounted) return;
    setState(() => _emergencyKeywords = keywords);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật từ khóa SMS khẩn cấp.')),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes phút';
    }
    final hours = minutes ~/ 60;
    return '$hours giờ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textTitle,
        title: const Text('Bảo vệ khỏi Spam'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _HeroProtectionCard(
              supportsNativeScreening: _supportsNativeScreening,
              onPressed: _enableProtection,
            ),
            const SizedBox(height: 20),
            if (_supportsNativeScreening) ...[
              _AndroidSetupCard(
                status: _setupStatus,
                busy: _setupBusy,
                onRefresh: _refreshSetupStatus,
                onEnableCallScreening: _enableProtection,
                onGrantSmsPermissions: _requestSmsPermissions,
                onGrantNotifications: _requestNotificationPermission,
              ),
              const SizedBox(height: 16),
              _FocusWidgetCard(
                status: _widgetStatus,
                busy: _setupBusy,
                onRefresh: _refreshSetupStatus,
                onRequestPin: _requestPinWidget,
              ),
              const SizedBox(height: 16),
            ],
            _ProtectionTile(
              icon: Icons.shield_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Tự động chặn spam',
              subtitle: _supportsNativeScreening
                  ? (_setupStatus?.callScreeningSupported == false)
                      ? 'Thiết bị đang ở chế độ giới hạn, chỉ dùng được kiểm tra spam và cấu hình cục bộ'
                      : (_setupStatus?.isReady ?? false)
                      ? 'Thiết bị đã sẵn sàng cho chặn cuộc gọi và SMS khẩn cấp'
                      : 'Cần hoàn tất 3 bước quyền Android ở phần thiết lập nhanh'
                  : 'Chỉ khả dụng trên Android',
              trailing: Switch.adaptive(
                value: _autoBlockEnabled,
                onChanged: _setupBusy || _setupStatus?.callScreeningSupported == false
                    ? null
                    : _toggleProtection,
                activeColor: const Color(0xFF2C7DFF),
              ),
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.timelapse_rounded,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Smart Focus Mode',
              subtitle: _supportsNativeScreening
                  ? FocusModeService.describe(_focusSnapshot)
                  : 'Chỉ hoạt động đầy đủ trên Android',
              onTap: _supportsNativeScreening ? _toggleFocusMode : null,
              trailing: TextButton(
                onPressed: _supportsNativeScreening ? _toggleFocusMode : null,
                child: Text(_focusSnapshot.isEnabled ? 'Tắt' : 'Bật'),
              ),
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.repeat_rounded,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Cho qua cuộc gọi lặp',
              subtitle: 'Nếu cùng một số lạ gọi lại trong 5 phút, cuộc gọi thứ hai sẽ được đổ chuông.',
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.sms_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Từ khóa SMS khẩn cấp',
              subtitle: _emergencyKeywords.isEmpty
                  ? 'Chưa có từ khóa. Thêm để người thân nhắn tin xin ưu tiên.'
                  : 'Đang theo dõi: ${_emergencyKeywords.join(', ')}',
              onTap: _supportsNativeScreening ? _editEmergencyKeywords : null,
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.block_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Danh sách chặn',
              subtitle: 'Xem và quản lý các số bạn đã chặn',
              onTap: () => Navigator.pushNamed(context, '/blocked'),
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.star_border,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Danh bạ ưu tiên',
              subtitle: 'Luôn cho phép các số quan trọng đi qua bộ lọc',
              onTap: () => Navigator.pushNamed(context, '/vip-list'),
            ),
            const SizedBox(height: 22),
            const Text(
              'Kiểm tra số điện thoại spam',
              style: TextStyle(
                color: AppTheme.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppTheme.textTitle),
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại',
                      hintStyle: const TextStyle(color: AppTheme.placeholder),
                      fillColor: AppTheme.searchBackground,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _check,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
                    child: const Text('Kiểm tra'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Báo cáo cộng đồng gần đây',
              style: TextStyle(
                color: AppTheme.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else if (_items.isEmpty)
              const _EmptyProtectionState()
            else
              ..._items.take(8).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CommunityReportTile(item: item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AndroidSetupCard extends StatelessWidget {
  final ScreeningSetupStatus? status;
  final bool busy;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onEnableCallScreening;
  final Future<void> Function() onGrantSmsPermissions;
  final Future<void> Function() onGrantNotifications;

  const _AndroidSetupCard({
    required this.status,
    required this.busy,
    required this.onRefresh,
    required this.onEnableCallScreening,
    required this.onGrantSmsPermissions,
    required this.onGrantNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = status;
    final setupComplete = currentStatus?.isReady ?? false;
    final limitedMode = currentStatus?.isLimitedMode ?? false;
    final supportMessage = currentStatus?.supportMessage ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Thiết lập Android',
                  style: TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: busy ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            limitedMode
                ? (supportMessage.isNotEmpty
                    ? supportMessage
                    : 'Thiết bị này không hỗ trợ Call Screening đầy đủ, app sẽ chạy ở chế độ giới hạn.')
                : setupComplete
                ? 'Thiết bị đã đủ điều kiện để Smart Focus, SMS khẩn cấp và widget hoạt động ổn định.'
                : 'Hoàn tất từng bước dưới đây để policy chặn cuộc gọi chạy đúng trên Android.',
            style: const TextStyle(
              color: AppTheme.textBody,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _SetupStepTile(
            step: '1',
            title: 'Bật vai trò Call Screening',
            subtitle: limitedMode
                ? 'Tính năng này không khả dụng trên thiết bị hiện tại.'
                : 'Cho phép Android dùng An Tâm Nghe làm bộ lọc cuộc gọi.',
            isDone: currentStatus?.callScreeningEnabled ?? false,
            busy: busy || limitedMode,
            actionLabel: limitedMode ? 'Không hỗ trợ' : 'Bật ngay',
            onPressed: onEnableCallScreening,
          ),
          const SizedBox(height: 12),
          _SetupStepTile(
            step: '2',
            title: 'Cấp quyền SMS',
            subtitle: 'Cần cho tính năng nhận tin nhắn khẩn cấp và whitelist tạm thời.',
            isDone: currentStatus?.smsPermissionsGranted ?? false,
            busy: busy,
            actionLabel: 'Cấp quyền',
            onPressed: onGrantSmsPermissions,
          ),
          const SizedBox(height: 12),
          _SetupStepTile(
            step: '3',
            title: 'Cho phép thông báo',
            subtitle: 'Dùng để báo khi có SMS khẩn cấp mở quyền ưu tiên cho người gọi.',
            isDone: currentStatus?.notificationsGranted ?? false,
            busy: busy,
            actionLabel: 'Bật thông báo',
            onPressed: onGrantNotifications,
          ),
        ],
      ),
    );
  }
}

class _SetupStepTile extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool busy;
  final String actionLabel;
  final Future<void> Function() onPressed;

  const _SetupStepTile({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.busy,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : Text(
                      step,
                      style: const TextStyle(
                        color: AppTheme.textTitle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textBody,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: isDone || busy ? null : onPressed,
            style: FilledButton.styleFrom(
              foregroundColor: AppTheme.primary,
              backgroundColor: const Color(0xFFFFECE8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(isDone ? 'Xong' : actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FocusWidgetCard extends StatelessWidget {
  final FocusWidgetStatus? status;
  final bool busy;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRequestPin;

  const _FocusWidgetCard({
    required this.status,
    required this.busy,
    required this.onRefresh,
    required this.onRequestPin,
  });

  @override
  Widget build(BuildContext context) {
    final widgetStatus = status;
    final isPinned = widgetStatus?.isPinned ?? false;
    final canRequestPin = widgetStatus?.canRequestPin ?? false;
    final message = widgetStatus?.message ??
        'Thêm widget An Tâm Nghe để bật Smart Focus chỉ với một chạm từ màn hình chính.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.widgets_outlined, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Widget Smart Focus',
                  style: TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: busy ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.textBody,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isPinned ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPinned ? Icons.check_circle_rounded : Icons.add_box_outlined,
                  color: isPinned ? const Color(0xFF16A34A) : AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPinned
                        ? 'Widget đã có trên màn hình chính'
                        : canRequestPin
                        ? 'Launcher hỗ trợ ghim nhanh từ ứng dụng'
                        : 'Cần ghim thủ công từ màn hình chính',
                    style: const TextStyle(
                      color: AppTheme.textTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: busy || isPinned ? null : onRequestPin,
                  style: FilledButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    backgroundColor: const Color(0xFFFFECE8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(isPinned ? 'Đã ghim' : (canRequestPin ? 'Ghim nhanh' : 'Xem cách thêm')),
                ),
              ],
            ),
          ),
          if (!isPinned && !canRequestPin) ...[
            const SizedBox(height: 12),
            const Text(
              'Cách thêm nhanh: nhấn giữ màn hình chính, chọn Widgets, tìm An Tâm Nghe rồi kéo Smart Focus ra ngoài.',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ManualWidgetGuideSheet extends StatelessWidget {
  const _ManualWidgetGuideSheet();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Ra màn hình chính và nhấn giữ vào khoảng trống.',
      'Chọn mục Widgets hoặc Tiện ích.',
      'Tìm An Tâm Nghe trong danh sách widget.',
      'Kéo widget Smart Focus ra màn hình chính để bật hoặc tắt nhanh.',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm widget thủ công',
              style: TextStyle(
                color: AppTheme.textTitle,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Một số launcher không cho ứng dụng tự ghim widget. Bạn vẫn có thể thêm Smart Focus theo các bước dưới đây.',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            ...steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppTheme.textBody,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Đã hiểu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroProtectionCard extends StatelessWidget {
  final bool supportsNativeScreening;
  final VoidCallback onPressed;

  const _HeroProtectionCard({
    required this.supportsNativeScreening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const _PhoneShieldArt(),
          const SizedBox(height: 18),
          const Text(
            'ID Người gọi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            supportsNativeScreening
                ? 'Bật bộ lọc cuộc gọi để nhận cảnh báo và chặn spam theo thời gian thực.'
                : 'Giao diện này đã sẵn sàng, nhưng tính năng chặn cuộc gọi hiện chỉ hoạt động trên Android.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFCECEE),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textTitle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(supportsNativeScreening ? 'Nhận cuộc gọi ngay' : 'Xem trên Android'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneShieldArt extends StatelessWidget {
  const _PhoneShieldArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _FloatingChip(offset: Offset(-118, -50), color: Color(0xFFFFD35A), angle: -0.8),
          const _FloatingChip(offset: Offset(-98, 10), color: Color(0xFFFFA37C), angle: -0.55),
          const _FloatingChip(offset: Offset(108, -44), color: Color(0xFFFFE6D9), angle: -0.48),
          const _FloatingChip(offset: Offset(116, 22), color: Color(0xFFFFC742), angle: 0.6),
          const _FloatingChip(offset: Offset(-44, 78), color: Color(0xFFFFD9A8), angle: -0.45),
          const _FloatingChip(offset: Offset(72, 88), color: Color(0xFFFFC0AF), angle: 0.22),
          Positioned(
            bottom: 14,
            child: Container(
              width: 132,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            width: 126,
            height: 168,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8F70), Color(0xFFE63946)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0x1A1D1D1F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 18,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFFFD8B8),
                    child: Icon(Icons.person, size: 14, color: Colors.brown.shade700),
                  ),
                ),
                Positioned(
                  top: 44,
                  left: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 44,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8B2A3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 26,
                  bottom: 28,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD166),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 26,
                  bottom: 28,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 74,
            top: 82,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ED6A1), Color(0xFF16B987)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 52),
            ),
          ),
          const Positioned(
            top: 6,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFFFD166),
            ),
          ),
          const Positioned(
            right: 34,
            bottom: 76,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFFFF1EB),
            ),
          ),
          const Positioned(
            right: 18,
            top: 78,
            child: CircleAvatar(
              radius: 7,
              backgroundColor: Color(0xFFFFE6D9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  final Offset offset;
  final Color color;
  final double angle;

  const _FloatingChip({
    required this.offset,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 18,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _ProtectionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProtectionTile({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textTitle,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                const Icon(Icons.chevron_right, color: AppTheme.arrowColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityReportTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CommunityReportTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final phone = item['phone']?.toString() ?? '';
    final label = 'Báo cáo: ${item['reportCount'] ?? 0}';
    final accent = _badgeColor(phone);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            '/spam_detail',
            arguments: {'id': item['id'], 'phone': phone},
          );
          if (context.mounted && result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật chi tiết số điện thoại.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: accent,
                  child: Text(
                    phone.length >= 2 ? phone.substring(phone.length - 2) : phone,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone,
                      style: const TextStyle(
                        color: AppTheme.textTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right, color: Color(0xFF8B93A7)),
                  const Icon(Icons.chevron_right, color: AppTheme.arrowColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _badgeColor(String phone) {
    final code = phone.isNotEmpty ? phone.codeUnitAt(phone.length - 1) : 0;
    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFFFFA94D),
      Color(0xFFFFC94D),
      Color(0xFF4DABF7),
      Color(0xFF51CF66),
    ];
    return colors[code % colors.length];
  }
}

class _EmptyProtectionState extends StatelessWidget {
  const _EmptyProtectionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.forum_outlined, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chưa có báo cáo mới từ cộng đồng. Hãy kiểm tra số hoặc bật chặn cuộc gọi để bắt đầu.',
              style: TextStyle(color: AppTheme.textBody, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
