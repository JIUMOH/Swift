//
//  ViewController.swift
//  task4
//
//  Created by Stanislav on 01.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var lineArray: [[CGPoint]] = [[CGPoint]()]
    var viewArray: [DrawView] = [DrawView()]
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    var maxX : CGFloat = 0
    var maxY : CGFloat = 0
    var minX : CGFloat = 0
    var minY : CGFloat = 0
    
    let lineWidth : CGFloat = 10.0
    
    var undoBarButton = UIBarButtonItem()
    var redoBarButton = UIBarButtonItem()
    
    var prevView = DrawView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBar()
    
        setupGestureRecognizers()
        
//        let drawView = DrawView()
//
//        drawView.backgroundColor = .white
//        drawView.frame = view.frame
//        drawView.layer.borderColor = UIColor.black.cgColor
//        drawView.layer.borderWidth = 2.0
//        view.addSubview(drawView)
    }
    
    private func addNavigationBar(){
        let height: CGFloat = 75
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: UIScreen.main.bounds.width, height: height))
        navigationBar.backgroundColor = UIColor.white
        navigationBar.delegate = self as? UINavigationBarDelegate
        
        let navItem = UINavigationItem()
        undoBarButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoButtonTap))
        redoBarButton = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redoButtonTap))
        redoBarButton.isEnabled = false
        undoBarButton.isEnabled = false
        navItem.leftBarButtonItem = undoBarButton
        navItem.rightBarButtonItem = redoBarButton
        
        navigationBar.items = [navItem]
        
        view.addSubview(navigationBar)
        
        self.view?.frame = CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - height))
    }
    
    @objc func undoButtonTap(){
        prevView = viewArray.popLast()!
        if viewArray.count == 1 { undoBarButton.isEnabled = false }
        prevView.removeFromSuperview()
        redoBarButton.isEnabled = true
    }
    
    @objc func redoButtonTap(){
        view.addSubview(prevView)
        viewArray.append(prevView)
        redoBarButton.isEnabled = false
        undoBarButton.isEnabled = true
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
}

fileprivate extension ViewController {
    private func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer === gestureRecognizer else { return }
        
        switch gestureRecognizer.state {
        case .began:
            
            print("began")
            
            undoBarButton.isEnabled = true
            redoBarButton.isEnabled = false
            
            let drawView = DrawView()
            
            drawView.strokeColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1).cgColor
            
            drawView.backgroundColor = .white
            
            drawView.frame = self.view.frame
            
            //drawView.layer.borderColor = UIColor.black.cgColor
            //drawView.layer.borderWidth = 2.0
            
            maxX = 0
            maxY = 0
            minX = 0
            minY = 0
            
            view.addSubview(drawView)
            
            lineArray.append([CGPoint]())
            viewArray.append(drawView)
            
        case .changed:
            let point = gestureRecognizer.location(in: self.view)
            
            print(point)
            
            if minX == 0 { minX = point.x }
            if minY == 0 { minY = point.y }
            
            if maxX < point.x { maxX = point.x }
            if maxY < point.y { maxY = point.y }
            if minX > point.x { minX = point.x }
            if minY > point.y { minY = point.y }
            
            
            let lastView = viewArray[viewArray.count - 1]
            
            guard var lastLine = lineArray.popLast() else { return }
            
            lastLine.append(point)
            lineArray.append(lastLine)
            
            lastView.line = lastLine
            
            let rect = CGRect(x: minX - lineWidth, y: minY - lineWidth, width: maxX - minX + lineWidth, height: maxY - minY + lineWidth)
            
            lastView.frame = rect
            lastView.bounds = rect
            
            lastView.setNeedsDisplay()
            
        case .cancelled, .ended:
            break
            
        case .failed, .possible:
            break
        }
    }
}

