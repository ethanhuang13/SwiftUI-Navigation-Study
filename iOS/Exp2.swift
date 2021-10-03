//
//  NavState.swift
//  Nav (iOS)
//
//  Created by Ethan Huang on 2021/10/3.
//

import SwiftUI

enum Exp2 {
  class Navigation: ObservableObject {
    @Published var editorViewNoteId: UUID?
    @Published var isPushingDisplayView = false

    func reset() {
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
                  navigation: navigation,
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
        .navigationTitle("List View (Exp2)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button(action: {
              notes.append(.random())
            }, label: {
              Image(systemName: "plus")
            })
          }
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var navigation = Navigation()
    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]
  }

  struct EditorView: View {
    @StateObject var navigation: Navigation
    @Binding var note: Note
    var onDelete: () -> Void

    var body: some View {
      VStack {
        TextEditor(text: $note.content)
          .padding()
      }
      .background(
        NavigationLink(
          isActive: $navigation.isPushingDisplayView,
          destination: {
            DisplayView(
              navigation: navigation,
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
            navigation.isPushingDisplayView = true
          }, label: {
            Image(systemName: "eyes")
          })
        }

        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            navigation.reset()
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
    @StateObject var navigation: Navigation
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
              navigation.reset()
            }, label: {
              Image(systemName: "arrowshape.turn.up.left.2.fill")
            })
          }
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              navigation.isPushingDisplayView = false
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
