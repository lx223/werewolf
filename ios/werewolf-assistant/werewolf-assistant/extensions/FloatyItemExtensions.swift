//
//  FloatyItemExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 03/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import Floaty
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: FloatyItem {

    public var tap: Observable<Base> {
        return Observable<Base>.create { observer -> Disposable in
            self.base.handler = { _ in
                observer.onNext(self.base)
            }

            return Disposables.create {}
        }

    }
}
