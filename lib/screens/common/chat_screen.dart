import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as location_pkg;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
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
  String _wardName = '';
  int _wardId = 0;
  
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isCoordinator = false;
  bool _isPolling = false;
  int _lastMsgId = 0;
  
  final Map<int, Map<String, dynamic>> _roleDefinitions = {
    9: {'name': 'PU Agent', 'icon': Icons.assignment_ind, 'color': '#3B82F6', 'level': 'pu_agent'},
    10: {'name': 'Party Agent', 'icon': Icons.how_to_vote, 'color': '#8B5CF6', 'level': 'party_agent'},
    11: {'name': 'Observer', 'icon': Icons.visibility, 'color': '#10B981', 'level': 'observer'},
    15: {'name': 'Volunteer', 'icon': Icons.volunteer_activism, 'color': '#F59E0B', 'level': 'volunteer'},
  };
  
  int _selectedRoleId = 9;
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
    
    if (authProvider.user != null) {
      _wardId = authProvider.user!.wardId ?? 0;
    }
    
    _isCoordinator = ['ward', 'lga', 'state', 'national', 'super_admin'].contains(_currentUserRole);
    
    if (_isCoordinator && _wardId > 0) {
      _wardName = await _getWardName(_wardId);
    }
    
    await _loadContacts();
  }

  Future<String> _getWardName(int wardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final tenantId = prefs.getInt('tenant_id') ?? 0;
      
      final response = await http.get(
        Uri.parse('${ChatService.baseUrl}/wards/get.php?id=$wardId&tenant_id=$tenantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['ward'] != null) {
          return data['ward']['name'] ?? 'Unknown Ward';
        }
      }
      return 'Unknown Ward';
    } catch (e) {
      print('Error fetching ward name: $e');
      return 'Unknown Ward';
    }
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      if (_isCoordinator) {
        final response = await _chatService.getContacts(_selectedRoleId);
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
        print('🟡 Loading coordinator for agent...');
        final coordinator = await _chatService.getCoordinator();
        print('🟡 Coordinator result: $coordinator');
        
        setState(() {
          _isLoading = false;
          if (coordinator != null) {
            print('🟡 Coordinator found: ${coordinator.fullName} (ID: ${coordinator.id})');
            _contacts = [coordinator];
            _selectedContact = coordinator;
            _loadMessages(coordinator.id);
            _startPolling();
          } else {
            print('🔴 No coordinator found');
            _contacts = [];
            _selectedContact = null;
            _messages = [];
            _pollTimer?.cancel();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('🔴 Error loading contacts: $e');
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
      print('Error loading messages: $e');
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
      print('Error sending message: $e');
      _showSnackBar('Error sending message', isError: true);
    }
  }

  // ============================================================
  // LOCATION SHARING
  // ============================================================
  
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
      print('Error sharing location: $e');
      _showSnackBar('Error sharing location', isError: true);
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        String locationName = '';
        if (place.name != null && place.name!.isNotEmpty) {
          locationName = place.name!;
        } else if (place.street != null && place.street!.isNotEmpty) {
          locationName = place.street!;
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!;
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          locationName = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationName = place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          locationName = place.country!;
        } else {
          locationName = 'Location';
        }
        
        if (place.locality != null && place.locality!.isNotEmpty && !locationName.contains(place.locality!)) {
          locationName += ', ${place.locality}';
        }
        
        return locationName;
      }
      
      return 'Location';
    } catch (e) {
      print('Reverse geocoding error: $e');
      return 'Location';
    }
  }

  Future<void> _openMap(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showSnackBar('Could not open map', isError: true);
      }
    } catch (e) {
      print('Error opening map: $e');
      _showSnackBar('Error opening map', isError: true);
    }
  }

  // ============================================================
  // FILE UPLOAD
  // ============================================================
  
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip', 'rar', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'gif'],
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() => _isSending = true);
      
      try {
        final message = await _chatService.sendFile(
          _selectedContact!.id,
          file.path!,
          file.name,
          file.size,
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
          _showSnackBar('Failed to upload file', isError: true);
        }
      } catch (e) {
        setState(() => _isSending = false);
        print('Error uploading file: $e');
        _showSnackBar('Error uploading file', isError: true);
      }
    }
  }

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() => _isSending = true);
      
      try {
        final message = await _chatService.sendImage(
          _selectedContact!.id,
          image.path,
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
          _showSnackBar('Failed to upload image', isError: true);
        }
      } catch (e) {
        setState(() => _isSending = false);
        print('Error uploading image: $e');
        _showSnackBar('Error uploading image', isError: true);
      }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD METHODS
  // ============================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isCoordinator ? 'Chat with Agents' : 'Chat with Coordinator',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isCoordinator && _wardName.isNotEmpty)
              Text(
                '$_wardName Ward',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray500,
                ),
              ),
          ],
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
        if (_isCoordinator && _contacts.length > 1)
          _buildRoleTabs(),
        
        Expanded(
          child: Row(
            children: [
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
          final color = Color(int.parse(role['color'].replaceAll('#', '0xFF')));
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRoleId = roleId;
                _selectedContact = null;
                _messages = [];
                _lastMsgId = 0;
              });
              _loadContacts();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : AppColors.gray200,
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
                          ? Colors.white.withValues(alpha: 0.3)
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
              onChanged: (value) => _filterContacts(value),
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
                          ? AppColors.primaryLight.withValues(alpha: 0.1)
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
                              child: contact.photographUrl != null && contact.photographUrl!.isNotEmpty
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
                                  Expanded(
                                    child: Text(
                                      contact.fullName,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gray800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: roleColor.withValues(alpha: 0.1),
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
                            if (contact.isOnline)
                              Text(
                                'Online',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
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

  void _filterContacts(String query) {
    _loadContacts();
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
            child: _selectedContact!.photographUrl != null && _selectedContact!.photographUrl!.isNotEmpty
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
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
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
  // MESSAGE BUBBLE
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
                    color: Colors.black.withValues(alpha: 0.04),
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
                  
                  if (message.messageType == 'location')
                    _buildLocationMessage(message, isSent)
                  else if (message.messageType == 'file' || (message.mediaUrl != null && message.mediaUrl!.isNotEmpty))
                    _buildFileMessage(message, isSent)
                  else
                    Text(
                      message.content.isNotEmpty ? message.content : 'Empty message',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isSent ? Colors.white : Colors.black87,
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
    String locationName = '';
    double? lat;
    double? lng;
    
    if (message.content.contains('📍')) {
      final parts = message.content.replaceAll('📍 ', '').split(':');
      if (parts.length >= 2) {
        locationName = parts[0].trim();
        final coords = parts[1].trim().split(',');
        if (coords.length >= 2) {
          lat = double.tryParse(coords[0].trim());
          lng = double.tryParse(coords[1].trim());
        }
      }
    }
    
    if (message.gpsLat != null && message.gpsLng != null) {
      lat = message.gpsLat;
      lng = message.gpsLng;
    }
    
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
            if (locationName.isNotEmpty && locationName != 'Location')
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 24),
                child: Text(
                  locationName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSent ? Colors.white70 : AppColors.gray600,
                  ),
                ),
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

  Widget _buildFileMessage(ChatMessage message, bool isSent) {
    String fileName = 'File';
    String fileSize = '';
    String fileType = '';
    String fileUrl = '';
    
    if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) {
      fileUrl = message.mediaUrl!;
      fileName = message.mediaUrl!.split('/').last;
      
      final ext = fileName.split('.').last.toLowerCase();
      final fileExts = {
        'pdf': 'PDF', 'doc': 'DOC', 'docx': 'DOCX', 'xls': 'XLS', 'xlsx': 'XLSX',
        'txt': 'TXT', 'zip': 'ZIP', 'rar': 'RAR', 'ppt': 'PPT', 'pptx': 'PPTX',
        'jpg': 'JPG', 'jpeg': 'JPEG', 'png': 'PNG', 'gif': 'GIF'
      };
      fileType = fileExts[ext] ?? ext.toUpperCase();
    }
    
    if (message.content.startsWith('{') || message.content.startsWith('[')) {
      try {
        final fileData = jsonDecode(message.content);
        if (fileData is Map) {
          fileName = fileData['filename'] ?? fileName;
          fileSize = fileData['filesize'] != null ? _formatFileSize(fileData['filesize']) : '';
          fileType = fileData['filetype'] ?? fileType;
          fileUrl = fileData['url'] ?? fileUrl;
        }
      } catch (e) {}
    }
    
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileName.split('.').last.toLowerCase());
    
    if (isImage && fileUrl.isNotEmpty) {
      return InkWell(
        onTap: () => _openImageViewer(fileUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: fileUrl,
            width: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 150,
              color: AppColors.gray200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 150,
              color: AppColors.gray200,
              child: const Icon(Icons.broken_image, size: 40, color: AppColors.gray400),
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSent ? Colors.white.withValues(alpha: 0.1) : AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSent ? Colors.white24 : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSent ? Colors.white24 : AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileName),
              color: isSent ? Colors.white : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.length > 30 ? '${fileName.substring(0, 27)}...' : fileName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSent ? Colors.white : AppColors.gray800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (fileType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSent ? Colors.white24 : AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fileType,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: isSent ? Colors.white70 : AppColors.gray600,
                          ),
                        ),
                      ),
                    if (fileSize.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        fileSize,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: isSent ? Colors.white60 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.download,
              color: isSent ? Colors.white70 : AppColors.primary,
              size: 18,
            ),
            onPressed: () => _downloadFile(fileUrl, fileName),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': return Icons.description;
      case 'docx': return Icons.description;
      case 'xls': return Icons.table_chart;
      case 'xlsx': return Icons.table_chart;
      case 'ppt': return Icons.slideshow;
      case 'pptx': return Icons.slideshow;
      case 'zip': return Icons.archive;
      case 'rar': return Icons.archive;
      case 'txt': return Icons.text_snippet;
      case 'jpg': return Icons.image;
      case 'jpeg': return Icons.image;
      case 'png': return Icons.image;
      case 'gif': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  Future<void> _openImageViewer(String url) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _showSnackBar('Download started');
      } else {
        _showSnackBar('Could not download file', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error downloading file', isError: true);
    }
  }

  // ============================================================
  // MESSAGE INPUT
  // ============================================================
  
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
              if (value == 'file') {
                _uploadFile();
              } else if (value == 'image') {
                _uploadImage();
              } else if (value == 'location') {
                _shareLocation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'file',
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 20),
                    SizedBox(width: 8),
                    Text('Attach File'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    Icon(Icons.image, size: 20),
                    SizedBox(width: 8),
                    Text('Attach Image'),
                  ],
                ),
              ),
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

  // ============================================================
  // HELPER METHODS
  // ============================================================

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