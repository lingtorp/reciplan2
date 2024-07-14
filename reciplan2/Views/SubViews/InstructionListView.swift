import SwiftUI

struct InstructionListView: View {
    var recipe: Recipe
    @Binding var highlightedInstruction: String?
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(recipe.instructions, id: \.self) { instruction in
                Button {
                    if highlightedInstruction == instruction {
                        highlightedInstruction = nil
                    } else {
                        highlightedInstruction = instruction
                    }
                } label: {
                    VStack(alignment: .leading) {
                        #if os(iOS)
                        GroupBox {
                            Text("\((recipe.instructions.firstIndex(of: instruction) ?? 0) + 1).").bold() +
                            Text(" \(instruction)")
                        }
                        #elseif os(watchOS)
                        Group {
                            Text("\((recipe.instructions.firstIndex(of: instruction) ?? 0) + 1).").bold() +
                            Text(" \(instruction)")
                        }
                        #endif
                    }
                }
                .foregroundColor(highlightedInstruction == instruction || highlightedInstruction == nil ? .primary : .secondary)
            }
        }
    }
}
