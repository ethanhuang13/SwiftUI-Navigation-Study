import SwiftUI

private let versionString = "Version 5"
private typealias Navigation = Version5.Navigation
private typealias NavigationKey = Version5.NavigationKey

private extension EnvironmentValues {
  var navigation: Binding<Navigation> {
    get { self[NavigationKey.self] }
    set { self[NavigationKey.self] = newValue }
  }
}

/// Refactor `Navigation` and `ListView`
enum Version5 {
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

    mutating func dismiss(toRoot: Bool = false) {
      if toRoot {
        editorViewNoteId = nil
        isPushingDisplayView = false
        return
      }

      guard editorViewNoteId != nil else {
        // already in root
        return
      }

      if isPushingDisplayView {
        isPushingDisplayView = false
      } else {
        editorViewNoteId = nil
      }
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
        ScrollView {
          LazyVStack {
            Divider()
              .padding(.leading)

            ForEach($notes) { note in // Swift 5.5
              HStack {
                Button(action: {
                  navigation.editorViewNoteId = note.wrappedValue.id
                }, label: {
                  Text(note.content.wrappedValue)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                })

                Spacer()

                Button(action: {
                  // TODO: Push to `DisplayView`
                }, label: {
                  Image(systemName: "eyes")
                })
                  .disabled(true)

                Image(systemName: "chevron.right")
                  .foregroundColor(.secondary)
              }
              .padding(.horizontal)
              .padding(.vertical, 8)

              Divider()
                .padding(.leading)

              // Hidden `NavigationLink` technique
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
                  EmptyView()
                })
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
