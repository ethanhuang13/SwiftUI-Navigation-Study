import Foundation
import UIKit

enum UIKit_Presentation {
  class AViewController: UIViewController {
    func present() {
      // `A` presents `B`
      present(BViewController(), animated: true, completion: nil)
      // or
      show(BViewController(), sender: nil)
    }
  }

  class BViewController: UIViewController {
    func dismiss() {
      // dismiss self
      dismiss(animated: true, completion: nil)
    }
  }
}
