import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../data/db/database.dart';
import 'streak_service.dart';

/// A single rotating prompt from assets/quest_ideas.json — see that file for
/// the full idea bank. Deliberately just a title + human-judgment prompt;
/// the app never picks the contact, the user does.
class SideQuestPrompt {
  const SideQuestPrompt({
    required this.id,
    required this.direction,
    required this.title,
    required this.prompt,
  });

  final String id;
  final String direction;
  final String title;
  final String prompt;

  factory SideQuestPrompt.fromJson(Map<String, dynamic> json) => SideQuestPrompt(
        id: json['id'] as String,
        direction: json['direction'] as String,
        title: json['title'] as String,
        prompt: json['prompt'] as String,
      );
}

/// Generates one rotating side quest per day (§ gamification brainstorm).
/// Kept entirely separate from QuestEngine/Quests — no pool, no k-threshold,
/// no streak semantics, so it can never collide with the daily quest's
/// single-active-row invariant.
class SideQuestEngine {
  SideQuestEngine(this.db);

  final AppDatabase db;

  static List<SideQuestPrompt>? _cachedPrompts;

  static Future<List<SideQuestPrompt>> loadPrompts() async {
    final cached = _cachedPrompts;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/quest_ideas.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final prompts = (decoded['prompts'] as List)
        .map((p) => SideQuestPrompt.fromJson(p as Map<String, dynamic>))
        .toList();
    _cachedPrompts = prompts;
    return prompts;
  }

  /// How many recent days' prompts to avoid repeating.
  static const _noRepeatWindow = 7;

  /// Returns (or creates) today's side quest.
  ///
  /// Called independently from both the hub (prefetch) and SideQuestScreen
  /// (self-sufficient direct entry), so — like QuestEngine.generateForCurrentPeriod
  /// before it — this needs a transaction: two concurrent callers could each see
  /// "no row for today" and both try to insert, tripping the dayKey unique
  /// constraint on the second insert.
  Future<SideQuest> generateForToday({DateTime? now}) {
    return db.transaction(() => _generateForToday(now: now));
  }

  Future<SideQuest> _generateForToday({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final today = StreakService.dayKey(n);

    final existing = await (db.select(db.sideQuests)
          ..where((s) => s.dayKey.equals(today)))
        .getSingleOrNull();
    if (existing != null) return existing;

    final prompts = await loadPrompts();
    final recent = await (db.select(db.sideQuests)
          ..orderBy([(s) => OrderingTerm.desc(s.dayKey)])
          ..limit(_noRepeatWindow))
        .get();
    final recentIds = recent.map((s) => s.promptId).toSet();

    var candidates = prompts.where((p) => !recentIds.contains(p.id)).toList();
    if (candidates.isEmpty) candidates = prompts;
    final chosen = candidates[Random().nextInt(candidates.length)];

    final id = await db.into(db.sideQuests).insert(SideQuestsCompanion.insert(
          dayKey: today,
          promptId: chosen.id,
          createdAt: n.toUtc().millisecondsSinceEpoch,
        ));
    return (db.select(db.sideQuests)..where((s) => s.id.equals(id))).getSingle();
  }

  /// Rerolls today's side quest to a different prompt, on demand — resets
  /// contactId/completedAt since it's now a different quest. Always allowed,
  /// even if today's quest was already completed.
  Future<SideQuest> regenerate(int sideQuestId, {DateTime? now}) {
    return db.transaction(() => _regenerate(sideQuestId, now: now));
  }

  Future<SideQuest> _regenerate(int sideQuestId, {DateTime? now}) async {
    final prompts = await loadPrompts();
    final recent = await (db.select(db.sideQuests)
          ..orderBy([(s) => OrderingTerm.desc(s.dayKey)])
          ..limit(_noRepeatWindow))
        .get();
    // The row being rerolled is always the most recent, so its current
    // promptId is already excluded — no special-casing needed.
    final recentIds = recent.map((s) => s.promptId).toSet();

    var candidates = prompts.where((p) => !recentIds.contains(p.id)).toList();
    if (candidates.isEmpty) candidates = prompts;
    final chosen = candidates[Random().nextInt(candidates.length)];

    await (db.update(db.sideQuests)..where((s) => s.id.equals(sideQuestId)))
        .write(SideQuestsCompanion(
      promptId: Value(chosen.id),
      contactId: const Value(null),
      completedAt: const Value(null),
    ));
    return (db.select(db.sideQuests)..where((s) => s.id.equals(sideQuestId)))
        .getSingle();
  }
}
