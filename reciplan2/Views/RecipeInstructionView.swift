import SwiftUI

struct EditInstructionView: View {
    @Binding var instruction: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Form {
            TextEditor(text: $instruction).frame(height: 0.4 * UIScreen.main.bounds.height)
        }
        .navigationTitle("Edit Instruction")
    }
}

struct InstructionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var instructions: [String]
    @State var instruction: String = ""
    var body: some View {
        EditInstructionView(instruction: $instruction)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if instruction.isEmpty { return }
                    instructions.append(instruction)
                    self.presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.theme)
                .font(.body)
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

