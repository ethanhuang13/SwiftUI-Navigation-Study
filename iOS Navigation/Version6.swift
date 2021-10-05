import SwiftUI

private let versionString = "Version 6"
private typealias Navigation = Version6.Navigation
private typealias NavigationKey = Version6.NavigationKey

private extension EnvironmentValues {
  var navigation: Binding<Navigation> {
    get { self[NavigationKey.self] }
    set { self[NavigationKey.self] = newValue }
  }
}

/// Refactor `Navigation` and `ListView`
enum Version6 {
  struct NavigationKey: EnvironmentKey {
    static let defaultValue: Binding<Navigation> = .constant(.init(screens: [.list]))
  }

  enum Screen {
    case list, editor(UUID), display(UUID)
  }

  struct Navigation {
    var screens: [Screen]

    mutating func pushEditorView(noteId: UUID) {
      screens.append(.editor(noteId))
    }

    mutating func pushDisplayView(noteId: UUID) {
      screens.append(.display(noteId))
    }

    mutating func dismiss(toRoot: Bool = false) {
      guard screens.count > 1 else {
        return
      }

      if toRoot {
        screens = screens.dropLast(screens.count - 1)
      } else {
        screens.removeLast()
      }
    }
  }

  struct ContainerView: View {
    // MARK: Internal

    var body: some View {
      NavigationView {
        buildCurrentView()
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .environment(\.navigation, $navigation)
    }

    // MARK: Private

    @State private var navigation = Navigation(screens: [.list])
    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]

    @ViewBuilder
    private func buildCurrentView() -> some View {
      if let screen = navigation.screens.last {
        buildView(for: screen)
      }
    }

    @ViewBuilder
    private func buildView(for screen: Screen) -> some View {
      switch screen {
      case .list:
        ListView(notes: $notes)
      case let .editor(noteId):
        if let note = bindingCurrentNote(noteId) {
          EditorView(note: note, onDelete: { deleteNote(noteId) })
        } else {
          Text("Build `EditorView` failed")
        }
      case let .display(noteId):
        if let note = bindingCurrentNote(noteId) {
          DisplayView(note: note, onDelete: { deleteNote(noteId) })
        } else {
          Text("Build `DisplayView` failed")
        }
      }
    }

    private func bindingCurrentNote(_ noteId: UUID) -> Binding<Note>? {
      guard let note = notes.first(where: { $0.id == noteId }) else {
        return nil
      }
      return Binding(
        get: {
          note
        },
        set: { note, _ in
          if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes.replaceSubrange(index ... index, with: [note])
          }
        })
    }

    private func deleteNote(_ noteId: UUID) {
      if let index = notes.firstIndex(where: { $0.id == noteId }) {
        notes.remove(at: index)
        $navigation.wrappedValue.dismiss(toRoot: true)
      }
    }
  }

  struct ListView: View {
    // MARK: Internal

    @Binding var notes: [Note]

    var body: some View {
      ScrollView {
        LazyVStack {
          Divider()
            .padding(.leading)

          ForEach($notes) { note in // Swift 5.5
            HStack {
              Button(action: {
                navigation.wrappedValue.pushEditorView(noteId: note.wrappedValue.id)
              }, label: {
                Text(note.content.wrappedValue)
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
                  .foregroundColor(.primary)
              })

              Spacer()

              Button(action: {
                navigation.wrappedValue.pushDisplayView(noteId: note.wrappedValue.id)
              }, label: {
                Image(systemName: "eyes")
              })

              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()
              .padding(.leading)
          }
        }
      }
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

    // MARK: Private

    @Environment(\.navigation) private var navigation
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
      .navigationTitle("Editor View")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: {
            navigation.wrappedValue.pushDisplayView(noteId: $note.wrappedValue.id)
          }, label: {
            Image(systemName: "eyes")
          })
        }

        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            navigation.wrappedValue.dismiss()
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

    @Environment(\.navigation) private var navigation
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
              navigation.wrappedValue.dismiss(toRoot: true)
            }, label: {
              Image(systemName: "arrowshape.turn.up.left.2.fill")
            })
          }
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              navigation.wrappedValue.dismiss()
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

    @Environment(\.navigation) private var navigation
  }

  struct ListView_Previews: PreviewProvider {
    static var previews: some View {
      ContainerView()
    }
  }
}
