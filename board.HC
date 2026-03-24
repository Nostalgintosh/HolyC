// Board and Piece Management for Hexagonal Coordinate System

// Define piece types
const PieceType = {
    EMPTY: 0,
    PLAYER_ONE: 1,
    PLAYER_TWO: 2,
};

// Initialize the board with hexagonal coordinates
class Board {
    constructor(size) {
        this.size = size;
        this.board = this.createBoard();
    }

    createBoard() {
        const board = [];
        for (let q = -this.size; q <= this.size; q++) {
            const row = [];
            for (let r = Math.max(-this.size, -q - this.size); r <= Math.min(this.size, -q + this.size); r++) {
                row.push(PieceType.EMPTY);
            }
            board.push(row);
        }
        return board;
    }

    getPiece(q, r) {
        return this.board[q + this.size][r + this.size];
    }

    setPiece(q, r, pieceType) {
        this.board[q + this.size][r + this.size] = pieceType;
    }
}

const board = new Board(5); // Initialize a board of size 5

// Export the board for external use
module.exports = { Board, PieceType };