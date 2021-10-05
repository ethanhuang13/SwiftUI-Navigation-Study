import SwiftUI

enum SwiftUI_Presentation {
  struct AView: View {
    @State private var isPresentingBView = false

    var body: some View {
      VStack {
        Text("This is A")

        Button(action: {
          isPresentingBView = true
        }, label: {
          Text("Present B")
        })
      }
      .sheet(isPresented: $isPresentingBView) {
        BView()
      }
    }
  }

  struct BView: View {
    @Environment(\.presentationMode) private var presentationMode
    // @Environment(\.dismiss) private var dismiss // iOS 15

    var body: some View {
      Text("This is B")

      Button(action: {
        presentationMode.wrappedValue.dismiss()
        // or
        // dismiss() // iOS 15
      }, label: {
        Text("Dismiss B")
      })
    }
  }

  struct SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
      AView()
    }
  }
}
