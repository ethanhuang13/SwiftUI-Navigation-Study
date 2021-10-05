import Foundation
import UIKit

enum UIKit_Navigation {
  class AViewController: UIViewController {
    func push() {
      // `A` push to `B`
      navigationController?.pushViewController(BViewController(), animated: true)
      // or
      navigationController?.show(BViewController(), sender: nil)
    }
  }

  class BViewController: UIViewController {
    func pop() {
      // pop self
      navigationController?.popViewController(animated: true)
      // pop to root
      navigationController?.popToRootViewController(animated: true)
    }
  }
}
