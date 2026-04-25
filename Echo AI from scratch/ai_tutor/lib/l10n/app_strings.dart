import 'package:flutter/material.dart';

class AppStrings {
  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context).languageCode);
  }

  final String languageCode;

  AppStrings(this.languageCode);

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'newChat': 'New Chat',
      'chatHistory': 'Chat History',
      'settings': 'Settings',
      'clearAllChats': 'Clear All Chat History',
      'appLanguage': 'App Language',
      'voiceLanguage': 'Voice Language',
      'fontSize': 'Font Size',
      'theme': 'App Theme',
      'about': 'About',
      'sendMessage': 'Send',
      'typeMessage': 'Type your message...',
      'thinking': 'Thinking...',
      'analyzing': 'Analyzing your question...',
      'preparingResponse': 'Preparing response...',
      'noChatsYet': 'No chats yet',
      'startFirstConversation': 'Start your first conversation',
      'home': 'Home',
      'projects': 'Projects',
      'deleteChat': 'Delete Chat',
      'renameChat': 'Rename Chat',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'darkMode': 'Dark',
      'lightMode': 'Light',
      'systemDefault': 'System',
      'english': 'English',
      'hindi': 'Hindi',
      'bengali': 'Bengali',
      'volume': 'Volume',
      'pitch': 'Pitch',
      'speechRate': 'Speech Rate',
      'clearConfirmMessage': 'Are you sure you want to delete all chat history? This action cannot be undone.',
      'renameChatTitle': 'Rename Chat',
      'enterNewName': 'Enter new name',
      'save': 'Save',
      'clear': 'Clear',
      'clearAllData': 'Clear All Data',
      'allChatHistoryCleared': 'All chat history cleared',
      'processingImage': 'Processing image...',
      'noTextFound': 'No text found in the image',
      'askMeAnything': 'Ask me anything!',
      'hereToHelp': 'I\'m here to help you learn',
      'voiceGender': 'Voice Gender',
      'female': 'Female',
      'male': 'Male',
      'storageLocation': 'Storage Location',
      'thisActionCannotBeUndone': 'This action cannot be undone',
      'adStatus': 'Ad Status',
      'activeRevenue': 'Active - Revenue optimization enabled',
      'version': 'Version 1.0.0',
      'yourPersonalAi': 'Your personal AI learning assistant powered by Groq',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'echo': 'Echo',
      'helloImEcho': 'Hello, I\'m Echo',
      'personalAiAssistant': 'Your personal AI learning assistant',
    },
    'hi': {
      'newChat': 'नई बातचीत',
      'chatHistory': 'बातचीत का इतिहास',
      'settings': 'सेटिंग्स',
      'clearAllChats': 'सभी बातचीत साफ़ करें',
      'appLanguage': 'ऐप भाषा',
      'voiceLanguage': 'आवाज़ भाषा',
      'fontSize': 'फ़ॉन्ट आकार',
      'theme': 'ऐप थीम',
      'about': 'बारे में',
      'sendMessage': 'भेजें',
      'typeMessage': 'अपना संदेश लिखें...',
      'thinking': 'सोच रहा हूँ...',
      'analyzing': 'आपका सवाल विश्लेषण कर रहा हूँ...',
      'preparingResponse': 'जवाब तैयार कर रहा हूँ...',
      'noChatsYet': 'अभी तक कोई बातचीत नहीं',
      'startFirstConversation': 'अपनी पहली बातचीत शुरू करें',
      'home': 'होम',
      'projects': 'प्रोजेक्ट्स',
      'deleteChat': 'बातचीत हटाएं',
      'renameChat': 'बातचीत का नाम बदलें',
      'cancel': 'रद्द करें',
      'confirm': 'पुष्टि करें',
      'darkMode': 'डार्क',
      'lightMode': 'लाइट',
      'systemDefault': 'सिस्टम',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'bengali': 'बांग्ला',
      'volume': 'वॉल्यूम',
      'pitch': 'पिच',
      'speechRate': 'बोलने की गति',
      'clearConfirmMessage': 'क्या आप वाकई सभी बातचीत इतिहास हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।',
      'renameChatTitle': 'बातचीत का नाम बदलें',
      'enterNewName': 'नया नाम दर्ज करें',
      'save': 'सहेजें',
      'clear': 'साफ़ करें',
      'clearAllData': 'सभी डेटा साफ़ करें',
      'allChatHistoryCleared': 'सभी बातचीत इतिहास साफ़ हो गया',
      'processingImage': 'छवि प्रोसेस हो रही है...',
      'noTextFound': 'छवि में कोई टेक्स्ट नहीं मिला',
      'askMeAnything': 'मुझसे कोई भी सवाल पूछें!',
      'hereToHelp': 'मैं आपकी मदद के लिए यहाँ हूँ',
      'voiceGender': 'आवाज़ प्रकार',
      'female': 'महिला',
      'male': 'पुरुष',
      'storageLocation': 'स्टोरेज स्थान',
      'thisActionCannotBeUndone': 'यह कार्रवाई पूर्ववत नहीं की जा सकती',
      'adStatus': 'विज्ञापन स्थिति',
      'activeRevenue': 'सक्रिय - राजस्व अनुकूलन सक्षम',
      'version': 'संस्करण 1.0.0',
      'yourPersonalAi': 'Groq द्वारा संचालित आपका व्यक्तिगत AI सीखने का सहायक',
      'small': 'छोटा',
      'medium': 'मध्यम',
      'large': 'बड़ा',
      'echo': 'एको',
      'helloImEcho': 'नमस्ते, मैं एको हूँ',
      'personalAiAssistant': 'आपका व्यक्तिगत AI सीखने का सहायक',
    },
    'bn': {
      'newChat': 'নতুন চ্যাট',
      'chatHistory': 'চ্যাট ইতিহাস',
      'settings': 'সেটিংস',
      'clearAllChats': 'সব চ্যাট মুছুন',
      'appLanguage': 'অ্যাপ ভাষা',
      'voiceLanguage': 'ভয়েস ভাষা',
      'fontSize': 'ফন্ট সাইজ',
      'theme': 'অ্যাপ থিম',
      'about': 'সম্পর্কে',
      'sendMessage': 'পাঠান',
      'typeMessage': 'আপনার বার্তা লিখুন...',
      'thinking': 'ভাবছি...',
      'analyzing': 'আপনার প্রশ্ন বিশ্লেষণ করছি...',
      'preparingResponse': 'উত্তর প্রস্তুত করছি...',
      'noChatsYet': 'এখনও কোনো চ্যাট নেই',
      'startFirstConversation': 'আপনার প্রথম কথোপকথন শুরু করুন',
      'home': 'হোম',
      'projects': 'প্রজেক্ট',
      'deleteChat': 'চ্যাট মুছুন',
      'renameChat': 'চ্যাটের নাম বদলান',
      'cancel': 'বাতিল',
      'confirm': 'নিশ্চিত করুন',
      'darkMode': 'ডার্ক',
      'lightMode': 'লাইট',
      'systemDefault': 'সিস্টেম',
      'english': 'ইংরেজি',
      'hindi': 'হিন্দি',
      'bengali': 'বাংলা',
      'volume': 'ভলিউম',
      'pitch': 'পিচ',
      'speechRate': 'বলার গতি',
      'clearConfirmMessage': 'আপনি কি সত্যিই সব চ্যাট ইতিহাস মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।',
      'renameChatTitle': 'চ্যাটের নাম বদলান',
      'enterNewName': 'নতুন নাম লিখুন',
      'save': 'সংরক্ষণ',
      'clear': 'মুছুন',
      'clearAllData': 'সব ডেটা মুছুন',
      'allChatHistoryCleared': 'সব চ্যাট ইতিহাস মুছে ফেলা হয়েছে',
      'processingImage': 'ছবি প্রসেস হচ্ছে...',
      'noTextFound': 'ছবিতে কোনো টেক্সট পাওয়া যায়নি',
      'askMeAnything': 'আমাকে যেকোনো প্রশ্ন করুন!',
      'hereToHelp': 'আমি আপনার শেখার সাহায্যে এখানে আছি',
      'voiceGender': 'ভয়েস জেন্ডার',
      'female': 'মহিলা',
      'male': 'পুরুষ',
      'storageLocation': 'স্টোরেজ অবস্থান',
      'thisActionCannotBeUndone': 'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না',
      'adStatus': 'বিজ্ঞাপন অবস্থা',
      'activeRevenue': 'সক্রিয় - রাজস্ব অপ্টিমাইজেশন সক্রিত',
      'version': 'ভার্সন 1.0.0',
      'yourPersonalAi': 'Groq দ্বারা চালিত আপনার ব্যক্তিগত AI শেখার সহায়ক',
      'small': 'ছোট',
      'medium': 'মাঝারি',
      'large': 'বড়',
      'echo': 'ইকো',
      'helloImEcho': 'হ্যালো, আমি ইকো',
      'personalAiAssistant': 'আপনার ব্যক্তিগত AI শেখার সহায়ক',
    },
  };

  String get newChat => _strings[languageCode]?['newChat'] ?? _strings['en']!['newChat']!;
  String get chatHistory => _strings[languageCode]?['chatHistory'] ?? _strings['en']!['chatHistory']!;
  String get settings => _strings[languageCode]?['settings'] ?? _strings['en']!['settings']!;
  String get clearAllChats => _strings[languageCode]?['clearAllChats'] ?? _strings['en']!['clearAllChats']!;
  String get appLanguage => _strings[languageCode]?['appLanguage'] ?? _strings['en']!['appLanguage']!;
  String get voiceLanguage => _strings[languageCode]?['voiceLanguage'] ?? _strings['en']!['voiceLanguage']!;
  String get fontSize => _strings[languageCode]?['fontSize'] ?? _strings['en']!['fontSize']!;
  String get theme => _strings[languageCode]?['theme'] ?? _strings['en']!['theme']!;
  String get about => _strings[languageCode]?['about'] ?? _strings['en']!['about']!;
  String get sendMessage => _strings[languageCode]?['sendMessage'] ?? _strings['en']!['sendMessage']!;
  String get typeMessage => _strings[languageCode]?['typeMessage'] ?? _strings['en']!['typeMessage']!;
  String get thinking => _strings[languageCode]?['thinking'] ?? _strings['en']!['thinking']!;
  String get analyzing => _strings[languageCode]?['analyzing'] ?? _strings['en']!['analyzing']!;
  String get preparingResponse => _strings[languageCode]?['preparingResponse'] ?? _strings['en']!['preparingResponse']!;
  String get noChatsYet => _strings[languageCode]?['noChatsYet'] ?? _strings['en']!['noChatsYet']!;
  String get startFirstConversation => _strings[languageCode]?['startFirstConversation'] ?? _strings['en']!['startFirstConversation']!;
  String get home => _strings[languageCode]?['home'] ?? _strings['en']!['home']!;
  String get projects => _strings[languageCode]?['projects'] ?? _strings['en']!['projects']!;
  String get deleteChat => _strings[languageCode]?['deleteChat'] ?? _strings['en']!['deleteChat']!;
  String get renameChat => _strings[languageCode]?['renameChat'] ?? _strings['en']!['renameChat']!;
  String get cancel => _strings[languageCode]?['cancel'] ?? _strings['en']!['cancel']!;
  String get confirm => _strings[languageCode]?['confirm'] ?? _strings['en']!['confirm']!;
  String get darkMode => _strings[languageCode]?['darkMode'] ?? _strings['en']!['darkMode']!;
  String get lightMode => _strings[languageCode]?['lightMode'] ?? _strings['en']!['lightMode']!;
  String get systemDefault => _strings[languageCode]?['systemDefault'] ?? _strings['en']!['systemDefault']!;
  String get english => _strings[languageCode]?['english'] ?? _strings['en']!['english']!;
  String get hindi => _strings[languageCode]?['hindi'] ?? _strings['en']!['hindi']!;
  String get bengali => _strings[languageCode]?['bengali'] ?? _strings['en']!['bengali']!;
  String get volume => _strings[languageCode]?['volume'] ?? _strings['en']!['volume']!;
  String get pitch => _strings[languageCode]?['pitch'] ?? _strings['en']!['pitch']!;
  String get speechRate => _strings[languageCode]?['speechRate'] ?? _strings['en']!['speechRate']!;
  String get clearConfirmMessage => _strings[languageCode]?['clearConfirmMessage'] ?? _strings['en']!['clearConfirmMessage']!;
  String get renameChatTitle => _strings[languageCode]?['renameChatTitle'] ?? _strings['en']!['renameChatTitle']!;
  String get enterNewName => _strings[languageCode]?['enterNewName'] ?? _strings['en']!['enterNewName']!;
  String get save => _strings[languageCode]?['save'] ?? _strings['en']!['save']!;
  String get clear => _strings[languageCode]?['clear'] ?? _strings['en']!['clear']!;
  String get clearAllData => _strings[languageCode]?['clearAllData'] ?? _strings['en']!['clearAllData']!;
  String get allChatHistoryCleared => _strings[languageCode]?['allChatHistoryCleared'] ?? _strings['en']!['allChatHistoryCleared']!;
  String get processingImage => _strings[languageCode]?['processingImage'] ?? _strings['en']!['processingImage']!;
  String get noTextFound => _strings[languageCode]?['noTextFound'] ?? _strings['en']!['noTextFound']!;
  String get askMeAnything => _strings[languageCode]?['askMeAnything'] ?? _strings['en']!['askMeAnything']!;
  String get hereToHelp => _strings[languageCode]?['hereToHelp'] ?? _strings['en']!['hereToHelp']!;
  String get voiceGender => _strings[languageCode]?['voiceGender'] ?? _strings['en']!['voiceGender']!;
  String get female => _strings[languageCode]?['female'] ?? _strings['en']!['female']!;
  String get male => _strings[languageCode]?['male'] ?? _strings['en']!['male']!;
  String get storageLocation => _strings[languageCode]?['storageLocation'] ?? _strings['en']!['storageLocation']!;
  String get thisActionCannotBeUndone => _strings[languageCode]?['thisActionCannotBeUndone'] ?? _strings['en']!['thisActionCannotBeUndone']!;
  String get adStatus => _strings[languageCode]?['adStatus'] ?? _strings['en']!['adStatus']!;
  String get activeRevenue => _strings[languageCode]?['activeRevenue'] ?? _strings['en']!['activeRevenue']!;
  String get version => _strings[languageCode]?['version'] ?? _strings['en']!['version']!;
  String get yourPersonalAi => _strings[languageCode]?['yourPersonalAi'] ?? _strings['en']!['yourPersonalAi']!;
  String get small => _strings[languageCode]?['small'] ?? _strings['en']!['small']!;
  String get medium => _strings[languageCode]?['medium'] ?? _strings['en']!['medium']!;
  String get large => _strings[languageCode]?['large'] ?? _strings['en']!['large']!;
  String get echo => _strings[languageCode]?['echo'] ?? _strings['en']!['echo']!;
  String get helloImEcho => _strings[languageCode]?['helloImEcho'] ?? _strings['en']!['helloImEcho']!;
  String get personalAiAssistant => _strings[languageCode]?['personalAiAssistant'] ?? _strings['en']!['personalAiAssistant']!;
  
  static const String appName = 'Echo';
  static const String appTagline = 'Your Personal Learning Assistant';
  
  static const List<String> suggestedPrompts = [
    'Explain quantum computing simply',
    'Help me write a poem about nature',
    'What is machine learning?',
    'Teach me about photosynthesis',
  ];
}