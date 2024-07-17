import SwiftUI

struct EditTagView: View {
    @Bindable var tag: Tag
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Name", text: $tag.name).foregroundColor(tag.color)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .layoutPriority(1)
                    
                    // NOTE: Must convert to hexadecimal for the compare to work!
                    ColorPicker(selection: $tag.color, supportsOpacity: false, label: {})
                }
            }
        }
        .navigationTitle("Tag")
    }
}

struct TagView: View {
    @Environment(\.presentationMode) var presentationMode
    var recipe: Recipe
    @State private var tag: Tag = Tag(name: "", color: .black)
    var body: some View {
        EditTagView(tag: tag)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    // Dont add dups
                    if !recipe.tags.contains(tag) {
                        recipe.tags.append(tag)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.theme).font(.body)
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}
