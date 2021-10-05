import SwiftUI

private let versionString = "Version 1"

/// Vanilla SwiftUI Navigation
enum Version1 {
  struct ListView: View {
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
            NavigationLink(destination:
              EditorView(note: note, onDelete: {
                if let index = notes.firstIndex(of: note.wrappedValue) {
                  notes.remove(at: index)
                }
              })) {
                Text(note.content.wrappedValue)
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
                  .foregroundColor(.primary)
                  .padding(.vertical, 8)
            }
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
    }
  }

  struct EditorView: View {
    @Binding var note: Note
    var onDelete: () -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var isPushingDisplayView = false

    var body: some View {
      VStack {
        TextEditor(text: $note.content)
          .padding()
      }
      .background(
        NavigationLink(
          isActive: $isPushingDisplayView,
          destination: { DisplayView(note: $note, onDelete: onDelete) },
          label: { EmptyView() })
      )
      .navigationTitle("Editor View")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: {
            isPushingDisplayView = true
          }, label: {
            Image(systemName: "eyes")
          })
        }

        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
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

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
      Text(String(note.content))
        .font(.largeTitle)
        .navigationTitle("Display View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button(action: {}, label: {
              Image(systemName: "arrowshape.turn.up.left.2.fill")
            })
              .disabled(true)
          }
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              // Pop to `NoteView`
              presentationMode.wrappedValue.dismiss()
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
