import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mind_print/features/journal/providers/journal_provider.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(journalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: Text(
          'Export Reports',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _startDate ??
                            DateTime.now().subtract(const Duration(days: 7)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.date_range, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _startDate == null
                                ? 'Start Date'
                                : DateFormat('MMM d, y').format(_startDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.date_range, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _endDate == null
                                ? 'End Date'
                                : DateFormat('MMM d, y').format(_endDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Export Options',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            journalsAsync.when(
              data: (journals) {
                final filtered = _filterJournals(journals);
                return Column(
                  children: [
                    Text(
                      'Found ${filtered.length} entries in range.',
                      style: GoogleFonts.inter(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Export as PDF'),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => _exportPdf(filtered),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(
                        Icons.table_chart,
                        color: Colors.green,
                      ),
                      title: const Text('Export as CSV'),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => _exportCsv(filtered),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading data: $e'),
            ),
          ],
        ),
      ),
    );
  }

  List<JournalEntry> _filterJournals(List<JournalEntry> all) {
    if (_startDate == null || _endDate == null) return all;
    return all.where((e) {
      final d = e.createdAt;
      final start = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      return d.isAfter(start) && d.isBefore(end);
    }).toList();
  }

  Future<void> _exportPdf(List<JournalEntry> entries) async {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No entries to export.')));
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MindPrint Journal Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              ...entries.map(
                (e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: const PdfColor(0.8, 0.8, 0.8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        DateFormat('MMM d, y - h:mm a').format(e.createdAt),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Mood Score: ${e.moodScore} | Type: ${e.entryType}',
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        e.content.isNotEmpty ? e.content : '(No text content)',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindprint_report.pdf');
    await file.writeAsBytes(await pdf.save());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully.')),
      );
    }
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: 'My MindPrint Report');
  }

  Future<void> _exportCsv(List<JournalEntry> entries) async {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No entries to export.')));
      return;
    }

    List<List<String>> csvData = [
      ['Date', 'Time', 'Type', 'Mood Score', 'Content'],
      ...entries.map(
        (e) => [
          DateFormat('yyyy-MM-dd').format(e.createdAt),
          DateFormat('HH:mm:ss').format(e.createdAt),
          e.entryType,
          e.moodScore.toString(),
          e.content,
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindprint_report.csv');
    await file.writeAsString(csv);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV generated successfully.')),
      );
    }
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: 'My MindPrint Report');
  }
}
