import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/education_entry.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSource();
});

/// The signed-in user's own profile — used by the dashboard (profile
/// strength nudge) and the job-apply screen (CV/portfolio snapshot).
final myProfileProvider = FutureProvider.autoDispose<Profile?>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Future.value(null);
  return ref.watch(profileRepositoryProvider).getProfile(uid);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

/// In-progress state for the 5-step onboarding wizard. Kept in Riverpod
/// (rather than screen-local setState) so any step can read/mutate it and
/// the submit step can assemble the full [Profile] without prop-drilling.
class OnboardingDraft {
  const OnboardingDraft({
    this.step = 0,
    this.skills = const {},
    this.institutionName = '',
    this.degree = '',
    this.graduationYear = '',
    this.languages = const {},
    this.qualifications = const {},
    this.cvFileName,
    this.cvBytes,
    this.portfolioFileNames = const [],
    this.portfolioBytesList = const [],
  });

  final int step;
  final Set<String> skills;
  final String institutionName;
  final String degree;
  final String graduationYear;
  final Set<String> languages;
  final Set<String> qualifications;
  final String? cvFileName;
  final List<int>? cvBytes;
  final List<String> portfolioFileNames;
  final List<List<int>> portfolioBytesList;

  bool get canContinueFromSkills => skills.isNotEmpty;
  bool get canContinueFromEducation =>
      institutionName.trim().isNotEmpty && degree.trim().isNotEmpty;
  bool get canContinueFromLanguages => languages.isNotEmpty;
  bool get canContinueFromQualifications => qualifications.isNotEmpty;
  bool get canFinish => cvFileName != null;

  OnboardingDraft copyWith({
    int? step,
    Set<String>? skills,
    String? institutionName,
    String? degree,
    String? graduationYear,
    Set<String>? languages,
    Set<String>? qualifications,
    String? cvFileName,
    List<int>? cvBytes,
    List<String>? portfolioFileNames,
    List<List<int>>? portfolioBytesList,
  }) {
    return OnboardingDraft(
      step: step ?? this.step,
      skills: skills ?? this.skills,
      institutionName: institutionName ?? this.institutionName,
      degree: degree ?? this.degree,
      graduationYear: graduationYear ?? this.graduationYear,
      languages: languages ?? this.languages,
      qualifications: qualifications ?? this.qualifications,
      cvFileName: cvFileName ?? this.cvFileName,
      cvBytes: cvBytes ?? this.cvBytes,
      portfolioFileNames: portfolioFileNames ?? this.portfolioFileNames,
      portfolioBytesList: portfolioBytesList ?? this.portfolioBytesList,
    );
  }
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftController, OnboardingDraft>(
      OnboardingDraftController.new,
    );

class OnboardingDraftController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  static const totalSteps = 5;

  void nextStep() {
    if (state.step < totalSteps - 1) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  void toggleSkill(String skill) =>
      state = state.copyWith(skills: _toggled(state.skills, skill));

  void toggleLanguage(String language) =>
      state = state.copyWith(languages: _toggled(state.languages, language));

  void toggleQualification(String qualification) => state = state.copyWith(
    qualifications: _toggled(state.qualifications, qualification),
  );

  void addCustomSkill(String skill) {
    if (skill.trim().isEmpty) return;
    state = state.copyWith(skills: {...state.skills, skill.trim()});
  }

  void setEducationField({
    String? institutionName,
    String? degree,
    String? graduationYear,
  }) {
    state = state.copyWith(
      institutionName: institutionName,
      degree: degree,
      graduationYear: graduationYear,
    );
  }

  void setCvFile(String fileName, List<int> bytes) {
    state = state.copyWith(cvFileName: fileName, cvBytes: bytes);
  }

  void addPortfolioFile(String fileName, List<int> bytes) {
    state = state.copyWith(
      portfolioFileNames: [...state.portfolioFileNames, fileName],
      portfolioBytesList: [...state.portfolioBytesList, bytes],
    );
  }

  Set<String> _toggled(Set<String> set, String value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }
}

final onboardingSubmitControllerProvider =
    AsyncNotifierProvider<OnboardingSubmitController, void>(
      OnboardingSubmitController.new,
    );

class OnboardingSubmitController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit() async {
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) return false;

    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(() async {
      final draft = ref.read(onboardingDraftProvider);
      final repo = ref.read(profileRepositoryProvider);

      String? cvFileId;
      if (draft.cvFileName != null && draft.cvBytes != null) {
        cvFileId = await repo.uploadDocument(
          uid: uid,
          fileName: 'cv_${draft.cvFileName}',
          bytes: draft.cvBytes!,
        );
      }

      final portfolioFileIds = <String>[];
      for (var i = 0; i < draft.portfolioFileNames.length; i++) {
        final url = await repo.uploadDocument(
          uid: uid,
          fileName: 'portfolio_${draft.portfolioFileNames[i]}',
          bytes: draft.portfolioBytesList[i],
        );
        portfolioFileIds.add(url);
      }

      final education = draft.institutionName.trim().isEmpty
          ? const <EducationEntry>[]
          : [
              EducationEntry(
                institutionName: draft.institutionName.trim(),
                degree: draft.degree.trim(),
                graduationYear: draft.graduationYear.trim(),
              ),
            ];

      await repo.saveProfile(
        Profile(
          uid: uid,
          skills: draft.skills.toList(),
          education: education,
          languages: draft.languages.toList(),
          qualifications: draft.qualifications.toList(),
          cvFileId: cvFileId,
          portfolioFileIds: portfolioFileIds,
        ),
      );
      await repo.markOnboardingComplete(uid);
      await ref
          .read(notificationsRemoteDataSourceProvider)
          .create(
            uid: uid,
            title: 'Welcome to SomTalent!',
            body:
                'Your profile is live. Browse recommended jobs to get started.',
            type: 'welcome',
          );
    });
    state = result;
    return !result.hasError;
  }
}
