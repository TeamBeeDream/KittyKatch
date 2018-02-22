//
//  Event.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

// MARK: - State
public class Event<DataType> {
    public typealias EventHandler = (DataType) -> ()
    private var eventHandlers = [Invocable]()
}

// MARK: - Public methods
extension Event {
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

// MARK: - Private types
extension Event {
    private class EventHandlerWrapper<T: AnyObject, U>: Invocable, Disposable {
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
                self.handler(t)(data as! U)
            }
        }
        
        public func dispose() {
            self.event.eventHandlers = event.eventHandlers.filter { $0 !== self }
        }
    }
}

private protocol Invocable: class {
    func invoke(data: Any)
}

public protocol Disposable {
    func dispose()
}
