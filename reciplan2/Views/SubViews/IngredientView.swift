import SwiftUI

struct EditIngredientView: View {
    private enum FocusField: Hashable {
      case name, quantity
    }

    @Bindable var measured: MeasuredIngredient
    
    @FocusState private var focusedField: FocusField?
    @State private var measurementType: MeasurementType = .volume
    @State private var measurementSystemSelection: Int = UserDefaults.standard.integer(forKey: "measurementSystem")
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Name").font(.headline)
                    TextField("Water", text: $measured.name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .quantity
                        }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Quantity").font(.headline)
                    TextField("1", value: $measured.measurement.quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .quantity)
                        .submitLabel(.done)
                        .keyboardShortcut(.defaultAction)
                }
            }

            // Measurement type selection
            Section {
                Picker("Measurement", selection: $measured.measurement.unit) {
                    ForEach(MeasurementUnit.sortedFiltered(type: measurementType, system: measurementSystemSelection)) {
                        Text($0.string(abbreviated: false)).tag($0)
                    }

//                    if measurementType == MeasurementType.misc {
//                        ForEach(MeasurementUnit.sortedFiltered(type: measurementType, system: MeasurementSystem.notApplicable.rawValue)) {
//                            Text($0.string(abbreviated: false)).tag($0)
//                        }
//                    } else {
//                    }
                }

                Picker("System", selection: $measurementSystemSelection) {
                    ForEach(MeasurementSystem.allCases.filter({ (system) -> Bool in
                        return system != MeasurementSystem.notApplicable
                    })) { system in
                        Text(verbatim: system.toString()).tag(system.rawValue).id(system.rawValue)
                    }
                }
                
                Picker("Type", selection: $measurementType) {
                    ForEach(MeasurementType.allCases) {
                        Text($0.description).tag($0).id($0.description)
                    }
                }
            }
            
            Section {
                Toggle(isOn: $measured.optional) {
                    Label("Optional", systemImage: "questionmark.circle")
                }
                
                Toggle(isOn: $measured.garnish) {
                    Label("Garnish", systemImage: "camera.macro.circle")
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .font(.body)
        .onAppear {
            focusedField = .name
            // Load view private state from binding
            measurementType = measured.measurement.unit.measurementType
            measurementSystemSelection = measured.measurement.unit.measurementSystem.rawValue
        }
    }
}

struct IngredientView: View {
    @Environment(\.presentationMode) private var presentationMode
    var recipe: Recipe
    
    @State private var measured: MeasuredIngredient = MeasuredIngredient()

    var body: some View {
        EditIngredientView(measured: measured)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    recipe.ingredients.append(measured)
                    self.presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.theme)
                .font(.body)
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}
