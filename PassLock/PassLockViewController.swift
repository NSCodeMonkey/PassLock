//
//  PassLockViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public enum Result<T> {
  case Success(T)
  case Failure
}

public protocol PassLockProtocol: class {
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>)
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>)
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>)
  func passLockController(passLockController: PassLockViewController, didUnlock result : Result<Any?>)
}

// make protocol functions optional
public extension PassLockProtocol {
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {}
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {}
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>) {}
  func passLockController(passLockController: PassLockViewController, didUnlock result : Result<Any?>) {}
}

public class PassLockViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var passwordInputView: PasswordInputView!

  public weak var delegate: PassLockProtocol?

  var config: PassLockConfiguration = PassLockConfiguration()
  var currentPassword: Password?
  var retryCount = 0

  lazy var stateMachine: StateMachine<PassLockState, PassLockEvent, Password> = {
    switch self.config.passLockType {
    case .SetPassword: return self.setPasswordStateMachine()
    case .ChangePassword: return self.changePasswordStateMachine()
    case .RemovePassword: return self.removePasswordStateMachine()
    case .Unlock: return self.unlockStateMachine()
    }
  }()

  public class func instantiateViewController(configration config: PassLockConfiguration = PassLockConfiguration()) -> PassLockViewController {
    let storyboard = UIStoryboard(name: "PassLock", bundle: NSBundle(forClass: PassLockViewController.self))
    let controller = storyboard.instantiateViewControllerWithIdentifier("PassLockViewController") as! PassLockViewController
    controller.config = config
    controller.currentPassword = config.initialPassword
    return controller
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    // setup UI
    passwordInputView.delegate = self
    passwordInputView.becomeFirstResponder()

    titleLabel.text = config.passLockType.title
    descriptionLabel.hidden = true
  }

}

extension PassLockViewController: PasswordInputProtocol {

  public func passwordInputView(passwordInputView: PasswordInputView, inputComplete input: Password) {
    let event = stateMachine.state.nextEvent(x: currentPassword, y: input)
    stateMachine.handleEvent(event, info: input)
  }

}
