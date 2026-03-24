/*
 * graphics.HC
 * Beautiful 2D Hexagonal Rendering for Hexagon Chess Game
 *
 * This file implements a simple and elegant visual design
 * for the hexagon chess game, utilizing hexagonal grids
 * for aesthetic gameplay representation.
 */

#include <graphics.h>

// Function to draw a hexagon
void drawHexagon(int centerX, int centerY, int size) {
    int x[6], y[6];
    for (int i = 0; i < 6; i++) {
        x[i] = centerX + size * cos(M_PI / 3 * i);
        y[i] = centerY + size * sin(M_PI / 3 * i);
    }
    // Draw hexagon
    drawpoly(6, x, y);
}

// Function to render the chessboard
void renderBoard() {
    int hexSize = 40; // Size of the hexagons
    for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
            int offsetX = (col * hexSize * 3/2);
            int offsetY = (row * hexSize * sqrt(3));
            if (col % 2 == 1) {
                offsetY += hexSize * sqrt(3) / 2;
            }
            drawHexagon(offsetX, offsetY, hexSize);
        }
    }
}

// Main function
int main() {
    initgraph();
    renderBoard();
    getch();
    closegraph();
    return 0;
}
