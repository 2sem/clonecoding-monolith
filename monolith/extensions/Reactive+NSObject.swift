//
//  Reactive+NSObject.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: NSObject {
    public func observe<Element: KVORepresentable>(_ type: Element.Type, keyPath keypath: ReferenceWritableKeyPath<Base, Element>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<Element?> {
        return self.observe(Element.KVOType.self, NSExpression(forKeyPath: keypath).keyPath, options: options, retainSelf: retainSelf)
            .map{ $0 == nil ? nil : Element.init(KVOValue: $0!) }
    }
}
