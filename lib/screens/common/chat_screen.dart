import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Contact> _contacts = [];
  List<ChatMessage> _messages = [];
  Contact? _selectedContact;
  int _currentUserId = 0;
  String _currentUserName = '';
  String _currentUserRole = '';
  
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isCoordinator = false;
  
  final Map<int, Map<String, dynamic>> _roleDefinitions = {
    9: {'name': 'PU Agent', 'icon': Icons.assignment_ind, 'color': '#3B82F6'},
    10: {'name': 'Party Agent', 'icon': Icons.how_to_vote, 'color': '#8B5CF6'},
    11: {'name': 'Observer', 'icon': Icons.visibility, 'color': '#10B981'},
    15: {'name': 'Volunteer', 'icon': Icons.volunteer_activism, 'color': '#F59E0B'},
  };
  
  int _selectedRoleId = 9;

  @override
  void initState() {
    super.initState();
    _loadUserAndChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.id ?? 0;
    _currentUserName = authProvider.user?.fullName ?? '';
    _currentUserRole = authProvider.user?.roleLevel ?? '';
    
    // Check if user is a coordinator (ward, lga, state, etc.)
    _isCoordinator = ['ward', 'lga', 'state', 'national', 'super_admin'].contains(_currentUserRole);
    
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      if (_isCoordinator) {
        // Coordinator sees all contacts by role
        final response = await _chatService.getContacts(_selectedRoleId);
        setState(() {
          _contacts = response.contacts;
          _isLoading = false;
          if (_contacts.isNotEmpty && _selectedContact == null) {
            _selectedContact = _contacts.first;
            _loadMessages(_selectedContact!.id);
          }
          if (_contacts.isEmpty) {
            _selectedContact = null;
            _messages = [];
          }
        });
      } else {
        // Agent sees only their coordinator
        final coordinator = await _chatService.getCoordinator();
        setState(() {
          _isLoading = false;
          if (coordinator != null) {
            _contacts = [coordinator];
            _selectedContact = coordinator;
            _loadMessages(coordinator.id);
          } else {
            _contacts = [];
            _selectedContact = null;
            _messages = [];
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading contacts: $e');
    }
  }

  Future<void> _loadMessages(int contactId) async {
    setState(() => _isLoadingMessages = true);
    try {
      final messages = await _chatService.getMessages(contactId);
      setState(() {
        _messages = messages;
        _isLoadingMessages = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoadingMessages = false);
      print('Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedContact == null) return;
    
    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);
    
    try {
      final message = await _chatService.sendMessage(
        _selectedContact!.id,
        content,
        'text',
      );
      
      if (message != null) {
        setState(() {
          _messages.add(message);
          _isSending = false;
        });
        _scrollToBottom();
      } else {
        setState(() => _isSending = false);
        _showSnackBar('Failed to send message', isError: true);
      }
    } catch (e) {
      setState(() => _isSending = false);
      print('Error sending message: $e');
      _showSnackBar('Error sending message', isError: true);
    }
  }

  void _selectContact(Contact contact) {
    setState(() {
      _selectedContact = contact;
      _messages = [];
    });
    _loadMessages(contact.id);
    _chatService.markAsRead(contact.id);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isCoordinator ? 'Chat with Agents' : 'Chat with Coordinator',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.gray200,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChatContent(),
    );
  }

  Widget _buildChatContent() {
    if (_contacts.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        // Role tabs only for coordinator
        if (_isCoordinator && _contacts.length > 1)
          _buildRoleTabs(),
        
        Expanded(
          child: Row(
            children: [
              // Contact sidebar - only show for coordinator with multiple contacts
              if (_isCoordinator && _contacts.length > 1 && MediaQuery.of(context).size.width > 768)
                SizedBox(
                  width: 320,
                  child: _buildContactSidebar(),
                ),
              Expanded(
                child: _selectedContact == null
                    ? _buildNoContactSelected()
                    : Column(
                        children: [
                          _buildChatHeader(),
                          Expanded(
                            child: _isLoadingMessages
                                ? const Center(child: CircularProgressIndicator())
                                : _messages.isEmpty
                                    ? _buildEmptyMessages()
                                    : ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(16),
                                        reverse: true,
                                        itemCount: _messages.length,
                                        itemBuilder: (context, index) {
                                          final message = _messages[_messages.length - 1 - index];
                                          return _buildMessageBubble(message);
                                        },
                                      ),
                          ),
                          _buildMessageInput(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _roleDefinitions.length,
        itemBuilder: (context, index) {
          final entry = _roleDefinitions.entries.elementAt(index);
          final roleId = entry.key;
          final role = entry.value;
          final isSelected = _selectedRoleId == roleId;
          final count = _contacts.where((c) => c.roleId == roleId).length;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRoleId = roleId;
                _selectedContact = null;
                _messages = [];
              });
              _loadContacts();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Color(int.parse(role['color'].replaceAll('#', '0xFF')))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? Color(int.parse(role['color'].replaceAll('#', '0xFF')))
                      : AppColors.gray200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.gray600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    role['name'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.gray700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.gray200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isSelected ? Colors.white : AppColors.gray500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isCoordinator) {
      final roleName = _roleDefinitions[_selectedRoleId]?['name'] ?? 'agents';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Contacts Available',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No $roleName available in your ward',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.gray400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Coordinator Assigned',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact your administrator',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.gray400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNoContactSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Contact',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a contact from the sidebar to start chatting',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.gray400,
                ),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final isSelected = _selectedContact?.id == contact.id;
                final roleColor = Color(int.parse(
                  _roleDefinitions[contact.roleId]?['color']?.replaceAll('#', '0xFF') ?? '0xFF6B7280'
                ));
                
                return GestureDetector(
                  onTap: () => _selectContact(contact),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryLight.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.gray200,
                              child: contact.photographUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: contact.photographUrl!,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const SizedBox(),
                                        errorWidget: (context, url, error) => Text(
                                          contact.initials,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      contact.initials,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gray600,
                                      ),
                                    ),
                            ),
                            if (contact.isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    contact.fullName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: roleColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _roleDefinitions[contact.roleId]?['name'] ?? 'Agent',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: roleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                contact.lastMessageDisplay,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: contact.unreadCount > 0 
                                      ? AppColors.gray800 
                                      : AppColors.gray400,
                                  fontWeight: contact.unreadCount > 0 
                                      ? FontWeight.w500 
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (contact.lastMessageTime != null)
                              Text(
                                _formatTime(contact.lastMessageTime!),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.gray400,
                                ),
                              ),
                            if (contact.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${contact.unreadCount}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gray200,
            child: _selectedContact!.photographUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _selectedContact!.photographUrl!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(),
                      errorWidget: (context, url, error) => Text(
                        _selectedContact!.initials,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                  )
                : Text(
                    _selectedContact!.initials,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray600,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedContact!.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                Row(
                  children: [
                    if (_selectedContact!.isOnline)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (_selectedContact!.isOnline)
                      const SizedBox(width: 4),
                    Text(
                      _selectedContact!.isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _selectedContact!.isOnline 
                            ? Colors.green 
                            : AppColors.gray400,
                      ),
                    ),
                    if (!_isCoordinator && _selectedContact!.roleName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Coordinator',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadMessages(_selectedContact!.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 12),
          Text(
            'No Messages Yet',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isCoordinator 
                ? 'Start a conversation with ${_selectedContact!.fullName}'
                : 'Your coordinator will send you messages here',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIXED MESSAGE BUBBLE - NO DUPLICATE CODE
  // ============================================================
  Widget _buildMessageBubble(ChatMessage message) {
    final isSent = message.senderId == _currentUserId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.gray200,
              child: Text(
                _selectedContact?.initials ?? 'U',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSent ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(12),
                  bottomLeft: isSent ? const Radius.circular(12) : const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isSent && message.senderFirstName != null)
                    Text(
                      message.senderName,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  
                  // Message content
                  if (message.messageType == 'location')
                    InkWell(
                      onTap: () {
                        // Open map
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isSent ? Colors.white : AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '📍 Location shared',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isSent ? Colors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
                    InkWell(
                      onTap: () {
                        // Open media
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.gray200,
                        ),
                        child: message.messageType == 'image'
                            ? CachedNetworkImage(
                                imageUrl: message.mediaUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: AppColors.gray400,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.insert_drive_file,
                                  size: 40,
                                  color: AppColors.gray400,
                                ),
                              ),
                      ),
                    )
                  else
                    // FIXED: Text message with proper visibility
                    Text(
                      message.content.isNotEmpty ? message.content : 'Empty message',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSent ? Colors.white : Colors.black87,
                        fontFamily: GoogleFonts.inter().fontFamily ?? 'Roboto',
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 9,
                          color: isSent ? Colors.white70 : Colors.grey,
                          fontFamily: GoogleFonts.inter().fontFamily ?? 'Roboto',
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          (message.isRead == true) ? Icons.done_all : Icons.done,
                          size: 12,
                          color: (message.isRead == true) ? Colors.green : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showMediaOptions,
            icon: const Icon(Icons.attach_file, color: AppColors.gray400),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.gray400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _messageController.text.isNotEmpty && !_isSending
                    ? AppColors.primary
                    : AppColors.gray200,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: _messageController.text.isNotEmpty
                          ? Colors.white
                          : AppColors.gray400,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.info),
                title: const Text('Choose Photo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.gray700),
                title: const Text('Share Location'),
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text = '📍 Location shared';
                  _sendMessage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (date == today) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (date == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else if (now.difference(date).inDays < 7) {
        return DateFormat('EEE').format(dateTime);
      } else {
        return DateFormat('MMM d').format(dateTime);
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}