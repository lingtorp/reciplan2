import SwiftUI

struct RecipeTagView: View {
    let tag: Tag
    let selected: Bool
    var body: some View {
        Text(tag.name)
            .font(.footnote)
            .textCase(.uppercase)
            .padding(5)
            .foregroundColor(selected ? .white : tag.color)
            .background(selected ? tag.color : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous), style: FillStyle(eoFill: true, antialiased: true))
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(tag.color ?? .gray, lineWidth: 1.5)
            )
            .padding(1) // Padding for overlay line that goes out of clip/content shape
    }
}

// Horizontal list of tags with selection
struct TagsSelectableView: View {
    let tags: [Tag]
    @Binding var selectedTags: Set<Tag>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if !tags.isEmpty {
                    // Clear button
                    Button(role: .destructive) {
                        withAnimation { selectedTags.removeAll() }
                    } label: {
                        if !selectedTags.isEmpty {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red).imageScale(.large)
                        } else {
                            Image(systemName: "xmark.circle").foregroundColor(.gray).imageScale(.large)
                        }
                    }
                    .padding(.leading)
                }
                
                ForEach(tags) { tag in
                    Button {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    } label: {
                        RecipeTagView(tag: tag, selected: selectedTags.contains(tag))
                    }
                    // TODO: Add longpress to select every tag except this one
                }
            }
        }
        .onAppear {
            // NOTE: Remove highlighted tag if it was removed
            for tag in selectedTags {
                if !tags.contains(tag) {
                    selectedTags.remove(tag)
                }
            }
        }
    }
}

// Horizontal list of tags without selection with bindings
struct TagsView: View {
    var recipe: Recipe
    
    var body: some View {
        // Tags
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(recipe.tags) { tag in
                    RecipeTagView(tag: tag, selected: false)
                }
            }
        }
    }
}

// Horizontal list of tags with selection without bindings
struct SelectedTagsView: View {
    let tags: [Tag]

    var body: some View {
        // Tags
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    RecipeTagView(tag: tag, selected: true)
                }
            }
        }
    }
}
