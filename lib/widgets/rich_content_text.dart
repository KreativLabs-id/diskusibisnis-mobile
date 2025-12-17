import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget untuk menampilkan konten dengan @mentions dan links yang clickable
class RichContentText extends StatefulWidget {
  final String content;
  final TextStyle? style;
  final void Function(String username)? onMentionTap;
  final int? maxLines;
  final TextOverflow? overflow;

  const RichContentText({
    super.key,
    required this.content,
    this.style,
    this.onMentionTap,
    this.maxLines,
    this.overflow,
  });

  @override
  State<RichContentText> createState() => _RichContentTextState();
}

class _RichContentTextState extends State<RichContentText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clear old recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final defaultStyle = widget.style ??
        const TextStyle(
          fontSize: 15,
          color: Color(0xFF334155),
          height: 1.6,
        );

    // Parse content and build rich text spans
    final spans = _parseContent(widget.content, defaultStyle, context);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: widget.maxLines,
      overflow: widget.overflow ?? TextOverflow.clip,
    );
  }

  List<TextSpan> _parseContent(
      String text, TextStyle defaultStyle, BuildContext context) {
    final List<TextSpan> spans = [];

    // Handle null or empty text
    if (text.isEmpty) {
      return spans;
    }

    // Combined regex for @mentions and URLs
    // Match @username or URLs (http/https)
    final pattern = RegExp(
      r'(@[a-zA-Z0-9_]+)|(https?://[^\s<>\[\]{}|\\^]+)',
      caseSensitive: false,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }

      final matchedText = match.group(0);
      if (matchedText == null) continue;

      if (matchedText.startsWith('@')) {
        // This is a mention
        final username = matchedText.substring(1); // Remove @
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            if (widget.onMentionTap != null) {
              widget.onMentionTap!(username);
            }
          };
        _recognizers.add(recognizer);

        spans.add(TextSpan(
          text: matchedText,
          style: defaultStyle.copyWith(
            color: const Color(0xFF059669),
            fontWeight: FontWeight.w600,
          ),
          recognizer: recognizer,
        ));
      } else {
        // This is a URL
        final recognizer = TapGestureRecognizer()
          ..onTap = () async {
            try {
              final uri = Uri.tryParse(matchedText);
              if (uri != null) {
                final canLaunch = await canLaunchUrl(uri);
                if (canLaunch) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          };
        _recognizers.add(recognizer);

        spans.add(TextSpan(
          text: matchedText,
          style: defaultStyle.copyWith(
            color: const Color(0xFF2563EB),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF2563EB),
          ),
          recognizer: recognizer,
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }
}
