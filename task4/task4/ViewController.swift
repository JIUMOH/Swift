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
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    var lineWidth : CGFloat = 1.0
    var lineColor : UIColor = UIColor.red
    
    var undoBarButton = UIBarButtonItem()
    var redoBarButton = UIBarButtonItem()
    
    var prevViewStack = [DrawView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBar()
        setupLayout()
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
    
    let yellowButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleColorChange(button: UIButton) {
        lineColor = (button.backgroundColor ?? .black)
    }
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    @objc fileprivate func handleSliderChange() {
        lineWidth = CGFloat(slider.value)
    }
    
    fileprivate func setupLayout() {
        let colorsStackView = UIStackView(arrangedSubviews: [yellowButton, redButton, blueButton])
        colorsStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [
            colorsStackView,
            slider,
            ])
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
    }
    
    @objc func undoButtonTap(){
        prevViewStack.append(view.subviews.last as! DrawView)
        if !(view.subviews[view.subviews.count - 2] is DrawView) { undoBarButton.isEnabled = false }
        prevViewStack[prevViewStack.count - 1].removeFromSuperview()
        redoBarButton.isEnabled = true
    }
    
    @objc func redoButtonTap(){
        guard let lastView = prevViewStack.popLast() else { return }
        view.addSubview(lastView)
        if prevViewStack.count == 0 { redoBarButton.isEnabled = false }
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
            drawView.clipsToBounds = false
            
            drawView.strokeColor = lineColor
            drawView.strokeWidth = lineWidth
            
            drawView.backgroundColor = .clear
            
            drawView.frame = self.view.frame
            
            view.addSubview(drawView)
            
            lineArray.append([CGPoint]())
            
        case .changed:
            let point = gestureRecognizer.location(in: self.view)
            
            print(point)
            
            let lastView = view.subviews.last as! DrawView
            
            guard var lastLine = lineArray.popLast() else { return }
            
            lastLine.append(point)
            lineArray.append(lastLine)
            
            lastView.line = lastLine
            
            lastView.drawView()
            
        case .cancelled, .ended:
            break
            
        case .failed, .possible:
            break
        }
    }
}

