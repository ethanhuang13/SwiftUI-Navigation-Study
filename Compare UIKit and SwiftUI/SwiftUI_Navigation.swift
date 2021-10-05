import SwiftUI

enum SwiftUI_Navigation {
  struct AView: View {
    @State private var isPushingBView = false

    var body: some View {
      NavigationView {
        VStack {
          Text("This is A")

          NavigationLink(
            isActive: $isPushingBView,
            destination: { BView() },
            label: { Text("Push B") })
        }
      }
    }
  }

  struct BView: View {
    var body: some View {
      Text("This is B")
    }
  }

  struct SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
      AView()
    }
  }
}
