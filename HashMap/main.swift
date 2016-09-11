//
//  main.swift
//  HashMapTest
//
//  Created by Nicholas Miller on 9/9/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import Foundation

// This is just a node class with a key and value
// I included the option if you want to have a linkedNode Bin
// However it is faster to iterate through an array than through pointers
public class HashEntry<T> {
    private var key: String
    private var value: T
    private var next: HashEntry?
    
    // This is our constructor and how we are going to make a new node for that particular bucket
    public init(key: String, value: T) {
        self.key = key
        self.value = value
        self.next = nil
    }
    public func getKey() -> String {
        return key;
    }
    public func getValue() -> T {
        return value
    }
    public func setValue(value: T) {
        self.value = value;
    }
    public func getNext() -> HashEntry<T>? {
        if let nextNode = next {
            return nextNode;
        }
        else {
            return nil
        }
    }
    public func setNext(next: HashEntry<T>) {
        self.next = next;
    }
};

// Can store a default of 128 elements (2^7 = 8 bits to use);
//let DEFAULT_TABLE_SIZE = 128;


// This is a basic implementation of a hashmap with chaining (a linked list at each array index bucket)
public class HashMap<T> {
    var threshold: Float
    var maxSize: Int
    var tableSize: Int
    var amount: Int
    
    // our array of lists
    var table: [HashEntry<T>?]
    
    public init(size: Int) {
        // 0.75 is recommended for max memory efficiency and time efficiency
        threshold = 0.75;
        maxSize = 100;
        tableSize = size;
        amount = 0;
        table = [HashEntry<T>?](count: tableSize, repeatedValue: nil)
    }
    
    // If we want a dynamic table
    // If we every reach 128 entries we make a new table double the original size and copy the old table over
//    public func resize() {
//        tableSize *= 2;
//        maxSize = Int(Float(tableSize) * threshold);
//        
//        let oldTable: [LinkedHashEntry<T>?] = table
//        table = [LinkedHashEntry<T>?](count: tableSize, repeatedValue: nil)
//        
//        size = 0;
//        
//        for ele in oldTable {
//            if ele != nil {
//                var entry = ele
//                while entry != nil {
//                    if let myEntry = entry {
//                        set(myEntry.getKey(), value: myEntry.getValue())
//                    }
//                    entry = entry?.getNext()
//                }
//            }
//        }
//    }
    
    // This method turns a string into a number so that we can do modulo tablesize to get it into a bucket
    // Swift does not work with ascii, it works with unicode I believe
    public func hashMe(key: String) -> Int {
        return key.hash;
    }
    
    public func containsKey(key: String) -> Int {
        var count = 0
        
        for ele in table {
            if ele?.getKey() == key {
                return count
                
            }
            count = count + 1
        }
        
        return -1
    }
    
    // This sets the maximum size so we can check when we start reaching capacity
    public func setThreshold(threshold: Float) {
        self.threshold = threshold;
        maxSize = Int(Float(tableSize) * threshold);
    }
    
    private func getWithLinks(key: String) -> T? {
        // Modular tablesize is used to get the index because it is an even number and not many collisions occur
        // It might be useful to find the nearest prime around tablesize instead
        let hash: Int = (hashMe(key) % tableSize);
        if table[hash] == nil {
            return nil;
        }
            // If the position is not nil we travel the linked list looking for the same key
        else {
            var entry = table[hash]
            while (entry != nil && entry?.getKey() != key) {
                entry = entry?.getNext()
            }
            if entry == nil {
                return nil;
            }
            else {
                return entry?.getValue()
            }
        }
    }
    
    // Returns the value associated with a key
    public func get(key: String) -> T? {
        // Modular tablesize is used to get the index because it is an even number and not many collisions occur
        // It might be useful to find the nearest prime around tablesize instead
        var hash: Int = (hashMe(key) % tableSize);
        
        if table[hash] == nil {
            return nil;
        }
        // If the position is not nil we linear probe for the key
        // Added a boolean array to make sure we don't duplicate
        // boolean array sacrifices a little space but makes it faster
        else {
            var boolArray = [Bool](count: tableSize, repeatedValue: false)
            while (table[hash] != nil && table[hash]?.getKey() != key && !boolArray[hash]) {
                boolArray[hash] = true
                hash = hash + 1
                if hash >= tableSize {
                    hash = 0
                }
            }
            // If it is nil then we probed for it and it never existed
            if table[hash] == nil {
                return nil;
            }
            else if table[hash]?.getKey() == key {
                return table[hash]?.getValue()
            }
            else {
                return nil
            }
        }
    }
    
    private func doPutWithLinks(key: String, value: T) -> Bool {
        let hash = (hashMe(key) % tableSize);
        
        if amount >= tableSize {
            return false
        }
        // NOTE: This is for a linked hash node
        // If the index is nil we make a new node in that bucket with the key/value pair
        if table[hash] == nil {
            table[hash] = HashEntry<T>(key: key, value: value);
            amount = amount + 1;
        }
        // Else we search the bucket to make sure it does not exist before adding it
        else {
            var entry = table[hash]
            while (entry?.getNext() != nil && entry?.getKey() != key) {
                entry = entry?.getNext()
            }
            if let nextEntry = entry?.getNext() {
                if (nextEntry.getKey() == key) {
                    nextEntry.setValue(value)
                }
            }
            else {
                entry?.setNext(HashEntry<T>(key: key, value: value))
                amount = amount + 1;
            }
        }
        
        return true
        
        // Only for dynamic table
        // If our size ever reaches the max size we double the table and copy the data over.
        //if (amount >= maxSize) {
        //  resize();
        //}
    }
    
    private func doPut(key: String, value: T) throws -> Bool {
        var hash = (hashMe(key) % tableSize);
        
        // NOTE: This is for a non-linked hash node and linear probing
        if table[hash] == nil {
            table[hash] = HashEntry<T>(key: key, value: value);
            amount = amount + 1;
            return true
        }
        
        // This is for a static table - we have to linear probe for a nil bin
        // boolean array sacrifices a little space but makes it faster
        var boolArray = [Bool](count: tableSize, repeatedValue: false)
        while (table[hash] != nil && table[hash]?.getKey() != key && !boolArray[hash]) {
            boolArray[hash] = true
            hash = hash + 1
            if hash >= tableSize {
                hash = 0
            }
        }
        
        // It exists already so we change it
        if table[hash]?.getKey() == key {
            table[hash]?.setValue(value)
            return true
        }
        // We check to see if we have the table full and it contains the key
        else if amount >= tableSize {
            return false
        }
        // We found an empty bin
        else if table[hash] == nil {
            table[hash] = HashEntry<T>(key: key, value: value);
            amount = amount + 1;
            return true
        }
        // Any other bad scenario
        else {
            print("maybe? Key: \(key) value: \(value)")
            print(table[hash]?.getKey())
            return false
        }
        
        // Only for dynamic table
        // If our size ever reaches the max size we double the table and copy the data over.
        //if (amount >= maxSize) {
        //  resize();
        //}
        
    }
    
    // This method sets a value for a particular key
    public func set(key: String, value: T) -> Bool {
        var result = false
        do {
            // Attempt to check success
            result = try doPut(key, value: value)
        } catch {
            // If an error occurs for any reason also return false
            result = false
        }
        
        // print(result)
        return result
    }
    
    private func doDelete(key: String) throws -> Bool {
        var hash: Int = (hashMe(key) % tableSize);
        
        if table[hash] == nil {
            return false;
        }
            // If the position is not nil we linear probe for the key
            // could add a boolean array to make sure we don't duplicate
        else {
            var boolArray = [Bool](count: tableSize, repeatedValue: false)
            while (table[hash] != nil && table[hash]?.getKey() != key && !boolArray[hash]) {
                boolArray[hash] = true
                hash = hash + 1
                if hash >= tableSize {
                    hash = 0
                }
            }
            // If it is nil then we probed for it and it never existed
            if table[hash] == nil {
                return false;
            }
            else if table[hash]?.getKey() == key {
                table[hash] = nil
                amount = amount - 1
                return true
            }
            else {
                return false
            }
        }
    }
    
    public func delete(key: String) -> Bool {
        var result = false
        do {
            // Attempt to check success
            result = try doDelete(key)
        } catch {
            // If an error occurs for any reason also return false
            result = false
        }
        
        // print(result)
        return result
    }
    
    public func load() -> Float {
        var loadFactor: Float = 0.0
        loadFactor = (Float(amount) / Float(tableSize))
        return loadFactor
    }
};


/************************************************************
 Below are all the test cases and where to run the operations
 ************************************************************/


// let hashmap = HashMap<Int>(size: 8)
// Test generic put and make sure it doesn't add another element if full ✅
//hashmap.set("a", value: 0)
//hashmap.set("b", value: 1)
//hashmap.set("c", value: 2)
//hashmap.set("d", value: 3)
//hashmap.set("e", value: 4)
//hashmap.set("f", value: 5)
//hashmap.set("g", value: 6)
//hashmap.set("h", value: 7)
//hashmap.set("h", value: 8)

// Test collision where value should change ✅
//hashmap.set("a", value: 0)
//hashmap.set("a", value: 1)
//hashmap.set("a", value: 2)

// Test another collision where value should change but later on ✅
//hashmap.set("a", value: 3)
//hashmap.set("b", value: 4)
//hashmap.set("c", value: 5)
//hashmap.set("a", value: 6)
//hashmap.set("b", value: 7)
//hashmap.set("c", value: 8)

// Test to make sure we can put after the table is full if the key exists ✅
//let hashmap = HashMap<Int>(size: 1)
//hashmap.set("a", value: 0)
//hashmap.set("a", value: 1)
//hashmap.set("a", value: 2)

// NOTE: UNICODE works but not for keys ✅
// Swift does not work with ascii, it works with unicode I believe
// This means that if I tweak my above code then I can get it to check for emojis as keys
// If the hashmap is of type String then the below works because it is unicode without tweaking
// hashmap.set("happy", value: "😀")

// Methods to print out element hash values and the entire table to confirm linear probing
//print("Hash values:", terminator: "\n")
//for ele in hashmap.table {
//    if let element = ele {
//        print("\(element.key) pos: \(element.key.hash % hashmap.tableSize) value: \(element.value)")
//    }
//}
//print("\ntable:", terminator: " ")
//for ele in hashmap.table {
//    if let element = ele {
//        print("\(element.value)", terminator: " ")
//    }
//    else {
//        print("nil", terminator: " ")
//    }
//}

//// Retrieving with the keys
// Test simple grab
//hashmap.set("a", value: 0)
//hashmap.set("a", value: 1)

// Checks if we look for an element that does not exist
//let hashmap = HashMap<Int>(size: 1)
//hashmap.set("a", value: 0)
//print(hashmap.get("q"))

// NOTE: Retrieving was tested with all the above test cases as well

//// Makes sure that we only print if it is not nil
//print("\n")
//if let value = hashmap.get("a") {
//    print(value)
//}

//// Check the delete method
//let hashmap = HashMap<Int>(size: 8)
//hashmap.set("a", value: 0)
//print(hashmap.get("a"))
//print(hashmap.delete("A"))
//print(hashmap.delete("a"))
//print(hashmap.get("a"))

//// Check load factor
//let hashmap = HashMap<Int>(size: 2)
//hashmap.set("a", value: 0)
//print(hashmap.load())

// Big Test with all the stuffs
//let hashmap = HashMap<Int>(size: 8)
//hashmap.set("a", value: 0)
//hashmap.set("b", value: 1)
//hashmap.set("c", value: 2)
//hashmap.set("d", value: 3)
//hashmap.set("e", value: 4)
//hashmap.set("f", value: 5)
//hashmap.set("g", value: 6)
//hashmap.set("h", value: 7)
//hashmap.set("a", value: 100)
//hashmap.set("i", value: 8)
//hashmap.set("b", value: 101)
//print(hashmap.load())
//hashmap.delete("c")
//print(hashmap.load())
//hashmap.delete("d")
//print(hashmap.load())
//hashmap.set("j", value: 33)
//hashmap.set("k", value: 55)
//print(hashmap.load())
//
//print("Hash values:", terminator: "\n")
//for ele in hashmap.table {
//    if let element = ele {
//        print("\(element.key) pos: \(element.key.hash % hashmap.tableSize) value: \(element.value)")
//    }
//}
//print("\ntable:", terminator: " ")
//for ele in hashmap.table {
//    if let element = ele {
//        print("\(element.value)", terminator: " ")
//    }
//    else {
//        print("nil", terminator: " ")
//    }
//}
//
//print()
//print(hashmap.load())



/************************************************************
 Below is where the user can interact with the hashmap
 ************************************************************/

var boolOut = false

public func doMenu() {
    print("Type 'set' to set an object")
    print("Type 'get' to get an object")
    print("Type 'delete' to delete an object")
    print("Type 'load' to see the load of the HashMap")
    print("Type 'bool' to toggle the boolean outputs of set and delete")
    print("Type 'print' to print the HashMap")
    print("Type 'keys' to print the keys in the HashMap")
    print("Type 'quit' to end the program")
    print("Type 'help' for this menu to be printed again")
}

// Allow the user to play with the hashmap
print("Welcome to the Swift HashMap")
print("the hashmap works with any type :)")
print("The default type of HashMap for this interaction is a String")
print("You can change the type by code in the instantiation below to whichever you prefer")
doMenu()
print()
print("To start, what size HashMap do you want")
var mapSize = 0;
var response = readLine(stripNewline: true)
if let goodResponse = response {
    if let theirSize = Int(goodResponse) {
        mapSize = theirSize
    }
    else {
        print("Not a number")
    }
}
else {
    print("weird input")
}

let hashmap = HashMap<String>(size: mapSize)

public func doSet() {
    var key = ""
    var value = ""
    print("Enter the Key")
    var response = readLine(stripNewline: true)
    if let goodResponse = response {
        key = goodResponse
        
        print("Enter the value")
        response = readLine(stripNewline: true)
        if let goodResponse = response {
            value = goodResponse
            
            let success = hashmap.set(key, value: value)
            if boolOut {
                if success {
                    print("Success")
                }
                else {
                    print("Fail")
                }
            }
        }
        else {
            print("weird value input")
        }
    }
    else {
        print("weird key input")
    }
}
public func doGet() {
    var key = ""
    var value: String?
    print("Enter the Key")
    let response = readLine(stripNewline: true)
    if let goodResponse = response {
        key = goodResponse
        
        value = hashmap.get(key)
        if let goodValue = value {
            print(goodValue)
        }
    }
    else {
        print("weird key input")
    }
}
public func doDelete() {
    var key = ""
    print("Enter the Key")
    let response = readLine(stripNewline: true)
    if let goodResponse = response {
        key = goodResponse
        
        let success = hashmap.delete(key)
        if boolOut {
            if success {
                print("Success")
            }
            else {
                print("Fail")
            }
        }
    }
    else {
        print("weird key input")
    }

}
public func doLoad() {
    print(hashmap.load())
}
public func doBool() {
    boolOut = !boolOut
    
    if boolOut {
        print("now printing success or failure")
    }
    else {
        print("now hiding success or failure")
    }
}
public func doPrint() {
    for ele in hashmap.table {
        if let element = ele {
            print("\(element.value)", terminator: " ")
        }
        else {
            print("nil", terminator: " ")
        }
    }
    print("")
}
public func doKeys() {
    for ele in hashmap.table {
        if let element = ele {
            print("\(element.getKey())", terminator: " ")
        }
    }
    print("")
}

print("I made the HashMap of size \(mapSize)")
print("Have fun")
print("--------")

response = readLine(stripNewline: true)
while response != "quit" {
    if let goodResponse = response {
        if goodResponse.lowercaseString.containsString("set") { doSet() }
        else if goodResponse.lowercaseString.containsString("get") { doGet() }
        else if goodResponse.lowercaseString.containsString("delete") { doDelete() }
        else if goodResponse.lowercaseString.containsString("load") { doLoad() }
        else if goodResponse.lowercaseString.containsString("bool") { doBool() }
        else if goodResponse.lowercaseString.containsString("print") { doPrint() }
        else if goodResponse.lowercaseString.containsString("keys") { doKeys() }
        else if goodResponse.lowercaseString.containsString("help") { doMenu() }
        else if goodResponse.lowercaseString.containsString("quit") { exit(0) }
        else { print("Unrecognized Command") }
        
        response = readLine(stripNewline: true)
    }
    else {
        print("weird input")
    }
}







