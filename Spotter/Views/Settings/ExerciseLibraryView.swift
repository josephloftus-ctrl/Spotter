import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var showingAddExercise = false
    @State private var selectedModality: ExerciseModality?

    private var filteredExercises: [Exercise] {
        var result = exercises

        if let modality = selectedModality {
            result = result.filter { $0.modality == modality }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    private var groupedExercises: [(ExerciseModality, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.modality }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Modality Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            SpotterChip(label: "All", isSelected: selectedModality == nil) {
                                selectedModality = nil
                            }

                            ForEach(ExerciseModality.allCases, id: \.self) { modality in
                                SpotterChip(
                                    label: modality.displayName,
                                    isSelected: selectedModality == modality
                                ) {
                                    selectedModality = modality
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                    }
                    .background(Color.spotterSurface)

                    // Exercise List
                    List {
                        ForEach(groupedExercises, id: \.0) { modality, exercises in
                            Section {
                                ForEach(exercises) { exercise in
                                    exerciseRow(exercise)
                                        .listRowBackground(Color.spotterSurfaceElevated)
                                }
                            } header: {
                                Text(modality.displayName)
                                    .font(.spotterCaptionMedium)
                                    .foregroundStyle(Color.spotterTextSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.spotterTextSecondary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.spotterPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.spotterSurface)
                    .frame(width: 40, height: 40)

                Image(systemName: exercise.modality.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.spotterTextMuted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterText)

                if !exercise.muscleGroups.isEmpty {
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }

            Spacer()

            if exercise.isCustom {
                Text("Custom")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterPrimary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.spotterPrimaryMuted)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, Spacing.xxs)
    }
}

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var modality = ExerciseModality.barbell
    @State private var muscleGroups = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        SpotterCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                SectionHeader("Exercise Details")

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Name")
                                        .font(.spotterCaptionMedium)
                                        .foregroundStyle(Color.spotterTextSecondary)

                                    TextField("e.g., Romanian Deadlift", text: $name)
                                        .font(.spotterBody)
                                        .foregroundStyle(Color.spotterText)
                                        .padding(Spacing.sm)
                                        .background(Color.spotterSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                                        )
                                }

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Type")
                                        .font(.spotterCaptionMedium)
                                        .foregroundStyle(Color.spotterTextSecondary)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: Spacing.sm) {
                                            ForEach(ExerciseModality.allCases, id: \.self) { mod in
                                                SpotterChip(
                                                    label: mod.displayName,
                                                    isSelected: modality == mod
                                                ) {
                                                    modality = mod
                                                }
                                            }
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Muscle Groups")
                                        .font(.spotterCaptionMedium)
                                        .foregroundStyle(Color.spotterTextSecondary)

                                    TextField("e.g., hamstrings, glutes, lower back", text: $muscleGroups)
                                        .font(.spotterBody)
                                        .foregroundStyle(Color.spotterText)
                                        .padding(Spacing.sm)
                                        .background(Color.spotterSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                                        )
                                }

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Notes (Optional)")
                                        .font(.spotterCaptionMedium)
                                        .foregroundStyle(Color.spotterTextSecondary)

                                    TextField("Any additional notes...", text: $notes, axis: .vertical)
                                        .font(.spotterBody)
                                        .foregroundStyle(Color.spotterText)
                                        .padding(Spacing.sm)
                                        .background(Color.spotterSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                                        )
                                        .lineLimit(2...4)
                                }
                            }
                        }

                        SpotterButton("Save Exercise", icon: "checkmark", style: .primary) {
                            saveExercise()
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.spotterTextSecondary)
                    }
                }
            }
        }
    }

    private func saveExercise() {
        let muscles = muscleGroups
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        let exercise = Exercise(
            name: name,
            muscleGroups: muscles,
            modality: modality,
            notes: notes.isEmpty ? nil : notes,
            isCustom: true
        )

        modelContext.insert(exercise)
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    ExerciseLibraryView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
