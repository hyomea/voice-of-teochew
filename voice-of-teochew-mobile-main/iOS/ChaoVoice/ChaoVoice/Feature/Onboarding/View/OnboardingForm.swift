//
//  OnboardingForm.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct OnboardingForm: View {
    @Binding var userProfile: UserProfile
    let background: Image
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                background
                    .resizable()
                    .frame(width: width, height: height)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("form.title")
                        .font(.largeTitle.bold())
                    
                    TextField("form.nickname_placeholder", text: $userProfile.nickName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    HStack {
                        Text("form.age_group")
                        Spacer()
                        Picker("form.age_group", selection: $userProfile.ageGroup) {
                            ForEach(UserProfile.AgeGroup.allCases, id: \.id) { group in
                                Text(LocalizedStringKey(group.rawValue))
                                    .tag(group)
                            }
                        }
                    }
                    Divider()

                    HStack {
                        Text("form.dialect")
                        Spacer()
                        Picker("form.dialect", selection: $userProfile.dialectTag) {
                            ForEach(UserProfile.DialectTag.allCases, id: \.id) { group in
                                Text(LocalizedStringKey(group.rawValue))
                                    .tag(group)
                            }
                        }
                    }
                    Button {
                        userProfile.isCompleted = true
                        userProfile.saveToUserDefaults()
                    } label: {
                        Text("form.start_button")
                            .font(.system(size: 18).bold())
                    }
                    .padding(12)
                    .background(userProfile.ageGroup == .unspecified ? Color.gray : Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(userProfile.ageGroup == .unspecified)
                    
                }
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 48)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

#Preview {
    VStack {
        GeometryReader { geo in
            OnboardingForm(
                userProfile: Binding.constant(UserProfile()),
                background: Image("onboarding-3"),
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}
