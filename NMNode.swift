//  Created by Nicholas Miller, all rights reserved.

import Foundation

public class NMNode<T> {
    var value: T
    var previous: NMNode?
    var next: NMNode?
    
    public init(value: T) {
        self.value = value
        self.previous = nil
        self.next = nil
    }
}
