//
//  Event.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

public class Event<DataType> {
    public typealias EventHandler = (DataType) -> ()
    
    public var eventHandlers = [Invocable]()
    
    public func addHandler<U: AnyObject>(target: U, handler: @escaping (U) -> EventHandler) -> Disposable {
        let wrapper = EventHandlerWrapper(target: target, handler: handler, event: self)
        eventHandlers.append(wrapper)
        return wrapper
    }
    
    public func raise(data: DataType) {
        for handler in self.eventHandlers {
            handler.invoke(data: data)
        }
    }
}

public class EventHandlerWrapper<T: AnyObject, U>: Invocable, Disposable {
    weak var target: T?
    let handler: (T) -> (U) -> ()
    let event: Event<U>
    
    init(target: T?, handler: @escaping (T) -> (U) -> (), event: Event<U>) {
        self.target = target
        self.handler = handler
        self.event = event
    }
    
    public func invoke(data: Any) {
        if let t = self.target {
            handler(t)(data as! U)
        }
    }
    
    public func dispose() {
        event.eventHandlers = event.eventHandlers.filter { $0 !== self }
    }
}

public protocol Invocable: class {
    func invoke(data: Any)
}

public protocol Disposable {
    func dispose()
}
