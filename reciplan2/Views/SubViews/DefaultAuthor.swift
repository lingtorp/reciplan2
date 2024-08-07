import SwiftUI

struct DefaultAuthorView: View {
    @Binding var defaultRecipeAuthor: String
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person").foregroundColor(.theme)
                    TextField("Author", text: $defaultRecipeAuthor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                                    
                    Button {
                        withAnimation { defaultRecipeAuthor = "" }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundColor(.secondary).opacity(defaultRecipeAuthor == "" ? 0.0 : 1.0)
                    Spacer()
                }
            }
            
            Section {
                Button {
                    defaultRecipeAuthor = UIDevice.current.name
                } label: {
                    Label("Reset to '\(UIDevice.current.name)'", systemImage: "minus.circle").foregroundColor(.red)
                }
            }
        }
        .font(.body)
        .allowsTightening(false)
        .listStyle(.insetGrouped)
        .navigationTitle("Default author")
    }
}
