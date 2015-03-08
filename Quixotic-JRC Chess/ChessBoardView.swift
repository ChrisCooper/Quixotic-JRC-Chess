//
//  ChessBoardView.swift
//  Quixotic-JRC Chess
//
//  Created by Shark on 2015-03-08.
//  Copyright (c) 2015 Quixotic - JRC. All rights reserved.
//

import UIKit

class ChessBoardView: UIView {

    let board_state = BoardState()
    
    // TODO: calculate this instead
    let pieceSize: Int = 38
    
    // Images
    let board: UIImage = UIImage(named: "board")!
    
    // TODO: Replace text drawing with piece images
    let teamColors = [Team.white: UIColor.whiteColor(), Team.black: UIColor.blackColor()]
    var textAttributes: [Team: NSDictionary] = [
        Team.white: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 30)!
        ],
        Team.black: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 30)!
        ]
    ]
    
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        // Draw board
        let boardSize: CGRect = self.bounds
        board.drawInRect(boardSize)
        
        // Draw pieces
        for position in board_state.allPieces() {
            let piece = board_state.piece(position)
            let pieceName: NSString = piece.type.description
            pieceName.drawInRect(pieceRect(position), withAttributes: textAttributes[piece.team])
        }
    }
    
    func pieceRect(position: Position) -> CGRect {
        let pieceSize: Int = 38
        return CGRect(x: (8 + (position.x * pieceSize)), y: (8 + (position.y * pieceSize)), width: pieceSize,height: pieceSize)
    }
}

class BoardState {
    
    // TODO: this should be a class-level property once Swift supports it
    let AllPositions: [Position]
    
    var board_state: [[Piece!]]
    
    // Set up board, and construct the "AllPositions" property
    init() {
        self.board_state = []
        self.AllPositions = []
        
        // Set up an empty board
        for (var row = 0; row < 8; row++) {
            board_state.append([])
            for (var col = 0; col < 8; col++) {
                self.board_state[row].append(nil)
                self.AllPositions.append(Position(y: row, x: col))
            }
        }
        
        // Add pawn rows
        let pawn_rows = [Team.white: 6, Team.black: 1]
        for (team, row) in pawn_rows {
            for (var col = 0; col < 8; col++) {
                board_state[row][col] = Piece(team: team, type: PieceType.Pawn)
            }
        }
        
        // Add back rows
        let back_rows = [Team.white: 7, Team.black: 0]
        for (team, row) in back_rows {
            for (var col = 0; col < 8; col++) {
                board_state[row][col] = Piece(team: team, type: PieceType.BackRow[col])
            }
        }
        
         println(board_state)
    }
    
    func piece(position: Position) -> Piece! {
        return board_state[position.y][position.x]
    }
    
    func allPieces() -> [Position] {
        return AllPositions.filter({p in self.piece(p) != nil})
    }
}

class Piece {
    
    let team: Team
    var type: PieceType
    
    init(team: Team, type: PieceType) {
        self.team = team
        self.type = type
    }
    
}



enum Team: String {
    case white = "white", black = "black"
    var description: String {
        get {
            return self.rawValue
        }
    }
}

// TODO: make this String instead of NSString once piece images are implemented
enum PieceType: NSString {
    case
    Pawn = "Pa",
    Rook = "Ro",
    Knight = "Kn",
    Bishop = "Bi",
    Queen = "Qu",
    King = "Ki"
    
    static let BackRow = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static let BackRowMoves = [
        Pawn: PawnMoves,
        Rook: StraightUnlimited,
        Knight: [],
        Bishop: DiagonalUnlimited,
        Queen: BothUnlimited,
        King: BothShort
    ]
    
    static let DiagonalDeltas = [(1,1), (1,-1), (-1,1), (-1,-1)]
    static let StraightDeltas = [(1,0), (-1,0), (0,1), (0,-1)]
    // TODO: when swift lets you add arrays, just use that here
    static let BothDeltas = [(1,1), (1,-1), (-1,1), (-1,-1),(1,0), (-1,0), (0,1), (0,-1)]
    
    // Build move arrays
    static let PawnMoves = [
        Move(deltaY: 1, deltaX: 0, canCapture: false, scalable: false),
        Move(deltaY: 1, deltaX: 1, canCapture: true, scalable: false),
        Move(deltaY: 1, deltaX: -1, canCapture: true, scalable: false)
    ]
    static let StraightUnlimited = StraightDeltas.map({ (y, x) -> Move in
        Move(deltaY: y, deltaX: x, canCapture: true, scalable: true)
    })
    static let DiagonalUnlimited = DiagonalDeltas.map({ (y, x) -> Move in
        Move(deltaY: y, deltaX: x, canCapture: true, scalable: true)
    })
    static let BothUnlimited = BothDeltas.map({ (y, x) -> Move in
        Move(deltaY: y, deltaX: x, canCapture: true, scalable: true)
    })
    static let BothShort = BothDeltas.map({ (y, x) -> Move in
        Move(deltaY: y, deltaX: x, canCapture: true, scalable: false)
    })
}

struct Move {
    let deltaY: Int
    let deltaX: Int
    let canCapture: Bool
    let scalable: Bool
}

struct Position: Printable, Equatable {
    let y: Int
    let x: Int
    var description: String {
        return "(\(y), \(x))"
    }
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
