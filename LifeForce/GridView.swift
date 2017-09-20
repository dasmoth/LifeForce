//
//  GridView.swift
//  LifeForce
//
//  Created by Thomas Down on 10/09/2017.
//  Copyright © 2017 Thomas Down. All rights reserved.
//

import UIKit
import AudioToolbox

func clamp(_ minVal: CGFloat, _ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return min(maxVal, max(minVal, x));
}

class GridView: UIView {
    let pixelsPerCell:CGFloat = 4;
    var rows:Int = 0;
    var cols:Int = 0;
    
    let minScale = 1.0,
        maxScale = 8.0,
        scaleChangePerTouchingFrame = 0.12,
        scaleChangePerReleasedFrame = -0.5;
    
    var touching = false;
    var primed = false;
    var touchPoint:CGPoint?;
    var zoomOrigin: CGPoint?;
    var xfrmedTouchPoint:CGPoint? {
        get {
            if let tp = touchPoint {
                return tp.applying(xfrm.inverted());
            } else {
                return nil;
            }
        }
    }
    var scale = 1.0;
    var xfrm = CGAffineTransform(scaleX: 1.0, y: 1.0);
    var timer:Timer? = nil;
    
    var activeCells = Set<Cell>([Cell(x: 40, y: 60), Cell(x: 40, y: 61), Cell(x: 40, y: 62), Cell(x: 41, y: 60), Cell(x: 39, y: 61)]) {
        didSet {
            setNeedsDisplay();
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func enableTimer() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        }
    }
    
    func killTimer() {
        timer?.invalidate()
        timer = nil;
    }
    
    @objc func update() {
        var newScale = scale;
        if (touching) {
            newScale = newScale + scaleChangePerTouchingFrame;
        } else {
            newScale = newScale + scaleChangePerReleasedFrame;
        }
        newScale = max(minScale, min(maxScale, newScale));
        
        if (newScale != scale) {
            scale = newScale;
            zoomOrigin = xfrmedTouchPoint;
        } else if (touching) {
            if let rtp = touchPoint {
                if let origin = zoomOrigin {
                    var displaceX:CGFloat = 0, displaceY:CGFloat = 0;
                    
                    let bounds = self.bounds;
                    let relX = (rtp.x - bounds.minX) / bounds.width,
                    relY = (rtp.y - bounds.minY) / bounds.height;
                    
                    if (relX < 0.3) {
                        displaceX = -1;
                    } else if (relX > 0.7) {
                        displaceX = 1;
                    }
                    
                    if (relY < 0.3) {
                        displaceY = -1;
                    } else if (relY > 0.7) {
                        displaceY = 1;
                    }
                    
                    zoomOrigin = CGPoint(x: clamp(0, origin.x + displaceX, bounds.width), y: clamp(0, origin.y + displaceY, bounds.height));
                }
            }
        }
        
        if let tp = zoomOrigin {
            let newXfrm = CGAffineTransform(translationX: tp.x, y: tp.y)
                .scaledBy(x: CGFloat(scale), y: CGFloat(scale))
                .translatedBy(x: -tp.x, y: -tp.y);
            
            if (newXfrm != xfrm) {
                xfrm = newXfrm;
                setNeedsDisplay();
            }
        }
        
        if (!touching && scale == 1.0) {
            killTimer();
        }
    }

    override func layoutSubviews() {
        rows = Int(ceil(self.bounds.height / pixelsPerCell));
        cols = Int(ceil(self.bounds.width / pixelsPerCell));
        super.layoutSubviews();
    }
    
    override func draw(_ frame: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState();
        ctx?.concatenate(xfrm);
        
        let h = self.bounds.height;
        let w = self.bounds.width;
        
        var gridColor:UIColor = UIColor.gray;
        if (scale < 2) {
            gridColor = UIColor(white: CGFloat(1.0 - (0.25 * scale)), alpha: 1.0);
        }
        
        let grid:UIBezierPath = UIBezierPath()
        grid.lineWidth = CGFloat(0.5 / scale);
        
        for row in 1...rows {
            grid.move(to: CGPoint(x: 0, y: CGFloat(row) * pixelsPerCell));
            grid.addLine(to: CGPoint(x: w, y: CGFloat(row) * pixelsPerCell));
        }
        for col in 1...cols {
            grid.move(to: CGPoint(x: CGFloat(col) * pixelsPerCell, y: 0));
            grid.addLine(to: CGPoint(x: CGFloat(col) * pixelsPerCell, y: h));
        }
        gridColor.set()
        grid.stroke();
        
        let cells:UIBezierPath = UIBezierPath();
        for cell in activeCells {
            cells.append(cellRect(cell));
        }
        UIColor.black.set()
        cells.fill();
        
        if (touching) {
            if let tp = xfrmedTouchPoint {
                let touchCell = pointToCell(tp);
                UIColor.red.set();
                cellRect(touchCell).stroke();
            }
        }
        
        ctx?.restoreGState();
    }
    
    func pointToCell(_ point: CGPoint) -> Cell {
        return Cell(x: Int(point.x / pixelsPerCell), y: Int(point.y / pixelsPerCell));
    }
    
    func cellRect(_ cell: Cell) -> UIBezierPath {
        return UIBezierPath(
            rect: CGRect(
                x: CGFloat(cell.x) * pixelsPerCell,
                y: CGFloat(cell.y) * pixelsPerCell,
                width: pixelsPerCell,
                height: pixelsPerCell
            )
        );
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touching = true;
            touchPoint = touch.location(in: self);
        }
        enableTimer();
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: self);
            if (touch.force < 3 && !primed) {
                primed = true;
            } else if (touch.force > 5 && primed) {
                AudioServicesPlaySystemSound(1520);
                primed = false;
                
                if let tp = xfrmedTouchPoint {
                    let cell = Cell(x: Int(tp.x / pixelsPerCell), y: Int(tp.y / pixelsPerCell))
                    if (activeCells.contains(cell)) {
                        activeCells.remove(cell);
                    } else {
                        activeCells.insert(cell);
                    }
                }
            }
            
            setNeedsDisplay();
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false;
        setNeedsDisplay();
    }
}
