//
//  main.swift
//  LinkedList
//
//  Created by Nicholas Miller on 9/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import Foundation

public class Node<T> {
    var value: T
    var next: Node?
    
    public init(value: T) {
        self.value = value
        self.next = nil
    }
}

public class LinkedList<T>  {
    
    private var head: Node<T>?
    private var tail: Node<T>?
    
    public init() {
        head = nil
    }
    
    public func addNodeToTail(value: T) {
        var p: Node<T>?
        
        if head == nil {
            p = Node(value: value)
            head = p
            tail = p
        }
        else {
            p = tail
            p?.next = Node(value: value)
            tail = p?.next
        }
    }
    
    public func printForward() {
        var p = head
        
        while p != nil {
            print(p?.value)
            p = p?.next
        }
    }
    
    public func getHead() -> Node<T>? {
        if let myHead = head {
            return myHead
        }
        else {
            return nil
        }
    }
}




let list = LinkedList<Int>()

list.addNodeToTail(0)
list.addNodeToTail(1)
list.addNodeToTail(2)
list.addNodeToTail(3)

list.printForward()













