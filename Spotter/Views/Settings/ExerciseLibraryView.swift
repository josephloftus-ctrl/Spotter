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
            List {
                // Modality Filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            filterChip(nil, label: "All")

                            ForEach(ExerciseModality.allCases, id: \.self) { modality in
                                filterChip(modality, label: modality.displayName)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Exercises
                ForEach(groupedExercises, id: \.0) { modality, exercises in
                    Section(modality.displayName) {
                        ForEach(exercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }

    private func filterChip(_ modality: ExerciseModality?, label: String) -> some View {
        Button {
            selectedModality = modality
            HapticManager.selection()
        } label: {
            Text(label)
                .font(.spotterCaption)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(selectedModality == modality ? Color.spotterPrimaryFallback : Color.spotterSurfaceFallback)
                .foregroundStyle(selectedModality == modality ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack {
            Image(systemName: exercise.modality.icon)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.spotterBody)

                if !exercise.muscleGroups.isEmpty {
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if exercise.isCustom {
                Text("Custom")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
        }
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
            Form {
                TextField("Exercise Name", text: $name)

                Picker("Type", selection: $modality) {
                    ForEach(ExerciseModality.allCases, id: \.self) { modality in
                        Text(modality.displayName).tag(modality)
                    }
                }

                TextField("Muscle Groups (comma separated)", text: $muscleGroups)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty)
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
