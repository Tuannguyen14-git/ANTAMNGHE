import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpamReport {
  final int id;
  final String phoneNumber;
  final String? reason;
  final String? reporter;
  final DateTime reportedAt;

  SpamReport({
    required this.id,
    required this.phoneNumber,
    this.reason,
    this.reporter,
    required this.reportedAt,
  });

  factory SpamReport.fromJson(Map<String, dynamic> json) {
    return SpamReport(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      reason: json['reason'],
      reporter: json['reporter'],
      reportedAt: DateTime.parse(json['reportedAt']),
    );
  }
}

class ReportSpamScreen extends StatefulWidget {
  final String? initialPhone;
  const ReportSpamScreen({Key? key, this.initialPhone}) : super(key: key);

  @override
  State<ReportSpamScreen> createState() => _ReportSpamScreenState();
}

class _ReportSpamScreenState extends State<ReportSpamScreen> {
  final String apiUrl = 'https://localhost:7295/api/SpamReports';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool isLoading = false;
  List<SpamReport> reports = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
    }
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          reports = data.map((e) => SpamReport.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // ignore
    }
    setState(() => isLoading = false);
  }

  Future<void> _submitReport() async {
    final phone = _phoneController.text.trim();
    final reason = _reasonController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập số điện thoại')));
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': phone, 'reason': reason}),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        _phoneController.clear();
        _reasonController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Báo cáo thành công')));
        await _fetchReports();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Báo cáo thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo số spam')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Lý do (tùy chọn)',
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _submitReport,
                          icon: const Icon(Icons.send),
                          label: const Text('Gửi báo cáo'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reports.isEmpty
                  ? const Center(child: Text('Chưa có báo cáo nào.'))
                  : RefreshIndicator(
                      onRefresh: _fetchReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: reports.length,
                        itemBuilder: (ctx, i) {
                          final r = reports[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade50,
                                  child: const Icon(
                                    Icons.report_problem,
                                    color: Colors.purple,
                                  ),
                                ),
                                title: Text(
                                  r.phoneNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (r.reason != null &&
                                        r.reason!.isNotEmpty)
                                      Text(r.reason!),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Báo cáo: ${r.reportedAt.toLocal()}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
