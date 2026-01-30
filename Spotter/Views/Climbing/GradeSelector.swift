import SwiftUI

struct GradeSelector: View {
    let gradeSystem: GradeSystem
    @Binding var selectedGrade: ClimbingGrade?

    private var grades: [ClimbingGrade] {
        ClimbingGrade.grades(for: gradeSystem)
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Grade")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(grades, id: \.value) { grade in
                    GradeButton(
                        grade: grade,
                        isSelected: selectedGrade?.value == grade.value
                    ) {
                        withAnimation(SpotterAnimation.quick) {
                            selectedGrade = grade
                        }
                        HapticManager.selection()
                    }
                }
            }
        }
    }
}

struct GradeButton: View {
    let grade: ClimbingGrade
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(grade.displayValue)
                .font(.spotterBodyMedium)
                .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.glass(isSelected ? .regular.tint(.spotterPrimary).interactive() : .clear.interactive()))
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.spotterBackground.ignoresSafeArea()

        VStack(spacing: Spacing.xl) {
            GradeSelector(gradeSystem: .vScale, selectedGrade: .constant(ClimbingGrade(system: .vScale, value: "V3")))

            GradeSelector(gradeSystem: .yds, selectedGrade: .constant(nil))
        }
        .padding()
    }
}
