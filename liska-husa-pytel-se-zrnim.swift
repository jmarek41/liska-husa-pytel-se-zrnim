#!/usr/bin/swift

//
//  liska-husa-pytel-se-zrnim.swift
//  
//
//  Created by Jakub Marek on 30/06/2019.
//
//  Jde o jednu z oblíbených hádánek Lewise Carolla.
//  Hříčka se točí kolem lišky, husy a pytle zrní.
//  Vše spočívá v tom, dostat je bezpečně na druhý konec řeky.
//  ==========================================================
//  Pravidla této úlohy jsou:
//
//  Musíte dostat lišku, husu a zrní bezpečně na druhý břeh řeky
//  V jednu chvíli můžete mít s sebou na člunu pouze jednu položku
//  Liška nesmí zůstat sama na břehu s husou, (protože tento stav by pro husu neměl dlouhého trvání)
//  Husa nesmí zůstat na břehu sama se zrním, (protože by to pro změnu nedopadlo úplně dobře pro zrní)
//

// MARK: Extensions

extension CaseIterable where Self: RawRepresentable {
    static var allValues: [RawValue] {
        return allCases.map { $0.rawValue }
    }
}

// MARK: Task

typealias CargoStore = [String]

enum Cargo: String, CaseIterable {
    case fox = ":liska"
    case goose = ":husa"
    case grain = ":zrni"
}
enum Direction { // Moving direction
    case forward, backwards // Forward = me from starting shore to other shore
}

// Constants
let illegalCargo1 = [Cargo.fox.rawValue, Cargo.goose.rawValue] // Fox eats goose
let illegalCargo2 = [Cargo.goose.rawValue, Cargo.grain.rawValue] // Goose eats grain

let me = ":ja"
let boatItem = ":clun"

let startingShore = Cargo.allValues + [me]
let boat = [boatItem]
let otherShore: CargoStore = []

// Task environment
var environment = [startingShore, boat, otherShore]
print("\(environment) // počáteční stav")

var boatState = Direction.forward
func move(index: Int) -> Int { // Returns next index for current boat state
    var newIndex = boatState == .forward ? index + 1 : index - 1
    if newIndex >= environment.count || newIndex < 0 { // New index out of bounds => ...
        boatState = boatState == .forward ? .backwards : .forward // ... change direction ...
        newIndex = boatState == .forward ? 1 : environment.count - 2 // ... and fix index
    }
    return newIndex
}

var myPosition = 0
func moveMyself() { // Move myself through environment
    environment[myPosition].removeAll(where: { $0 == me })
    myPosition = move(index: myPosition)
    environment[myPosition].append(me)
}

func isValid(cargoStore: CargoStore) -> Bool { // Check if input cargo store is valid
    return Set(cargoStore) != Set(illegalCargo1) && Set(cargoStore) != Set(illegalCargo2)
}

var cargoStoreIndex = 0
func moveCargo() { // Move cargo through environment
    var cargoItemToMove = ""
    let cargoStore = environment[cargoStoreIndex].filter { $0 != me } // Don't count me as a cargo
    if cargoStoreIndex == environment.count - 1 { // Other shore - try to keep cargo here ...
        if !isValid(cargoStore: cargoStore) { // ... if cargo store is not valid, switch new cargo for the oldest item in this cargo store
            var temporaryCargoStore = cargoStore
            cargoItemToMove = temporaryCargoStore.removeFirst()
            environment[cargoStoreIndex] = temporaryCargoStore
        }
    } else { // All positions except for other shore - move cargo
        for cargoItem in cargoStore {
            guard cargoItem != boatItem else {
                continue // Don't move boat item
            }
            let temporaryCargoStore = cargoStore.filter { $0 != cargoItem } // Try to remove actual cargo item from actual cargo store ...
            if isValid(cargoStore: temporaryCargoStore) { // ... if actual cargo store is valid ...
                environment[cargoStoreIndex] = temporaryCargoStore // ... confirm cargo removal from actual cargo store
                cargoItemToMove = cargoItem
                break
            }
        }
    }

    // Move cargo to next cargo store
    cargoStoreIndex = move(index: cargoStoreIndex)
    if !cargoItemToMove.isEmpty {
        environment[cargoStoreIndex].append(cargoItemToMove)
    }
}

// MARK: Execution

print("...")
var iteration = 1
while environment.last?.count != startingShore.count {
    moveCargo()
    moveMyself()

    print("\(iteration): \(environment)")
    iteration += 1
}
print("...")
print("\(environment) // koncový stav")
