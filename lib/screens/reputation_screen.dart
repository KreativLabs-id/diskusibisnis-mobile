import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/reputation_activity.dart';
import '../models/user_profile.dart'; // To show current user stats
import '../services/api_service.dart';

class ReputationScreen extends StatefulWidget {
  final String userId;

  const ReputationScreen({super.key, required this.userId});

  @override
  State<ReputationScreen> createState() => _ReputationScreenState();
}

class _ReputationScreenState extends State<ReputationScreen> {
  final ApiService _apiService = ApiService();
  List<ReputationActivity> _activities = [];
  bool _isLoading = true;
  int _userRank = 0;
  // Mock current user for display
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _apiService.getProfile(widget.userId);
      final activities =
          await _apiService.getReputationActivities(widget.userId);
      final rank = await _apiService.getUserRank(widget.userId);

      setState(() {
        _currentUser = user;
        _activities = activities;
        _userRank = rank;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Reputasi',
            style: TextStyle(
                color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentUser != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.trophy,
                      size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentUser!.reputationPoints}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        Icon(LucideIcons.trophy,
                            size: 32, color: Color(0xFF059669)),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reputasi Anda',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            Text('Statistik pencapaian dan kontribusi',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              LucideIcons.trophy,
                              'Total Poin',
                              '${_currentUser?.reputationPoints ?? 0}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              LucideIcons.trendingUp, 'Minggu Ini', '+15',
                              textColor: const Color(0xFF059669))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRankCard(),

                  const SizedBox(height: 32),

                  // History & Sidebar
                  const Text('Riwayat Aktivitas',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),

                  if (_activities.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.activity,
                                size: 32, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                              child: Text('Belum ada aktivitas',
                                  style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        final isLast = index == _activities.length - 1;
                        return _buildTimelineItem(activity, isLast);
                      },
                    ),

                  const SizedBox(height: 32),

                  // System Poin Info
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.zap,
                                  color: Color(0xFFFBBF24), size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text('Sistem Poin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildPointInfo('Jawaban Terbaik', '+15'),
                        _buildPointInfo('Dapat Upvote', '+10'),
                        _buildPointInfo('Buat Pertanyaan', '+5'),
                        _buildPointInfo('Dapat Downvote', '-2',
                            isNegative: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value,
      {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: const Color(0xFF059669))),
              const SizedBox(width: 8),
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.award, size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Text('Peringkat Global',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('#$_userRank',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  const SizedBox(width: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('Top 1%',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669)))),
                ],
              ),
            ],
          ),
          // Decoration
          const Icon(LucideIcons.barChart2, size: 48, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ReputationActivity activity, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF059669), width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(activity.type)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getIcon(activity.type),
                                  size: 12,
                                  color: _getTypeColor(activity.type)),
                              const SizedBox(width: 6),
                              Text(
                                _getTypeLabel(activity.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getTypeColor(activity.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(activity.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        height: 1.4,
                      ),
                    ),
                    if (activity.questionTitle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.messageCircle,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activity.questionTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Poin Diperoleh',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                const Color(0xFF64748B).withValues(alpha: 0.8),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${activity.points}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'question_upvote':
      case 'answer_upvote':
        return const Color(0xFF059669);
      case 'answer_accepted':
        return const Color(0xFF0284C7);
      case 'question_posted':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'question_upvote':
        return 'UPVOTE';
      case 'answer_upvote':
        return 'UPVOTE';
      case 'answer_accepted':
        return 'JAWABAN VALID';
      case 'question_posted':
        return 'PERTANYAAN';
      default:
        return 'AKTIVITAS';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'question_upvote':
        return LucideIcons.thumbsUp;
      case 'answer_upvote':
        return LucideIcons.thumbsUp;
      case 'answer_accepted':
        return LucideIcons.checkCircle;
      case 'question_posted':
        return LucideIcons.messageSquare;
      default:
        return LucideIcons.star;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPointInfo(String label, String points,
      {bool isNegative = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF065F46),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 13)),
          Text(points,
              style: TextStyle(
                  color: isNegative
                      ? const Color(0xFFF87171)
                      : const Color(0xFF34D399),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
