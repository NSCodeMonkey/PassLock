//
//  PassLockViewController+States.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

enum PassLockState {
  case Input, Confirm, Reconfirm, Done
}

enum PassLockEvent {
  case Valid, Invalid
}

extension PassLockType {
  func nextEvent(x x: Password?, y: Password?, with state: PassLockState) -> PassLockEvent {
    switch (self, state) {
    case (.SetPassword, .Confirm), (.RemovePassword, .Confirm):
      return x == y ? .Valid : .Invalid
    default:
      return .Valid
    }
  }
}

extension PassLockViewController {

  func setPasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Input) { [weak self] state, event in
      switch (state, event) {
      case (.Input, .Valid): return (.Confirm, { _, _, info in
        // input => confirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.Confirm, .Valid): return (.Done, { _, _, _ in
        // confirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, didSetPassLock: .Success(password))
      })
      case (.Confirm, .Invalid): return (.Confirm, { _, _, _ in
        // confirm again
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
          self?.descriptionLabel.text = "密码不匹配, 请再试一次"
          self?.descriptionLabel.hidden = false
        }
      })
      default: return nil
      }
    }
  }

  func changePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Confirm) { [weak self] state, event in
      switch (state, event) {
      case (.Confirm, .Valid): return (.Input, { _, _, _ in
        // confirm => input
        self?.titleLabel.text = "请输入新密码"
        self?.descriptionLabel.hidden = true
      })
      case (.Confirm, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .Failure)
          })
        } else {
          // retry
          return (.Confirm, { _, _, _ in
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
              strongSelf.descriptionLabel.hidden = false
              strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            }
          })
        }
      case (.Input, .Valid): return (.Reconfirm, { _, _, info in
        // input => reconfirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.Reconfirm, .Valid): return (.Done, { _, _, info in
        // reconfirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .Success(password))
      })
      case (.Reconfirm, .Invalid): return (.Reconfirm, { _, _, _ in
        // reconfirm again
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
          self?.descriptionLabel.text = "密码不匹配, 请再试一次"
          self?.descriptionLabel.hidden = false
        }
      })
      default: return nil
      }
    }
  }

  func removePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Confirm) { [weak self] state, event in
      switch (state, event) {
      case (.Confirm, .Valid): return (.Done, {  _, _, _ in
        // confirm => done
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .Success(nil))
      })
      case (.Confirm, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .Failure)
          })
        } else {
          // retry
          return (.Confirm, { _, _, _ in
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
              strongSelf.descriptionLabel.hidden = false
              strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            }
          })
        }
      default: return nil
      }
    }
  }

}
