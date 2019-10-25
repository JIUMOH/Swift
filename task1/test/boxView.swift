//
//  boxView.swift
//  test
//
//  Created by Stanisla on 25/10/2019.
//  Copyright © 2019 Stanisla. All rights reserved.
//

import UIKit

class boxView: UIView {
    
    init (vcon : ViewController) {
        super.init(frame: CGRect(x:0, y:0, width: 100, height: 100))
        vCon = vcon
        mView = vcon.view
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        box = self
        
        mView.addSubview(self)
        
        self.backgroundColor = .red
            
        self.translatesAutoresizingMaskIntoConstraints = false

        widthConstraint = self.widthAnchor.constraint(equalToConstant:type(of: self).initialBoxDimSize)
        heightConstraint = self.heightAnchor.constraint(equalToConstant: type(of: self).initialBoxDimSize)

        centerYConstraint = self.centerYAnchor.constraint(equalTo: mView.centerYAnchor)
        centerXConstraint = self.centerXAnchor.constraint(equalTo: mView.centerXAnchor)

        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerYConstraint, centerXConstraint])

        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0

        setupGestureRecognizers()
    }
    
    private var mView = UIView()
    private var vCon = ViewController()
    private var box = UIView()
    
    private static let initialBoxDimSize : CGFloat = 150.0
    
    private var scale: CGFloat = 1.0 { didSet { updateBoxTransform() } }
    private var rotation: CGFloat = 0.0 { didSet { updateBoxTransform() } }
    
    private var widthConstraint : NSLayoutConstraint!
    private var heightConstraint : NSLayoutConstraint!
    private var centerYConstraint : NSLayoutConstraint!
    private var centerXConstraint : NSLayoutConstraint!
    
    // gesture recognizers

    private static let forceGestureRecognizerThreshold: CGFloat = 3.0
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private let pinchGestureRecognizer = UIPinchGestureRecognizer()
    private let rotateGestureRecognizer = UIRotationGestureRecognizer()
    private let singleTapGestureRecognizer = UITapGestureRecognizer()
    private let doubleTapGestureRecognizer = UITapGestureRecognizer()

    private let buttonDoubleTapGestureRecognizer = UITapGestureRecognizer()

    private var panGestureAnchorPoint: CGPoint?
    private var pinchGestureAnchorScale: CGFloat?
    private var rotateGestureAnchorRotation: CGFloat?
    

}

extension boxView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let simultaneousRecognizers = [panGestureRecognizer, pinchGestureRecognizer, rotateGestureRecognizer]
        return simultaneousRecognizers.contains(gestureRecognizer) &&
               simultaneousRecognizers.contains(otherGestureRecognizer)
    }

}

fileprivate extension boxView {

    private func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(_:)))
        rotateGestureRecognizer.addTarget(self, action: #selector(handleRotateGesture(_:)))

        panGestureRecognizer.maximumNumberOfTouches = 1

        [panGestureRecognizer,
         pinchGestureRecognizer,
         rotateGestureRecognizer
        ].forEach { $0.delegate = self }

        box.addGestureRecognizer(panGestureRecognizer)
        box.addGestureRecognizer(pinchGestureRecognizer)
        box.addGestureRecognizer(rotateGestureRecognizer)
    }

    private func updateBoxTransform() {
        self.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).rotated(by: rotation)
    }

    // MARK: -

    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer === gestureRecognizer else { return }

        switch gestureRecognizer.state {
        case .began:
            panGestureAnchorPoint = gestureRecognizer.location(in: mView)

        case .changed:
            guard let panGestureAnchorPoint = panGestureAnchorPoint else { return }

            let gesturePoint = gestureRecognizer.location(in: mView)

            centerXConstraint.constant += gesturePoint.x - panGestureAnchorPoint.x
            centerYConstraint.constant += gesturePoint.y - panGestureAnchorPoint.y
            self.panGestureAnchorPoint = gesturePoint

        case .cancelled, .ended:
            panGestureAnchorPoint = nil

        case .failed, .possible:
            break
        }
    }

    @objc private func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard pinchGestureRecognizer === gestureRecognizer else { return }

        switch gestureRecognizer.state {
        case .began:
            pinchGestureAnchorScale = gestureRecognizer.scale

        case .changed:
            guard let pinchGestureAnchorScale = pinchGestureAnchorScale else {  return }

            let gestureScale = gestureRecognizer.scale
            scale += gestureScale - pinchGestureAnchorScale
            self.pinchGestureAnchorScale = gestureScale

        case .cancelled, .ended:
            pinchGestureAnchorScale = nil

        case .failed, .possible:
            break
        }
    }

    @objc private func handleRotateGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
        guard rotateGestureRecognizer === gestureRecognizer else { return }

        switch gestureRecognizer.state {
        case .began:
            rotateGestureAnchorRotation = gestureRecognizer.rotation

        case .changed:
            guard let rotateGestureAnchorRotation = rotateGestureAnchorRotation else { return }

            let gestureRotation = gestureRecognizer.rotation
            rotation += gestureRotation - rotateGestureAnchorRotation
            self.rotateGestureAnchorRotation = gestureRotation

        case .cancelled, .ended:
            rotateGestureAnchorRotation = nil

        case .failed, .possible:
            break
        }
    }
}
