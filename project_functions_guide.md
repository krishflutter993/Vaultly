# Project Functions and Methods Guide

This guide lists and explains all classes, methods, and functions found in the project's Dart source files.

## File: [main.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/main.dart)
Path: `lib/main.dart`

### Functions & Methods:

#### `main` (Line 10)
- **Signature**: `void main() async {`
- **Location**: Global/Top-level: 
- **Code Snippet**:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  ```

---

## File: [attachment_model.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/model/attachment_model.dart)
Path: `lib/model/attachment_model.dart`

### Classes Defined:
- **AttachmentModel** (Line 1)

---

## File: [theme_provider.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/providers/theme_provider.dart)
Path: `lib/providers/theme_provider.dart`

### Classes Defined:
- **ThemeProvider** (Line 4)

### Functions & Methods:

#### `loadTheme` (Line 14)
- **Signature**: `Future<void> loadTheme() async {`
- **Location**: In Class `ThemeProvider`: 
- **Code Snippet**:
  ```dart
  Future<void> loadTheme() async {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    }
  ```

#### `toggleTheme` (Line 20)
- **Signature**: `Future<void> toggleTheme(bool value) async {`
- **Location**: In Class `ThemeProvider`: 
- **Code Snippet**:
  ```dart
  Future<void> toggleTheme(bool value) async {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    }
  ```

---

## File: [glass_container.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/theme/glass_container.dart)
Path: `lib/theme/glass_container.dart`

### Classes Defined:
- **GlassContainer** (Line 4)

### Functions & Methods:

#### `build` (Line 31)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `GlassContainer`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final defaultColor = color ?? (isDark ? Colors.white : Colors.black);
      final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
  
      return Container(
  ```

---

## File: [theme.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/theme/theme.dart)
Path: `lib/theme/theme.dart`

### Classes Defined:
- **AppTheme** (Line 4)

---

## File: [CategoryItems.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/dashboard/Screen/CategoryItems.dart)
Path: `lib/user/dashboard/Screen/CategoryItems.dart`

### Classes Defined:
- **CategoryDetailsScreen** (Line 16)
- **ItemAttachmentsWidget** (Line 283)

### Functions & Methods:

#### `build` (Line 22)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `CategoryDetailsScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;
  
      if (user == null) {
        return const Scaffold(body: Center(child: Text("User not logged in")));
      }
  ```

#### `_buildDetailRow` (Line 233)
- **Signature**: `Widget _buildDetailRow(BuildContext context, String title, String value) {`
- **Location**: In Class `CategoryDetailsScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildDetailRow(BuildContext context, String title, String value) {
      if (value.isEmpty ||
          value == 'No Password' ||
          value == 'No URL' ||
          value == 'No Notes') {
        return const SizedBox.shrink();
  ```

#### `createState` (Line 294)
- **Signature**: `State<ItemAttachmentsWidget> createState() => _ItemAttachmentsWidgetState();`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  State<ItemAttachmentsWidget> createState() => _ItemAttachmentsWidgetState();
  }
  
  class _ItemAttachmentsWidgetState extends State<ItemAttachmentsWidget> {
    List<dynamic> _attachments = [];
    bool _isLoading = true;
  ```

#### `initState` (Line 302)
- **Signature**: `void initState() {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  void initState() {
      super.initState();
      _loadAttachments();
    }
  
    Future<void> _loadAttachments() async {
  ```

#### `_loadAttachments` (Line 307)
- **Signature**: `Future<void> _loadAttachments() async {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  Future<void> _loadAttachments() async {
      try {
        var url = Uri.parse(
          "https://prakrutitech.xyz/krish/view_attachments.php?firebase_uid=${widget.uid}&item_id=${widget.itemId}",
        );
        var response = await http.get(url);
  ```

#### `build` (Line 332)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      if (_isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: SizedBox(
  ```

#### `_isImage` (Line 345)
- **Signature**: `bool _isImage(String pathOrUrl) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  bool _isImage(String pathOrUrl) {
        final mime = pathOrUrl.split('?').first.toLowerCase();
        return mime.endsWith('.jpg') ||
            mime.endsWith('.jpeg') ||
            mime.endsWith('.png') ||
            mime.endsWith('.gif') ||
  ```

#### `_getFileIcon` (Line 355)
- **Signature**: `IconData _getFileIcon(String pathOrUrl) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  IconData _getFileIcon(String pathOrUrl) {
        final cleanPath = pathOrUrl.split('?').first.toLowerCase();
        if (cleanPath.endsWith('.pdf')) {
          return Icons.picture_as_pdf_rounded;
        } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
          return Icons.description_rounded;
  ```

#### `_getFileIconColor` (Line 374)
- **Signature**: `Color _getFileIconColor(BuildContext context, String pathOrUrl) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  Color _getFileIconColor(BuildContext context, String pathOrUrl) {
        final cleanPath = pathOrUrl.split('?').first.toLowerCase();
        if (cleanPath.endsWith('.pdf')) {
          return Colors.redAccent;
        } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
          return Colors.blueAccent;
  ```

#### `_showErrorDialog` (Line 392)
- **Signature**: `void _showErrorDialog(BuildContext context, String title, String message) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  void _showErrorDialog(BuildContext context, String title, String message) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
  ```

#### `_getFriendlyError` (Line 408)
- **Signature**: `String _getFriendlyError(OpenResult result) {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  String _getFriendlyError(OpenResult result) {
        switch (result.type) {
          case ResultType.noAppToOpen:
            return "No compatible application is installed on your device to open this file type. Please install an appropriate app and try again.";
          case ResultType.fileNotFound:
            return "The file could not be found on your device.";
  ```

#### `_extractArchive` (Line 421)
- **Signature**: `Future<void> _extractArchive(BuildContext context, File file) async {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  Future<void> _extractArchive(BuildContext context, File file) async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
  ```

#### `_handleArchiveTap` (Line 507)
- **Signature**: `Future<void> _handleArchiveTap(BuildContext context, File file) async {`
- **Location**: In Class `ItemAttachmentsWidget`: 
- **Code Snippet**:
  ```dart
  Future<void> _handleArchiveTap(BuildContext context, File file) async {
        final cleanPath = file.path.toLowerCase();
        final extension = cleanPath.split('.').last;
        if (extension != 'zip' && extension != 'tar') {
          showDialog(
            context: context,
  ```

---

## File: [add_item_screen.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/dashboard/Screen/add_item_screen.dart)
Path: `lib/user/dashboard/Screen/add_item_screen.dart`

### Classes Defined:
- **AddItemScreen** (Line 13)

### Functions & Methods:

#### `createState` (Line 22)
- **Signature**: `State<AddItemScreen> createState() => _AddItemScreenState();`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  State<AddItemScreen> createState() => _AddItemScreenState();
  }
  
  class _AddItemScreenState extends State<AddItemScreen> {
    // Controllers
    final _titleCtrl = TextEditingController();
  ```

#### `initState` (Line 44)
- **Signature**: `void initState() {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  void initState() {
      super.initState();
  
      _itemId = FirebaseFirestore.instance.collection('users').doc().id;
  
      final user = FirebaseAuth.instance.currentUser;
  ```

#### `dispose` (Line 65)
- **Signature**: `void dispose() {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  void dispose() {
      _titleCtrl.dispose();
      _usernameCtrl.dispose();
      _passwordCtrl.dispose();
      _urlCtrl.dispose();
      _notesCtrl.dispose();
  ```

#### `_calcStrength` (Line 74)
- **Signature**: `double _calcStrength(String pwd) {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  double _calcStrength(String pwd) {
      if (pwd.isEmpty) return 0;
      double score = 0;
      if (pwd.length >= 8) score += 0.2;
      if (pwd.length >= 12) score += 0.2;
      if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.2;
  ```

#### `_strengthColor` (Line 85)
- **Signature**: `Color _strengthColor(double s) {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  Color _strengthColor(double s) {
      if (s < 0.4) return Colors.redAccent;
      if (s < 0.7) return Colors.orangeAccent;
      return Colors.green;
    }
  ```

#### `_generatePassword` (Line 91)
- **Signature**: `String _generatePassword() {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  String _generatePassword() {
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
      final rng = Random.secure();
      return List.generate(16, (_) => chars[rng.nextInt(chars.length)]).join();
    }
  ```

#### `_onSave` (Line 98)
- **Signature**: `Future<void> _onSave() async {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _onSave() async {
      if (_titleCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Title is required'),
            backgroundColor: Colors.redAccent,
  ```

#### `_addCustomField` (Line 176)
- **Signature**: `void _addCustomField() {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  void _addCustomField() {
      showDialog(
        context: context,
        builder: (ctx) {
          final labelCtrl = TextEditingController();
          return AlertDialog(
  ```

#### `_uploadLocalFile` (Line 230)
- **Signature**: `Future<bool> _uploadLocalFile(File file) async {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<bool> _uploadLocalFile(File file) async {
      try {
        var firebaseUid = FirebaseAuth.instance.currentUser!.uid;
        var url = Uri.parse(
          "https://prakrutitech.xyz/krish/upload_attachment.php",
        );
  ```

#### `_addFile` (Line 252)
- **Signature**: `Future<void> _addFile() async {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _addFile() async {
      List<File>? selectedFiles = await showModalBottomSheet<List<File>>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ```

#### `build` (Line 346)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `AddItemScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Entry'),
          actions: [
            IconButton(
  ```

---

## File: [edit_item_screen.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/dashboard/Screen/edit_item_screen.dart)
Path: `lib/user/dashboard/Screen/edit_item_screen.dart`

### Classes Defined:
- **EditItemScreen** (Line 13)

### Functions & Methods:

#### `createState` (Line 26)
- **Signature**: `State<EditItemScreen> createState() => _EditItemScreenState();`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  State<EditItemScreen> createState() => _EditItemScreenState();
  }
  
  class _EditItemScreenState extends State<EditItemScreen> {
    // Controllers
    final _titleCtrl = TextEditingController();
  ```

#### `initState` (Line 51)
- **Signature**: `void initState() {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  void initState() {
      super.initState();
  
      _itemId = widget.itemId;
      _loadAttachments();
  ```

#### `dispose` (Line 89)
- **Signature**: `void dispose() {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  void dispose() {
      _titleCtrl.dispose();
      _usernameCtrl.dispose();
      _passwordCtrl.dispose();
      _urlCtrl.dispose();
      _notesCtrl.dispose();
  ```

#### `_calcStrength` (Line 98)
- **Signature**: `double _calcStrength(String pwd) {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  double _calcStrength(String pwd) {
      if (pwd.isEmpty) return 0;
      double score = 0;
      if (pwd.length >= 8) score += 0.2;
      if (pwd.length >= 12) score += 0.2;
      if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.2;
  ```

#### `_strengthColor` (Line 109)
- **Signature**: `Color _strengthColor(double s) {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Color _strengthColor(double s) {
      if (s < 0.4) return Colors.redAccent;
      if (s < 0.7) return Colors.orangeAccent;
      return Colors.green;
    }
  ```

#### `_generatePassword` (Line 115)
- **Signature**: `String _generatePassword() {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  String _generatePassword() {
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
      final rng = Random.secure();
      return List.generate(16, (_) => chars[rng.nextInt(chars.length)]).join();
    }
  ```

#### `_onSave` (Line 122)
- **Signature**: `Future<void> _onSave() async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _onSave() async {
      if (_titleCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Title is required'),
            backgroundColor: Colors.redAccent,
  ```

#### `_onDelete` (Line 199)
- **Signature**: `Future<void> _onDelete() async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _onDelete() async {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        for (var file in _attachedFiles) {
          await http.post(
            Uri.parse("https://prakrutitech.xyz/krish/delete_attachment.php"),
  ```

#### `_addCustomField` (Line 229)
- **Signature**: `void _addCustomField() {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  void _addCustomField() {
      showDialog(
        context: context,
        builder: (ctx) {
          final labelCtrl = TextEditingController();
          return AlertDialog(
  ```

#### `_loadAttachments` (Line 283)
- **Signature**: `Future<void> _loadAttachments() async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _loadAttachments() async {
      setState(() {
        attachmentsLoading = true;
        attachmentsError = "";
      });
  ```

#### `_deleteFile` (Line 327)
- **Signature**: `Future<void> _deleteFile(AttachedFile file) async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _deleteFile(AttachedFile file) async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ```

#### `_uploadLocalFile` (Line 396)
- **Signature**: `Future<bool> _uploadLocalFile(File file) async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<bool> _uploadLocalFile(File file) async {
      try {
        var firebaseUid = FirebaseAuth.instance.currentUser!.uid;
        var url = Uri.parse(
          "https://prakrutitech.xyz/krish/upload_attachment.php",
        );
  ```

#### `_addFile` (Line 418)
- **Signature**: `Future<void> _addFile() async {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _addFile() async {
      List<File>? selectedFiles = await showModalBottomSheet<List<File>>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ```

#### `build` (Line 512)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `EditItemScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Entry'),
          actions: [
            IconButton(
  ```

---

## File: [shared_item_widgets.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/dashboard/Screen/shared_item_widgets.dart)
Path: `lib/user/dashboard/Screen/shared_item_widgets.dart`

### Classes Defined:
- **CustomField** (Line 8)
- **AttachedFile** (Line 14)
- **InputTile** (Line 28)
- **PasswordTile** (Line 52)
- **UrlTile** (Line 117)
- **CustomFieldTile** (Line 140)
- **FileTile** (Line 178)
- **LocalFileTile** (Line 278)
- **NotesTile** (Line 378)

### Functions & Methods:

#### `build` (Line 43)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `InputTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      );
  ```

#### `build` (Line 71)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `PasswordTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
  ```

#### `build` (Line 124)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `UrlTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: 'Website URL',
  ```

#### `build` (Line 147)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `CustomFieldTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final valueCtrl = TextEditingController(text: field.value);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
  ```

#### `build` (Line 185)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `FileTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final isImg = isImage(
        file.imageUrl.isNotEmpty ? file.imageUrl : file.name,
      );
      return Container(
        margin: const EdgeInsets.only(bottom: 12.0),
  ```

#### `_getFileSizeString` (Line 284)
- **Signature**: `String _getFileSizeString(File file) {`
- **Location**: In Class `LocalFileTile`: 
- **Code Snippet**:
  ```dart
  String _getFileSizeString(File file) {
      try {
        int bytes = file.lengthSync();
        return "${(bytes / 1024).toStringAsFixed(1)} KB";
      } catch (e) {
        return "0.0 KB";
  ```

#### `build` (Line 294)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `LocalFileTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final fileName = file.path.split('/').last;
      final isImg = isImage(file.path);
      return Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
  ```

#### `build` (Line 383)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Add some secure notes here...',
  ```

#### `isImage` (Line 395)
- **Signature**: `bool isImage(String pathOrUrl) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  bool isImage(String pathOrUrl) {
    final mime = pathOrUrl.split('?').first.toLowerCase();
    return mime.endsWith('.jpg') ||
        mime.endsWith('.jpeg') ||
        mime.endsWith('.png') ||
        mime.endsWith('.gif') ||
  ```

#### `getFileIcon` (Line 405)
- **Signature**: `IconData getFileIcon(String pathOrUrl) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  IconData getFileIcon(String pathOrUrl) {
    final cleanPath = pathOrUrl.split('?').first.toLowerCase();
    if (cleanPath.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
      return Icons.description_rounded;
  ```

#### `getFileIconColor` (Line 424)
- **Signature**: `Color getFileIconColor(BuildContext context, String pathOrUrl) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  Color getFileIconColor(BuildContext context, String pathOrUrl) {
    final cleanPath = pathOrUrl.split('?').first.toLowerCase();
    if (cleanPath.endsWith('.pdf')) {
      return Colors.redAccent;
    } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
      return Colors.blueAccent;
  ```

#### `showErrorDialog` (Line 442)
- **Signature**: `void showErrorDialog(BuildContext context, String title, String message) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
  ```

#### `getFriendlyError` (Line 458)
- **Signature**: `String getFriendlyError(OpenResult result) {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  String getFriendlyError(OpenResult result) {
    switch (result.type) {
      case ResultType.noAppToOpen:
        return "No compatible application is installed on your device to open this file type. Please install an appropriate app and try again.";
      case ResultType.fileNotFound:
        return "The file could not be found on your device.";
  ```

#### `extractArchive` (Line 471)
- **Signature**: `Future<void> extractArchive(BuildContext context, File file) async {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  Future<void> extractArchive(BuildContext context, File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
  ```

#### `handleArchiveTap` (Line 555)
- **Signature**: `Future<void> handleArchiveTap(BuildContext context, File file) async {`
- **Location**: In Class `NotesTile`: 
- **Code Snippet**:
  ```dart
  Future<void> handleArchiveTap(BuildContext context, File file) async {
    final cleanPath = file.path.toLowerCase();
    final extension = cleanPath.split('.').last;
    if (extension != 'zip' && extension != 'tar') {
      showDialog(
        context: context,
  ```

---

## File: [dashboard.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/dashboard/dashboard.dart)
Path: `lib/user/dashboard/dashboard.dart`

### Classes Defined:
- **DashboardScreen** (Line 10)

### Functions & Methods:

#### `createState` (Line 14)
- **Signature**: `State<DashboardScreen> createState() => _DashboardScreenState();`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  State<DashboardScreen> createState() => _DashboardScreenState();
  }
  
  class _DashboardScreenState extends State<DashboardScreen> {
    String searchText = '';
    final TextEditingController searchController = TextEditingController();
  ```

#### `initState` (Line 36)
- **Signature**: `void initState() {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  void initState() {
      super.initState();
      categories = List.from(defaultCategories);
      _loadCustomCategories();
    }
  ```

#### `_loadCustomCategories` (Line 42)
- **Signature**: `Future<void> _loadCustomCategories() async {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _loadCustomCategories() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
  
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  ```

#### `_deleteCategory` (Line 67)
- **Signature**: `void _deleteCategory(String title) async {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  void _deleteCategory(String title) async {
      setState(() {
        categories.removeWhere((c) => c['title'] == title);
      });
  
      final user = FirebaseAuth.instance.currentUser;
  ```

#### `_showAddCategoryDialog` (Line 89)
- **Signature**: `void _showAddCategoryDialog() {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  void _showAddCategoryDialog() {
      final TextEditingController catController = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
  ```

#### `_buildVaultView` (Line 146)
- **Signature**: `Widget _buildVaultView() {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildVaultView() {
      final filtered = categories.where((item) {
        return item["title"].toString().toLowerCase().contains(searchText.toLowerCase());
      }).toList();
  
      return Column(
  ```

#### `build` (Line 330)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `DashboardScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final List<Widget> pages = [
        _buildVaultView(),
        const ProfileScreen(),
        const SettingsScreen(),
      ];
  ```

---

## File: [loging.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/loging/loging.dart)
Path: `lib/user/loging/loging.dart`

### Classes Defined:
- **LoginScreen** (Line 7)

### Functions & Methods:

#### `createState` (Line 11)
- **Signature**: `State<LoginScreen> createState() => _LoginScreenState();`
- **Location**: In Class `LoginScreen`: 
- **Code Snippet**:
  ```dart
  State<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends State<LoginScreen> {
    final email = TextEditingController();
    final password = TextEditingController();
  ```

#### `build` (Line 21)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `LoginScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
  ```

---

## File: [forgot_password.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/masterpassword/forgot_password.dart)
Path: `lib/user/masterpassword/forgot_password.dart`

### Classes Defined:
- **ForgotMasterPasswordScreen** (Line 8)

### Functions & Methods:

#### `createState` (Line 12)
- **Signature**: `State<ForgotMasterPasswordScreen> createState() => _ForgotMasterPasswordScreenState();`
- **Location**: In Class `ForgotMasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  State<ForgotMasterPasswordScreen> createState() => _ForgotMasterPasswordScreenState();
  }
  
  class _ForgotMasterPasswordScreenState extends State<ForgotMasterPasswordScreen> {
    final TextEditingController _newMasterController = TextEditingController();
    bool isLoading = false;
  ```

#### `hashPassword` (Line 20)
- **Signature**: `String hashPassword(String password) {`
- **Location**: In Class `ForgotMasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  String hashPassword(String password) {
      return sha256.convert(utf8.encode(password)).toString();
    }
  
    Future<void> updateMasterPassword() async {
      if (_newMasterController.text.trim().isEmpty) {
  ```

#### `updateMasterPassword` (Line 24)
- **Signature**: `Future<void> updateMasterPassword() async {`
- **Location**: In Class `ForgotMasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> updateMasterPassword() async {
      if (_newMasterController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a new master password"), backgroundColor: Colors.redAccent),
        );
        return;
  ```

#### `dispose` (Line 75)
- **Signature**: `void dispose() {`
- **Location**: In Class `ForgotMasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  void dispose() {
      _newMasterController.dispose();
      super.dispose();
    }
  
    @override
  ```

#### `build` (Line 81)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `ForgotMasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Reset Master Password"),
        ),
        body: Container(
  ```

---

## File: [pass_loging.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/masterpassword/pass_loging.dart)
Path: `lib/user/masterpassword/pass_loging.dart`

### Classes Defined:
- **MasterVerifyScreen** (Line 11)

### Functions & Methods:

#### `createState` (Line 15)
- **Signature**: `State<MasterVerifyScreen> createState() => _MasterVerifyScreenState();`
- **Location**: In Class `MasterVerifyScreen`: 
- **Code Snippet**:
  ```dart
  State<MasterVerifyScreen> createState() => _MasterVerifyScreenState();
  }
  
  class _MasterVerifyScreenState extends State<MasterVerifyScreen> {
    final TextEditingController masterController = TextEditingController();
    bool isLoading = false;
  ```

#### `hashPassword` (Line 23)
- **Signature**: `String hashPassword(String password) {`
- **Location**: In Class `MasterVerifyScreen`: 
- **Code Snippet**:
  ```dart
  String hashPassword(String password) {
      return sha256.convert(utf8.encode(password)).toString();
    }
  
    Future<void> verifyMasterPassword() async {
      if (masterController.text.isEmpty) {
  ```

#### `verifyMasterPassword` (Line 27)
- **Signature**: `Future<void> verifyMasterPassword() async {`
- **Location**: In Class `MasterVerifyScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> verifyMasterPassword() async {
      if (masterController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter Master Password"),
            backgroundColor: Colors.redAccent,
  ```

#### `build` (Line 98)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `MasterVerifyScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
  ```

---

## File: [password_signuo.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/masterpassword/password_signuo.dart)
Path: `lib/user/masterpassword/password_signuo.dart`

### Classes Defined:
- **MasterPasswordScreen** (Line 9)

### Functions & Methods:

#### `createState` (Line 13)
- **Signature**: `State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();`
- **Location**: In Class `MasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
  }
  
  class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
    final TextEditingController masterController = TextEditingController();
    bool isLoading = false;
  ```

#### `hashPassword` (Line 21)
- **Signature**: `String hashPassword(String password) {`
- **Location**: In Class `MasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  String hashPassword(String password) {
      return sha256.convert(utf8.encode(password)).toString();
    }
  
    Future<void> saveMasterPassword() async {
      if (masterController.text.trim().isEmpty) {
  ```

#### `saveMasterPassword` (Line 25)
- **Signature**: `Future<void> saveMasterPassword() async {`
- **Location**: In Class `MasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> saveMasterPassword() async {
      if (masterController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a Master Password"), backgroundColor: Colors.redAccent),
        );
        return;
  ```

#### `build` (Line 67)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `MasterPasswordScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Setup Master Password"),
        ),
        body: Container(
  ```

---

## File: [onboarding_screen.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/onboarding/onboarding_screen.dart)
Path: `lib/user/onboarding/onboarding_screen.dart`

### Classes Defined:
- **OnboardingScreen** (Line 6)
- **PremiumGlassCard** (Line 366)
- **OnboardingContent** (Line 400)

### Functions & Methods:

#### `createState` (Line 10)
- **Signature**: `State<OnboardingScreen> createState() => _OnboardingScreenState();`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  State<OnboardingScreen> createState() => _OnboardingScreenState();
  }
  
  class _OnboardingScreenState extends State<OnboardingScreen> {
    final PageController _pageController = PageController();
    int _currentPage = 0;
  ```

#### `_completeOnboarding` (Line 43)
- **Signature**: `Future<void> _completeOnboarding() async {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _completeOnboarding() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
  ```

#### `_nextPage` (Line 59)
- **Signature**: `void _nextPage() {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  void _nextPage() {
      if (_currentPage < _contents.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
  ```

#### `_prevPage` (Line 70)
- **Signature**: `void _prevPage() {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  void _prevPage() {
      if (_currentPage > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
  ```

#### `dispose` (Line 80)
- **Signature**: `void dispose() {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  void dispose() {
      _pageController.dispose();
      super.dispose();
    }
  
    @override
  ```

#### `build` (Line 86)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: _bgMint,
        body: Stack(
          children: [
            // Background floating shapes (Blurred teal circles)
  ```

#### `_buildBlurredCircle` (Line 237)
- **Signature**: `Widget _buildBlurredCircle(Color color, double size) {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildBlurredCircle(Color color, double size) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4),
  ```

#### `_buildNavigationControls` (Line 252)
- **Signature**: `Widget _buildNavigationControls() {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildNavigationControls() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage == 0
              ? const SizedBox(width: 56) // Placeholder for alignment
  ```

#### `_buildGetStartedButton` (Line 316)
- **Signature**: `Widget _buildGetStartedButton() {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildGetStartedButton() {
      return GestureDetector(
        onTap: _completeOnboarding,
        child: Container(
          width: double.infinity,
          height: 64,
  ```

#### `_buildDot` (Line 352)
- **Signature**: `Widget _buildDot(int index) {`
- **Location**: In Class `OnboardingScreen`: 
- **Code Snippet**:
  ```dart
  Widget _buildDot(int index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: _currentPage == index ? 24 : 8,
  ```

#### `build` (Line 372)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `PremiumGlassCard`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
  ```

---

## File: [profile_screen.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/profile/profile_screen.dart)
Path: `lib/user/profile/profile_screen.dart`

### Classes Defined:
- **ProfileScreen** (Line 5)

### Functions & Methods:

#### `build` (Line 9)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `ProfileScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;
  
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
  ```

---

## File: [settings_screen.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/settings/settings_screen.dart)
Path: `lib/user/settings/settings_screen.dart`

### Classes Defined:
- **SettingsScreen** (Line 7)

### Functions & Methods:

#### `build` (Line 11)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `SettingsScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Container(
  ```

---

## File: [signup.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/signup/signup.dart)
Path: `lib/user/signup/signup.dart`

### Classes Defined:
- **SignupScreen** (Line 6)

### Functions & Methods:

#### `createState` (Line 10)
- **Signature**: `State<SignupScreen> createState() => _SignupScreenState();`
- **Location**: In Class `SignupScreen`: 
- **Code Snippet**:
  ```dart
  State<SignupScreen> createState() => _SignupScreenState();
  }
  
  class _SignupScreenState extends State<SignupScreen> {
    final email = TextEditingController();
    final password = TextEditingController();
  ```

#### `_calcStrength` (Line 19)
- **Signature**: `double _calcStrength(String pwd) {`
- **Location**: In Class `SignupScreen`: 
- **Code Snippet**:
  ```dart
  double _calcStrength(String pwd) {
      if (pwd.isEmpty) return 0;
      double score = 0;
      if (pwd.length >= 8) score += 0.2;
      if (pwd.length >= 12) score += 0.2;
      if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.2;
  ```

#### `build` (Line 31)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `SignupScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      final strength = _calcStrength(password.text);
      final strengthColor = strength < 0.4 ? Colors.redAccent : (strength < 0.7 ? Colors.orangeAccent : Colors.green);
  
      return Scaffold(
        body: Container(
  ```

---

## File: [splash.dart](file:///Users/krishsavaliya/Documents/accounts_information_handler/lib/user/splashscreen/splash.dart)
Path: `lib/user/splashscreen/splash.dart`

### Classes Defined:
- **SplashScreen** (Line 8)

### Functions & Methods:

#### `createState` (Line 12)
- **Signature**: `State<SplashScreen> createState() => _SplashScreenState();`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  State<SplashScreen> createState() => _SplashScreenState();
  }
  
  class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
  ```

#### `initState` (Line 20)
- **Signature**: `void initState() {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  void initState() {
      super.initState();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
  ```

#### `dispose` (Line 34)
- **Signature**: `void dispose() {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  void dispose() {
      _animationController.dispose();
      super.dispose();
    }
  
    Future<void> _startSplash() async {
  ```

#### `_startSplash` (Line 39)
- **Signature**: `Future<void> _startSplash() async {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> _startSplash() async {
      await Future.delayed(const Duration(seconds: 3));
      await checkInternetAndLogin();
    }
  
    Future<bool> hasInternet() async {
  ```

#### `hasInternet` (Line 44)
- **Signature**: `Future<bool> hasInternet() async {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  Future<bool> hasInternet() async {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException {
        return false;
  ```

#### `checkInternetAndLogin` (Line 53)
- **Signature**: `Future<void> checkInternetAndLogin() async {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  Future<void> checkInternetAndLogin() async {
      bool internet = await hasInternet();
  
      if (!mounted) return;
  
      if (internet) {
  ```

#### `build` (Line 93)
- **Signature**: `Widget build(BuildContext context) {`
- **Location**: In Class `SplashScreen`: 
- **Code Snippet**:
  ```dart
  Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
  ```

---

