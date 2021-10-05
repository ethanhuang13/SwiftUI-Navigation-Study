import SwiftUI

private let versionString = "Version 7"
private typealias Navigation = Version7.Navigation
private typealias NavigationKey = Version7.NavigationKey

private extension EnvironmentValues {
  var navigation: Binding<Navigation> {
    get { self[NavigationKey.self] }
    set { self[NavigationKey.self] = newValue }
  }
}

/// Put `NavigationLink` back. With `NavigationNode`, `NavigationStack`, and `ScreenView`
/// Reference: https://github.com/johnpatrickmorgan/FlowStacks/
enum Version7 {
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

  indirect enum NavigationNode: View {
    case view(ScreenView,
              nextNode: NavigationNode,
              screens: Binding<[Screen]>,
              index: Int)
    case nothing

    var body: some View {
      screenView
        .background(
          NavigationLink(
            isActive: isActive,
            destination: { pushingScreenView },
            label: { EmptyView() })
        )
    }

    private var isActive: Binding<Bool> {
      switch self {
      case let .view(_, nextNode: .view, screens: screens, index: index):
        let countIfNotActive = index + 1
        return Binding(
          get: {
            screens.wrappedValue.count > countIfNotActive
          },
          set: { isActive in
            guard isActive == false,
                  screens.wrappedValue.count > countIfNotActive else {
              return
            }
            screens.wrappedValue = Array(screens.wrappedValue.prefix(countIfNotActive))
          })
      default:
        return .constant(false)
      }
    }

    @ViewBuilder
    private var screenView: some View {
      if case let .view(view, _, _, _) = self {
        view
      }
    }

    @ViewBuilder
    private var pushingScreenView: some View {
      if case let .view(_, navigationNode, _, _) = self {
        navigationNode
      }
    }
  }

  struct NavigationStack: View {
    @Binding var screens: [Screen]
    @ViewBuilder var buildView: (Screen) -> ScreenView

    var body: some View {
      screens // [.list, .editor, .display]
        .enumerated()
        .reversed() // [.display, .editor, .list]
        .reduce(NavigationNode.nothing) { result, next in
          // [.nothing, .display, .editor, .list]
          NavigationNode.view(
            buildView(next.element),
            nextNode: result,
            screens: $screens,
            index: next.offset)
        }
    }
  }

  struct ScreenView: View {
    let screen: Screen
    @Binding var notes: [Note]

    var body: some View {
      switch screen {
      case .list:
        ListView(notes: $notes)
      case let .editor(noteId):
        if let note = bindingCurrentNote(noteId) {
          EditorView(note: note, onDelete: { deleteNote(noteId) })
        }
      case let .display(noteId):
        if let note = bindingCurrentNote(noteId) {
          DisplayView(note: note, onDelete: { deleteNote(noteId) })
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
      }
    }
  }

  struct ContainerView: View {
    @State private var navigation = Navigation(screens: [.list])
    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]

    var body: some View {
      NavigationView {
        NavigationStack(screens: $navigation.screens) { screen in
          ScreenView(screen: screen, notes: $notes)
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .environment(\.navigation, $navigation)
    }
  }

  struct ListView: View {
    @Binding var notes: [Note]

    @Environment(\.navigation) private var navigation

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
            navigation.wrappedValue.dismiss(toRoot: true)
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
              navigation.wrappedValue.dismiss(toRoot: true)
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
      ContainerView()
    }
  }
}
