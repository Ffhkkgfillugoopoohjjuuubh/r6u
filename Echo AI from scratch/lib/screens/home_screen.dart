import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/session_drawer.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    if (chatState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (chatState.sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Tutor'),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        drawer: SessionDrawer(
          sessions: chatState.sessions,
          currentSession: chatState.currentSession,
          onSessionSelected: (session) {
            ref.read(chatProvider.notifier).selectSession(session);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
          onSessionDeleted: (id) {
            ref.read(chatProvider.notifier).deleteSession(id);
          },
          onSessionCreated: (name) {
            ref.read(chatProvider.notifier).createSession(name);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: Color(0xFF2196F3),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to AI Tutor!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal learning assistant',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(chatProvider.notifier).createSession('New Chat');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Start Learning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentSession = chatState.currentSession;
    if (currentSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: SessionDrawer(
        sessions: chatState.sessions,
        currentSession: chatState.currentSession,
        onSessionSelected: (session) {
          ref.read(chatProvider.notifier).selectSession(session);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        onSessionDeleted: (id) {
          ref.read(chatProvider.notifier).deleteSession(id);
        },
        onSessionCreated: (name) {
          ref.read(chatProvider.notifier).createSession(name);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(chatProvider.notifier).createSession('New Chat');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}