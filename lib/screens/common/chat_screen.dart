import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as location_pkg;
import 'package:url_launcher/url_launcher.dart';
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
  int _wardId = 0;
  bool _isCoordinator = false;
  
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isPolling = false;
  int _lastMsgId = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadUserAndChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.id ?? 0;
    _currentUserName = authProvider.user?.fullName ?? '';
    _currentUserRole = authProvider.user?.roleLevel ?? '';
    _wardId = authProvider.user?.wardId ?? 0;
    
    _isCoordinator = ['ward', 'lga', 'state', 'national', 'super_admin'].contains(_currentUserRole);
    
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      if (_isCoordinator) {
        final response = await _chatService.getContacts(9);
        setState(() {
          _contacts = response.contacts;
          _isLoading = false;
          if (_contacts.isNotEmpty && _selectedContact == null) {
            _selectedContact = _contacts.first;
            _loadMessages(_selectedContact!.id);
            _startPolling();
          }
          if (_contacts.isEmpty) {
            _selectedContact = null;
            _messages = [];
            _pollTimer?.cancel();
          }
        });
      } else {
        final coordinator = await _chatService.getCoordinator();
        setState(() {
          _isLoading = false;
          if (coordinator != null) {
            _contacts = [coordinator];
            _selectedContact = coordinator;
            _loadMessages(coordinator.id);
            _startPolling();
          } else {
            _contacts = [];
            _selectedContact = null;
            _messages = [];
            _pollTimer?.cancel();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading contacts: $e', isError: true);
    }
  }

  Future<void> _loadMessages(int contactId) async {
    setState(() => _isLoadingMessages = true);
    try {
      final messages = await _chatService.getMessages(contactId);
      setState(() {
        _messages = messages;
        _isLoadingMessages = false;
        if (messages.isNotEmpty) {
          _lastMsgId = messages.last.id;
        }
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoadingMessages = false);
      _showSnackBar('Error loading messages', isError: true);
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

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isPolling && _selectedContact != null) {
        _checkForNewMessages();
      }
    });
  }

  Future<void> _checkForNewMessages() async {
    if (_selectedContact == null || _selectedContact!.id == 0) return;
    
    _isPolling = true;
    try {
      final messages = await _chatService.getMessagesSince(
        _selectedContact!.id,
        _lastMsgId,
      );
      
      if (messages.isNotEmpty) {
        setState(() {
          _messages.addAll(messages);
          _lastMsgId = messages.last.id;
        });
        _scrollToBottom();
        await _chatService.markAsRead(_selectedContact!.id);
      }
    } catch (e) {
      print('Polling error: $e');
    } finally {
      _isPolling = false;
    }
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
          _lastMsgId = message.id;
        });
        _scrollToBottom();
      } else {
        setState(() => _isSending = false);
        _showSnackBar('Failed to send message', isError: true);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showSnackBar('Error sending message', isError: true);
    }
  }

  Future<void> _shareLocation() async {
    setState(() => _isSending = true);
    
    try {
      final location = location_pkg.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showSnackBar('Please enable location services', isError: true);
          setState(() => _isSending = false);
          return;
        }
      }

      location_pkg.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == location_pkg.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_pkg.PermissionStatus.granted) {
          _showSnackBar('Location permission denied', isError: true);
          setState(() => _isSending = false);
          return;
        }
      }

      location_pkg.LocationData currentLocation = await location.getLocation();
      
      double lat = currentLocation.latitude ?? 0;
      double lng = currentLocation.longitude ?? 0;
      
      String locationName = await _getLocationName(lat, lng);
      String message = '📍 $locationName: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      
      final msg = await _chatService.sendMessage(
        _selectedContact!.id,
        message,
        'location',
        gpsLat: lat,
        gpsLng: lng,
      );
      
      if (msg != null) {
        setState(() {
          _messages.add(msg);
          _isSending = false;
          _lastMsgId = msg.id;
        });
        _scrollToBottom();
        _showSnackBar('Location shared successfully');
      } else {
        setState(() => _isSending = false);
        _showSnackBar('Failed to share location', isError: true);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showSnackBar('Error sharing location', isError: true);
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName = place.name ?? place.street ?? place.locality ?? 
                             place.subAdministrativeArea ?? place.administrativeArea ?? 
                             place.country ?? 'Location';
        return locationName;
      }
      return 'Location';
    } catch (e) {
      return 'Location';
    }
  }

  Future<void> _openMap(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      _showSnackBar('Could not open map', isError: true);
    }
  }

  void _selectContact(Contact contact) {
    setState(() {
      _selectedContact = contact;
      _messages = [];
      _lastMsgId = 0;
    });
    _loadMessages(contact.id);
    _chatService.markAsRead(contact.id);
    _startPolling();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
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
          child: Container(height: 1, color: AppColors.gray200),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChatContent(),
    );
  }

  Widget _buildChatContent() {
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              _isCoordinator ? 'No Contacts Available' : 'No Coordinator Assigned',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.gray500),
            ),
            const SizedBox(height: 8),
            Text(
              _isCoordinator 
                  ? 'No agents available in your ward' 
                  : 'Please contact your administrator',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: _selectedContact == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray300),
                      const SizedBox(height: 16),
                      Text(
                        'Select a Contact',
                        style: GoogleFonts.inter(fontSize: 16, color: AppColors.gray500),
                      ),
                    ],
                  ),
                )
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
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gray200,
            child: Text(
              _selectedContact!.initials,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedContact!.fullName,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  _selectedContact!.isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _selectedContact!.isOnline ? Colors.green : AppColors.gray400,
                  ),
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
          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(
            'No Messages Yet',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray500),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a conversation with ${_selectedContact!.fullName}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

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
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.messageType == 'location')
                    _buildLocationMessage(message, isSent)
                  else
                    Text(
                      message.content.isNotEmpty ? message.content : 'Empty message',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isSent ? Colors.white : Colors.black87,
                      ),
                      softWrap: true,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: isSent ? Colors.white70 : Colors.grey,
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

  Widget _buildLocationMessage(ChatMessage message, bool isSent) {
    double? lat = message.gpsLat;
    double? lng = message.gpsLng;
    
    return InkWell(
      onTap: () => _openMap(lat, lng),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSent ? Colors.transparent : AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSent ? Colors.white24 : AppColors.primaryLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isSent ? Colors.white : AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '📍 Location Shared',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSent ? Colors.white : AppColors.gray800,
                  ),
                ),
              ],
            ),
            if (lat != null && lng != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 24),
                child: Text(
                  'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isSent ? Colors.white60 : AppColors.gray400,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 24),
              child: Text(
                'Tap to view on map',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isSent ? Colors.white60 : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: Icon(Icons.attach_file, color: AppColors.gray400),
            onSelected: (value) {
              if (value == 'location') {
                _shareLocation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Share Location'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
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