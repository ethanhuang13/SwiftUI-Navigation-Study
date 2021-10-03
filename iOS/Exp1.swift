//
//  NavState.swift
//  Nav (iOS)
//
//  Created by Ethan Huang on 2021/10/3.
//

import SwiftUI

enum Exp1 {
  struct Note: Identifiable, Codable, Hashable {
    var id = UUID()
    var content: String

    static func random() -> Note {
      func randomString(length: Int) -> String {
        let emojis = "🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑"
        return String((0 ..< length).map { _ in emojis.randomElement()! })
      }

      return Note(content: Array(repeating: randomString(length: 1), count: 100).joined())
    }
  }

  struct ListView: View {
    @State var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]

    @State var selection: UUID?

    var body: some View {
      NavigationView {
        List {
          ForEach($notes) { note in // Swift 5.5
            NavigationLink(
              destination:
              NoteView(note: note, onDelete: {
                if let index = notes.firstIndex(of: note.wrappedValue) {
                  notes.remove(at: index)
                }
              }),
              tag: note.id.wrappedValue,
              selection: $selection) {
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
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing: Button(action: {
          notes.append(.random())
        }, label: {
          Image(systemName: "plus")
        }))
      }
    }
  }

  struct NoteView: View {
    // MARK: Internal

    @Binding var note: Note
    var onDelete: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode

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
      .navigationTitle("Note View")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }, label: {
            Image(systemName: "list.dash")
          })
        }
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            isPushingDisplayView = true
          }, label: {
            Image(systemName: "eyes")
          })
        }
        ToolbarItem(placement: .bottomBar) {
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

    @State private var isPushingDisplayView = false
  }

  struct DisplayView: View {
    @Binding var note: Note
    var onDelete: () -> Void
    
    // iOS 15 way
    // `DismissAction`: `CallAsFunction`
    @Environment(\.dismiss) var dismiss

    var body: some View {
      Text(String(note.content))
        .font(.largeTitle)
        .navigationTitle("Display View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              // TODO: Pop back to `ListView`
              dismiss()
            }, label: {
              Image(systemName: "list.dash")
            })
          }
          ToolbarItem(placement: .bottomBar) {
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
