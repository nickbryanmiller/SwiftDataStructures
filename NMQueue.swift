//  Created by Nicholas Miller, all rights reserved.

import Foundation

public class NMQueue<T> {
    private var nmLinkedList: NMLinkedList<T>
    
    public init() {
        self.nmLinkedList = NMLinkedList<T>()
    }
    
    // O(1)
    public func isEmpty() -> Bool {
        return (nmLinkedList.getSize() > 0) ? false : true
    }
    
    // O(1)
    public func size() -> size_t {
        return nmLinkedList.getSize()
    }
    
    // O(1)
    public func first() -> NMNode<T>? {
        return nmLinkedList.getHead()
    }
    
    // O(1)
    public func last() -> NMNode<T>? {
        return nmLinkedList.getTail()
    }
    
    // O(1)
    public func push(value: T) {
        nmLinkedList.addNodeToTail(value: value)
    }
    
    // O(1)
    public func pop() {
        nmLinkedList.removeHead()
    }
    
    // O(1)
    public func popAndGet() -> NMNode<T>? {
        let poppedNode: NMNode<T>? = first()
        pop()
        return poppedNode
    }
}
