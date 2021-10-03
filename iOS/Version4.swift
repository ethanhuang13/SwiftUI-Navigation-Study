import SwiftUI

private extension EnvironmentValues {
  var navigation: Binding<Version4.Navigation> {
    get { self[Version4.NavigationKey.self] }
    set { self[Version4.NavigationKey.self] = newValue }
  }
}

/// Put `Navigation` into custom `EnvironmentValues`, similar to `PresentationMode`
enum Version4 {
  struct NavigationKey: EnvironmentKey {
    static let defaultValue: Binding<Navigation> = .constant(.init())
  }

  struct Navigation {
    var editorViewNoteId: UUID? {
      didSet {
        if editorViewNoteId == nil {
          isPushingDisplayView = false
        }
      }
    }

    var isPushingDisplayView = false

    mutating func reset() {
      editorViewNoteId = nil
      isPushingDisplayView = false
    }
  }

  struct ListView: View {
    // MARK: Internal

    var body: some View {
      NavigationView {
        List {
          ForEach($notes) { note in // Swift 5.5
            NavigationLink(
              tag: note.id.wrappedValue,
              selection: $navigation.editorViewNoteId,
              destination: {
                EditorView(
                  note: note,
                  onDelete: {
                    if let index = notes.firstIndex(of: note.wrappedValue) {
                      notes.remove(at: index)
                    }
                  })
              }, label: {
                Text(note.content.wrappedValue)
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
                  .foregroundColor(.primary)
                  .padding(.vertical, 8)
              })
          }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("List View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button(action: {
              notes.append(.random())
            }, label: {
              Image(systemName: "plus")
            })
          }
          ToolbarItem(placement: .bottomBar) {
            Text("Version 4")
          }
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .environment(\.navigation, $navigation)
    }

    // MARK: Private

    @State private var navigation: Navigation = .init()

    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]
  }

  struct EditorView: View {
    // MARK: Internal

    @Binding var note: Note
    var onDelete: () -> Void

    var body: some View {
      VStack {
        TextEditor(text: $note.content)
          .padding()
      }
      .background(
        NavigationLink(
          isActive: navigation.isPushingDisplayView,
          destination: {
            DisplayView(
              note: $note,
              onDelete: onDelete)
          },
          label: {
            EmptyView()
          })
      )
      .navigationTitle("Editor View")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: {
            navigation.isPushingDisplayView.wrappedValue = true
          }, label: {
            Image(systemName: "eyes")
          })
        }

        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            navigation.wrappedValue.reset()
          }, label: {
            Image(systemName: "arrowshape.turn.up.backward.fill")
          })
        }
        ToolbarItem(placement: .destructiveAction) {
          Button(action: {
            onDelete()
          }, label: {
            Image(systemName: "trash")
              .foregroundColor(.red)
          })
        }
      }
    }

    // MARK: Private

    @Environment(\.navigation) var navigation
  }

  struct DisplayView: View {
    // MARK: Internal

    @Binding var note: Note
    var onDelete: () -> Void

    var body: some View {
      Text(String(note.content))
        .font(.largeTitle)
        .navigationTitle("Display View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              navigation.wrappedValue.reset()
            }, label: {
              Image(systemName: "arrowshape.turn.up.left.2.fill")
            })
          }
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              navigation.isPushingDisplayView.wrappedValue = false
            }, label: {
              Image(systemName: "arrowshape.turn.up.backward.fill")
            })
          }
          ToolbarItem(placement: .destructiveAction) {
            Button(action: {
              onDelete()
            }, label: {
              Image(systemName: "trash")
                .foregroundColor(.red)
            })
          }
        }
    }

    // MARK: Private

    @Environment(\.navigation) var navigation
  }

  struct ListView_Previews: PreviewProvider {
    static var previews: some View {
      ListView()
    }
  }
}
