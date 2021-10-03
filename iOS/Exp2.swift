//
//  NavState.swift
//  Nav (iOS)
//
//  Created by Ethan Huang on 2021/10/3.
//

import SwiftUI

enum Exp2 {
  struct ListView: View {
    // MARK: Internal
    
    var body: some View {
      NavigationView {
        List {
          ForEach($notes) { note in // Swift 5.5
            NavigationLink(
              destination:
                EditorView(note: note, onDelete: {
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
        .navigationTitle("List View (Exp2)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
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
    }
    
    // MARK: Private
    
    @State private var notes: [Note] = [
      .random(),
      .random(),
      .random(),
      .random()
    ]
    
    @State private var selection: UUID?
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
    
    // MARK: Private
    
    @Environment(\.presentationMode) private var presentationMode
    
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
            Button(action: {}, label: {
              Image(systemName: "arrowshape.turn.up.left.2.fill")
            })
              .disabled(true)
          }
          ToolbarItem(placement: .bottomBar) {
            Button(action: {
              // Pop to `NoteView`
              dismiss()
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
