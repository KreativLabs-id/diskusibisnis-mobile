import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    await _authService.init();
    final user = _authService.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
        });
        _loadTickets(user.email ?? ''); // Handle potential null email
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTickets(String email) async {
    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Email tidak ditemukan';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final tickets = await _apiService.getMyTickets(email);
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat tiket: $e';
          _isLoading = false;
        });
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

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.amber[50]!;
      case 'replied':
        return Colors.blue[50]!;
      case 'in_progress':
        return Colors.purple[50]!;
      case 'resolved':
        return Colors.green[50]!;
      case 'closed':
        return Colors.grey[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Menunggu';
      case 'replied':
        return 'Dibalas';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      case 'closed':
        return 'Ditutup';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tiket Saya'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.lock, size: 64, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              const Text(
                'Silakan login untuk melihat tiket',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tiket Saya',
          style:
              TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF0F172A)),
            onPressed: () => _checkAuthAndLoad(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)))
          : _error.isNotEmpty
              ? Center(
                  child:
                      Text(_error, style: const TextStyle(color: Colors.red)),
                )
              : _tickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.inbox,
                              size: 64, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada tiket',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Anda belum membuat tiket bantuan apapun.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CreateTicketScreen()),
                              ).then((_) => _checkAuthAndLoad());
                            },
                            icon: const Icon(LucideIcons.plus),
                            label: const Text('Buat Tiket Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return _buildTicketCard(ticket);
                      },
                    ),
      floatingActionButton: _tickets.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
                ).then((_) => _checkAuthAndLoad());
              },
              backgroundColor: const Color(0xFF059669),
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TicketDetailScreen(ticketNumber: ticket.ticketNumber),
          ),
        ).then((_) => _checkAuthAndLoad()); // Refresh on return
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        '#${ticket.ticketNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(ticket.status),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getStatusColor(ticket.status)
                                .withOpacity(0.3)),
                      ),
                      child: Text(
                        _getStatusLabel(ticket.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(ticket.status),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(LucideIcons.chevronRight,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(width: 12),
                Icon(LucideIcons.tag, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  ticket.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
