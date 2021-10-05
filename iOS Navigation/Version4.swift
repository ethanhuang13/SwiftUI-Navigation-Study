import SwiftUI

private let versionString = "Version 4"
private typealias Navigation = Version4.Navigation
private typealias NavigationKey = Version4.NavigationKey

private extension EnvironmentValues {
  var navigation: Binding<Navigation> {
    get { self[NavigationKey.self] }
    set { self[NavigationKey.self] = newValue }
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
    @State private var navigation = Navigation()
    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]

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
            Text(versionString)
          }
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .environment(\.navigation, $navigation)
    }
  }

  struct EditorView: View {
    @Binding var note: Note
    var onDelete: () -> Void

    @Environment(\.navigation) private var navigation

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
  }

  struct DisplayView: View {
    @Binding var note: Note
    var onDelete: () -> Void

    @Environment(\.navigation) private var navigation

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
  }

  struct ListView_Previews: PreviewProvider {
    static var previews: some View {
      ListView()
    }
  }
}
