//
//  ExpertsListView.swift
//  trip-mind-mobile
//
//  Visible experts list
//

import SwiftUI

struct ExpertsListView: View {
    @StateObject private var viewModel = ExpertsListViewModel()
    @State private var selectedExpert: ExpertPublic?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.experts.isEmpty {
                    VStack(spacing: DesignSystem.spacing4) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 56))
                            .foregroundColor(DesignSystem.mutedForeground)
                        
                        Text("No Experts Yet")
                            .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text("Check back soon for local guides.")
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.spacing4) {
                            ForEach(viewModel.experts) { expert in
                                ExpertCardView(expert: expert)
                                    .onTapGesture {
                                        selectedExpert = expert
                                    }
                            }
                        }
                        .padding(DesignSystem.spacing4)
                    }
                }
            }
            .navigationTitle("Experts")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadExperts()
            }
            .task {
                await viewModel.loadExperts()
            }
            .sheet(item: $selectedExpert) { expert in
                ExpertDetailView(expert: expert)
            }
        }
    }
}

private struct ExpertCardView: View {
    let expert: ExpertPublic
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            HStack(spacing: DesignSystem.spacing3) {
                avatarView
                VStack(alignment: .leading, spacing: 4) {
                    Text(expert.name)
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                    if let location = expert.location, !location.isEmpty {
                        Text(location)
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                }
                Spacer()
            }
            
            if let bio = expert.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                    .lineLimit(3)
            }
            
            HStack(spacing: DesignSystem.spacing2) {
                if let languages = expert.languages, !languages.isEmpty {
                    chip(text: languages)
                }
                if let experience = expert.experienceYears {
                    chip(text: "\(experience) yrs")
                }
                if let price = expert.pricePerHour {
                    chip(text: priceText(price))
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.muted)
                .frame(width: 52, height: 52)
            
            if let urlString = expert.avatarUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        initialsView
                    case .empty:
                        ProgressView()
                    @unknown default:
                        initialsView
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
    }
    
    private var initialsView: some View {
        Text(initials(from: expert.name))
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(DesignSystem.mutedForeground)
    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").map { String($0.prefix(1)) }
        return parts.prefix(2).joined().uppercased()
    }
    
    private func chip(text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.FontSize.xs.value, weight: .semibold))
            .foregroundColor(DesignSystem.mutedForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(DesignSystem.muted)
            .clipShape(Capsule())
    }
    
    private func priceText(_ price: Double) -> String {
        let formatted = String(format: "%.0f", price)
        return "$\(formatted)/hr"
    }
}

private struct ExpertDetailView: View {
    let expert: ExpertPublic
    @Environment(\.dismiss) private var dismiss
    @State private var isBookingPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                    HStack(spacing: DesignSystem.spacing3) {
                        ExpertCardView(expert: expert)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                        detailRow(title: "Location", value: expert.location)
                        detailRow(title: "Languages", value: expert.languages)
                        detailRow(title: "Experience", value: expert.experienceYears.map { "\($0) years" })
                        detailRow(title: "Price per hour", value: expert.pricePerHour.map { "$\(String(format: "%.0f", $0))" })
                        detailRow(title: "Time zone", value: expert.timeZone)
                        detailRow(title: "Country", value: expert.countryCode)
                    }
                    .padding(DesignSystem.spacing4)
                    .background(DesignSystem.card)
                    .cornerRadius(DesignSystem.radiusXLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                            .stroke(DesignSystem.border, lineWidth: 1)
                    )
                    
                    Button(action: { isBookingPresented = true }) {
                        Text("Request Booking")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: DesignSystem.buttonHeightTouch)
                    .background(DesignSystem.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(DesignSystem.radiusMedium)
                }
                .padding(DesignSystem.spacing4)
            }
            .navigationTitle("Expert Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(DesignSystem.primaryColor)
                }
            }
            .sheet(isPresented: $isBookingPresented) {
                ExpertBookingSheetView(expert: expert)
            }
        }
    }
    
    private func detailRow(title: String, value: String?) -> some View {
        HStack {
            Text(title)
                .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                .foregroundColor(DesignSystem.foreground)
            Spacer()
            Text(value ?? "—")
                .font(.system(size: DesignSystem.FontSize.sm.value))
                .foregroundColor(DesignSystem.mutedForeground)
        }
    }
}

private struct ExpertBookingSheetView: View {
    let expert: ExpertPublic
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = "08:00"
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    private let apiClient = APIClient.shared
    private let timeSlots = ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                Text("Pick a time with \(expert.name)")
                    .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                
                if let tz = expert.timeZone, !tz.isEmpty {
                    Text("Times are shown in \(tz)")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
                
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                Picker("Time", selection: $selectedTimeSlot) {
                    ForEach(timeSlots, id: \.self) { slot in
                        Text(slot).tag(slot)
                    }
                }
                .pickerStyle(.segmented)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.destructive)
                }
                
                if let successMessage {
                    Text(successMessage)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.primaryColor)
                }
                
                Button(action: submitBooking) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Confirm Booking")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.buttonHeightTouch)
                .background(DesignSystem.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(DesignSystem.radiusMedium)
                .disabled(isSubmitting)
                
                Spacer()
            }
            .padding(DesignSystem.spacing4)
            .navigationTitle("Book Expert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(DesignSystem.primaryColor)
                }
            }
        }
    }
    
    private func submitBooking() {
        guard let expertId = expert.id as Int? else { return }
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        
        let tz = expert.timeZone.flatMap { TimeZone(identifier: $0) }
        let dateString = formatDate(selectedDate, timeZone: tz)
        
        Task {
            do {
                _ = try await apiClient.createExpertBooking(
                    expertId: expertId,
                    date: dateString,
                    time: selectedTimeSlot
                )
                successMessage = "Booking sent. You'll see it in your history."
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
    
    private func formatDate(_ date: Date, timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    ExpertsListView()
}
