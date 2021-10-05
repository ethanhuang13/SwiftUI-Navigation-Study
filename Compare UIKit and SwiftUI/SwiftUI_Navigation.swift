import SwiftUI

enum SwiftUI_Navigation {
  struct AView: View {
    @State private var isPushingBView = false

    var body: some View {
      NavigationView {
        VStack {
          NavigationLink(
            isActive: $isPushingBView,
            destination: { BView() },
            label: { Text("Push B") })
        }
        .navigationBarTitle("This is A", displayMode: .inline)
      }
    }
  }

  struct BView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
      Button(action: {
        presentationMode.wrappedValue.dismiss()
      }, label: {
        Text("Pop")
      })
        .navigationBarTitle("This is B", displayMode: .inline)
    }
  }

  struct SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
      AView()
    }
  }
}
