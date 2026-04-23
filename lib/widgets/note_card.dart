import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSubjectTag(),
                  const Spacer(),
                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      note.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: note.isSaved 
                          ? const Color(0xFF136DEC) 
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lexend',
                  color: Color(0xFF1A1A1A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildUploaderInfo(),
                  const Spacer(),
                  _buildStats(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectTag() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF136DEC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            note.subject,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lexend',
              color: Color(0xFF136DEC),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileTypeIcon(),
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                note.fileType.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Lexend',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFileTypeIcon() {
    switch (note.fileType) {
      case NoteFileType.pdf:
        return Icons.picture_as_pdf;
      case NoteFileType.image:
        return Icons.image;
      case NoteFileType.document:
        return Icons.description;
    }
  }

  Widget _buildUploaderInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF136DEC).withOpacity(0.2),
          backgroundImage: note.uploaderAvatar.isNotEmpty
              ? NetworkImage(note.uploaderAvatar)
              : null,
          child: note.uploaderAvatar.isEmpty
              ? Text(
                  note.uploaderName.isNotEmpty ? note.uploaderName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF136DEC),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          note.uploaderName,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Lexend',
            color: Colors.grey[600],
          ),
        ),
        if (note.uploaderBranch.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              note.uploaderBranch,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lexend',
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.amber[600]),
        const SizedBox(width: 4),
        Text(
          note.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lexend',
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.download_outlined, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '${note.downloadCount}',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Lexend',
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
