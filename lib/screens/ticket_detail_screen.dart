import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketNumber;
  const TicketDetailScreen({super.key, required this.ticketNumber});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Ticket? _ticket;
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    await _authService.init();
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'Anda harus login';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final ticket = await _apiService.getTicketByNumber(
          widget.ticketNumber, user.email ?? '');
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat detail tiket: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;
    if (_ticket == null) return;

    final user = _authService.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isSending = true);

    try {
      await _apiService.replyTicket(
        ticketNumber: _ticket!.ticketNumber,
        email: user.email!,
        message: _replyController.text,
        name: user.displayName,
      );

      _replyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balasan terkirim')),
        );
      }
      _loadTicket(); // Refresh to see new reply
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim balasan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.amber[700]!;
      case 'replied':
        return Colors.blue[700]!;
      case 'in_progress':
        return Colors.purple[700]!;
      case 'resolved':
        return Colors.green[700]!;
      case 'closed':
        return Colors.grey[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Tiket #${widget.ticketNumber}',
          style: const TextStyle(
              color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)))
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _ticket == null
                  ? const Center(child: Text('Tiket tidak ditemukan'))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ticket Header
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _ticket!.subject,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      _ticket!.status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: _getStatusColor(
                                                          _ticket!.status)
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              _ticket!.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(
                                                    _ticket!.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            radius: 16,
                                            child: Text(
                                              _ticket!.name != null &&
                                                      _ticket!.name!.isNotEmpty
                                                  ? _ticket!.name![0]
                                                      .toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _ticket!.name ?? 'User',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  _formatDate(
                                                      _ticket!.createdAt),
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _ticket!.message ?? '',
                                        style: const TextStyle(
                                            color: Color(0xFF334155),
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Riwayat Percakapan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Replies List
                                if (_ticket!.replies != null &&
                                    _ticket!.replies!.isNotEmpty)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _ticket!.replies!.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final reply = _ticket!.replies![index];
                                      final isAdmin = reply.isAdmin;
                                      return Row(
                                        mainAxisAlignment: isAdmin
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isAdmin) ...[
                                            CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              radius: 16,
                                              child: const Icon(
                                                  LucideIcons.user,
                                                  size: 16,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isAdmin
                                                    ? const Color(0xFFECFDF5)
                                                    : Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      const Radius.circular(16),
                                                  topRight:
                                                      const Radius.circular(16),
                                                  bottomLeft: isAdmin
                                                      ? const Radius.circular(
                                                          16)
                                                      : Radius.zero,
                                                  bottomRight: isAdmin
                                                      ? Radius.zero
                                                      : const Radius.circular(
                                                          16),
                                                ),
                                                border: Border.all(
                                                  color: isAdmin
                                                      ? const Color(0xFFD1FAE5)
                                                      : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        reply.senderName,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isAdmin
                                                              ? const Color(
                                                                  0xFF059669)
                                                              : const Color(
                                                                  0xFF0F172A),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _formatDate(
                                                            reply.createdAt),
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Color(0xFF94A3B8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    reply.message,
                                                    style: const TextStyle(
                                                      color: Color(0xFF334155),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isAdmin) ...[
                                            const SizedBox(width: 8),
                                            CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFFD1FAE5),
                                              radius: 16,
                                              child: const Icon(
                                                  LucideIcons.shieldCheck,
                                                  size: 16,
                                                  color: Color(0xFF059669)),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    alignment: Alignment.center,
                                    child: const Text('Belum ada balasan',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Reply Input
                        if (_ticket!.status.toLowerCase() != 'closed')
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  top: BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replyController,
                                    decoration: InputDecoration(
                                      hintText: 'Tulis balasan...',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _isSending ? null : _sendReply,
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: _isSending
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Icon(LucideIcons.send),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[100],
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.lock,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Tiket ditutup',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
    );
  }
}
