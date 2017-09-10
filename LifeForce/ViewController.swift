//
//  ViewController.swift
//  LifeForce
//
//  Created by Thomas Down on 10/09/2017.
//  Copyright © 2017 Thomas Down. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var grid: GridView!;
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var statusItem: UIBarButtonItem!;
    
    var running = false {
        didSet {
            pauseButton.isEnabled = running;
            playButton.isEnabled = !running;
        }
    }
    var timer:Timer? = nil
    var frameNumber:Int = 0 {
        didSet {
            statusItem.title = String(format: "Cycle %d", frameNumber);
        }
    }
    
    func makeTimer() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        }
    }
    
    func killTimer() {
        timer?.invalidate()
        timer = nil;
    }
    
    func update() {
        if (running) {
            frameNumber += 1;
            grid.activeCells = step(grid.activeCells);
            grid.setNeedsDisplay();
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { _ in self.makeTimer() });
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil, using: { _ in self.killTimer() });
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func paused(_ sender: Any) {
        running = false;
    }

    @IBAction func started(_ sender: Any) {
        running = true;
    }
    
    @IBAction func cleared(_ sender: Any) {
        running = false;
        frameNumber = 0;
        grid.activeCells = Set<Cell>();
    }
}

