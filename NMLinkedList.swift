//  Created by Nicholas Miller, all rights reserved.

import Foundation

public class NMLinkedList<T>  {
    private var head: NMNode<T>?
    private var tail: NMNode<T>?
    private var size: size_t
    
    public init() {
        head = nil
        tail = nil
        size = 0
    }
    
    // O(1)
    public func getHead() -> NMNode<T>? {
        return head
    }
    
    // O(1)
    public func addNodeToHead(value: T) {
        let p: NMNode<T>? = NMNode(value: value)
        if head == nil {
            head = p
            tail = p
        }
        else {
            p?.next = head
            head?.previous = p
            head = p
        }
        incrementSize()
    }
    
    // O(1)
    public func removeHead() {
        if head == nil {
            return
        } else {
            let p: NMNode<T>? = head?.next
            p?.previous = nil
            head = nil
            head = p
            decrementSize()
        }
    }
    
    // O(1)
    public func getTail() -> NMNode<T>? {
        return tail
    }
    
    // O(1)
    public func addNodeToTail(value: T) {
        let p: NMNode<T>? = NMNode(value: value)
        if head == nil {
            head = p
            tail = p
        }
        else {
            tail?.next = p
            p?.previous = tail
            tail = p
        }
        incrementSize()
    }
    
    // O(1)
    public func removeTail() {
        if tail == nil {
            return
        } else {
            let p: NMNode<T>? = tail?.previous
            p?.next = nil
            tail = nil
            tail = p
            decrementSize()
        }
    }
    
    // O(1)
    private func incrementSize() {
        size = size + 1
    }
    
    // O(1)
    private func decrementSize() {
        size = (size <= 0) ? 0 : size - 1
    }
    
    // O(1)
    public func getSize() -> size_t {
        return size
    }
    
    public func printForward() {
        var p = head
        
        while p != nil {
            print(p?.value ?? "node doesn't exist")
            p = p?.next
        }
    }
    
    public func printBackward() {
        var p = tail
        
        while p != nil {
            print(p?.value ?? "node doesn't exist")
            p = p?.previous
        }
    }
}
