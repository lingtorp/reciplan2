import SwiftUI

struct DescriptionView: View {
    @Binding var description: String
    var body: some View {
        Form {
            Section {
                TextEditor(text: $description).textFieldStyle(.roundedBorder).disableAutocorrection(true).frame(minHeight: 300)
            }
        }
        .navigationTitle("Description") // FIXME: Localize text ...
    }
}
