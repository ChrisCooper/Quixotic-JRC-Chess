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
    let board: UIImage = UIImage(named: "Board")!
    let selectionHighlight: UIImage = UIImage(named: "SelectionHighlight")!
    
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
        
        if (board_state.SelectedPosition != nil) {
            // Draw selection highlight
            selectionHighlight.drawInRect(pieceRect(board_state.SelectedPosition))
            
            // Draw possible moves
            // TODO: Build the list of valid moves intelligently instead of checking everything
            for position in board_state.AllPositions {
                if (board_state.moveIsValid(to: position)) {
                    selectionHighlight.drawInRect(pieceRect(position))
                }
            }
        }
        
        
        // Draw pieces
        for position in board_state.allPieces() {
            let piece = board_state.getPiece(position)
            let pieceName: NSString = piece.type.description
            pieceName.drawInRect(pieceRect(position), withAttributes: textAttributes[piece.team])
        }
    }
    
    func pieceRect(position: Position) -> CGRect {
        let pieceSize: Int = 38
        return CGRect(x: (8 + (position.x * pieceSize)), y: (8 + (position.y * pieceSize)), width: pieceSize,height: pieceSize)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event:UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let touchLocation: CGPoint = touch.locationInView(self)
        
        let squareWidth =  (self.frame.width / 8)
        let squareHeight = (self.frame.height / 8)
        
        let xCoord: Int = Int(touchLocation.x / squareWidth)
        let yCoord: Int = Int(touchLocation.y / squareHeight)
        
        board_state.positionWasTouched(Position(y: yCoord, x: xCoord))
        
        self.setNeedsDisplay()
    }
}

class BoardState {
    
    // TODO: this should be a class-level property once Swift supports it
    let AllPositions: [Position]
    
    var board_state: [[Piece!]]
    
    var SelectedPosition: Position!
    var CurrentTeam = Team.white
    
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
    
    func getPiece(position: Position) -> Piece! {
        return board_state[position.y][position.x]
    }
    
    func allPieces() -> [Position] {
        return AllPositions.filter({p in self.getPiece(p) != nil})
    }
    
    func isFriendly(position: Position) -> Bool {
        let piece = getPiece(position)
        if piece != nil {
            return piece.team == CurrentTeam
        }
        return false
    }
    
    func isEnemy(position: Position) -> Bool {
        let piece = getPiece(position)
        if piece != nil {
            return piece.team != CurrentTeam
        }
        return false
    }
    
    func positionWasTouched(positionTouched: Position) {
        let piece = getPiece(positionTouched)
        
        if isFriendly(positionTouched) {
            SelectedPosition = positionTouched
        } else if (SelectedPosition != nil) {
            let moveSucceeded = tryToMovePiece(to: positionTouched)
            if (!moveSucceeded) {
                SelectedPosition = nil
            }
        }
    }
    
    func tryToMovePiece(to newPosition: Position) -> Bool {
        return false;
    }
    
    func moveIsValid(to newPosition: Position) -> Bool {
        return getPiece(newPosition) == nil;
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
