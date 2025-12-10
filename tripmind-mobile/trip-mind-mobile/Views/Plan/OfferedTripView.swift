// /Users/kalnazar/Desktop/Uni/Trip-Diploma/trip-mind-mobile/trip-mind-mobile/Views/Plan/OfferedTripView.swift
//
//  OfferedTripView.swift
//  trip-mind-mobile
//

import SwiftUI

struct OfferedTripView: View {
    let summary: String
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                    Text("Offered Plan")
                        .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .semibold))

                    Text(summary)
                        .font(.system(size: DesignSystem.FontSize.base.value))
                        .foregroundColor(DesignSystem.foreground)
                        .padding(DesignSystem.spacing2)
                        .background(DesignSystem.card)
                        .cornerRadius(DesignSystem.radiusMedium)

                    Spacer()
                }
                .padding(DesignSystem.spacing4)
            }
            .navigationTitle("Offered Trip")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveOfferedTrip(summary: summary)
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OfferedTripView(summary: "Sample summary of offered trip.", viewModel: ChatViewModel())
}
