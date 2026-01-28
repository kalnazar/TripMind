//
//  ItineraryPreviewView.swift
//  trip-mind-mobile
//
//  Preview and save generated itinerary
//

import SwiftUI

struct ItineraryPreviewView: View {
    let tripPlan: TripPlan
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.spacing6) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Itinerary Title")
                        .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                        .foregroundColor(DesignSystem.mutedForeground)

                    TextField("", text: $title)
                        .padding()
                        .background(DesignSystem.card)
                        .cornerRadius(DesignSystem.radiusLarge)
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                }
                
                // Description input
//                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
//                    Text("Description (Optional)")
//                        .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
//                        .foregroundColor(DesignSystem.mutedForeground)
//                    
//                    TextField("Brief description of your trip", text: $description, axis: .vertical)
//                        .textFieldStyle(.roundedBorder)
//                        .lineLimit(3...6)
//                }
                
                // Trip summary
                VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                    Text("Trip Summary")
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                        InfoRow(label: "Origin", value: tripPlan.origin)
                        InfoRow(label: "Destination", value: tripPlan.destination)
                        InfoRow(label: "Duration", value: "\(tripPlan.durationDays) days")
                        InfoRow(label: "Group Size", value: tripPlan.groupSize)
                        InfoRow(label: "Budget", value: tripPlan.budget)
                        
                        if !tripPlan.interests.isEmpty {
                            HStack(alignment: .top) {
                                Text("Interests:")
                                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                                    .foregroundColor(DesignSystem.mutedForeground)
                                    .frame(width: 100, alignment: .leading)
                                
                                Text(tripPlan.interests.joined(separator: ", "))
                                    .font(.system(size: DesignSystem.FontSize.sm.value))
                                    .foregroundColor(DesignSystem.foreground)
                            }
                        }
                    }
                }
                .padding(DesignSystem.spacing4)
                .background(DesignSystem.card)
                .cornerRadius(DesignSystem.radiusXLarge)
                
                if !tripPlan.hotels.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                        Text("Hotels")
                            .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                            .padding(.top, DesignSystem.spacing4)

                        ForEach(tripPlan.hotels) { hotel in
                            HotelCardView(hotel: hotel)
                        }
                    }
                    .padding(.top, DesignSystem.spacing2)
                }

                
                if !tripPlan.itinerary.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                        Text("Daily Plan")
                            .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                            .padding(.top, DesignSystem.spacing4)

                        ForEach(tripPlan.itinerary) { day in
                            DayPlanCardView(
                                dayPlan: day,
                                isExpanded: true,
                                onToggle: { /* no-op for preview */ }
                            )
                        }
                    }
                    .padding(.top, DesignSystem.spacing2)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.destructive)
                        .padding(DesignSystem.spacing3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignSystem.muted)
                        .cornerRadius(DesignSystem.radiusMedium)
                }
                
                // Save button
                Button(action: handleSave) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save Itinerary")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.buttonHeightTouch)
                .background(DesignSystem.primaryColor)
                .foregroundColor(DesignSystem.primaryForeground)
                .cornerRadius(DesignSystem.radiusMedium)
                .disabled(isSaving || title.isEmpty)
            }
            .padding(DesignSystem.spacing4)
        }
        .navigationTitle("Save Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your itinerary has been saved successfully!")
        }
        .onAppear {
            if title.isEmpty {
                title = "\(tripPlan.destination) - \(tripPlan.durationDays) days"
            }
        }
    }
    
    private func handleSave() {
        guard !title.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let request = SaveItineraryRequest(
                    title: title,
                    tripId: nil,
                    tripPlan: tripPlan
                )
                
                _ = try await apiClient.saveItinerary(request)
                
                await MainActor.run {
                    showSuccess = true
                    isSaving = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
}
