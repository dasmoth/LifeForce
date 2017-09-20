//
//  Conway.swift
//  LifeForce
//
//  Created by Thomas Down on 10/09/2017.
//  Copyright © 2017 Thomas Down. All rights reserved.
//

struct Cell : Hashable, Codable {
    let x:Int;
    let y:Int;
    
    var hashValue : Int {
        get {
            return x ^ (y * 17);
        }
    }
}

extension Cell: Equatable {}

func ==(lhs: Cell, rhs: Cell) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y;
}

func neighbours(cell: Cell) -> [Cell] {
    return [
        Cell(x: cell.x - 1, y: cell.y - 1),
        Cell(x: cell.x    , y: cell.y - 1),
        Cell(x: cell.x + 1, y: cell.y - 1),
        Cell(x: cell.x - 1, y: cell.y    ),
        Cell(x: cell.x + 1, y: cell.y    ),
        Cell(x: cell.x - 1, y: cell.y + 1),
        Cell(x: cell.x    , y: cell.y + 1),
        Cell(x: cell.x + 1, y: cell.y + 1)
    ]
}

func frequencies<T,S:Sequence>(items: S) -> [T: Int] where S.Iterator.Element == T {
    var freqs = [T:Int]();
    for item in items {
        if let prevCount = freqs[item] {
            freqs[item] = prevCount + 1;
        } else {
            freqs[item] = 1;
        }
    }
    return freqs;
}

func step(_ oldState: Set<Cell>) -> Set<Cell> {
    let counts = frequencies(items: oldState.flatMap(neighbours));
    
    return Set<Cell>(
        counts.flatMap({(cell, count) -> [Cell] in
            if (count == 3 || (count == 2 && oldState.contains(cell))) {
                return [cell];
            } else {
                return [];
            }
            
        })
    )
}
