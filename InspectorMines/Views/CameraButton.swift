//
//  CameraButton.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 11/28/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import AVFAudio

class CameraButton: UIButton {
    //create a new layer to render the various circles
    var pathLayer:CAShapeLayer!
    let animationDuration = 0.4
    @objc var subscribeButtonAction : (() -> Void)?

    override init(frame: CGRect) {

        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
        self.awakeFromNib()
    }

    //common set up code
    func setup()
    {
        //add a shape layer for the inner shape to be able to animate it
        self.pathLayer = CAShapeLayer()

        //show the right shape for the current state of the control
        self.pathLayer.path = self.currentInnerPath().cgPath

        //don't use a stroke color, which would give a ring around the inner circle
        self.pathLayer.strokeColor = nil

        //set the color for the inner shape
        self.pathLayer.fillColor = UIColor.white.cgColor

        //add the path layer to the control layer so it gets drawn
        self.layer.addSublayer(self.pathLayer)

        //lock the size to match the size of the camera button
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.width,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.height,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))

        //clear the title
        self.setTitle("", for:.normal)

        //add out target for event handling
         self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        // self.addTarget(self, action: #selector(touchDown), for: .touchDown)

    }

    override var isSelected:Bool{
        didSet{
            //change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration;
            morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

            //change the shape according to the current state of the control
            morph.toValue = self.currentInnerPath().cgPath

            //ensure the animation is not reverted once completed
            morph.fillMode = CAMediaTimingFillMode.forwards
            morph.isRemovedOnCompletion = false

            //add the animation
            self.pathLayer.add(morph, forKey:"")
        }
    }

    @objc func subscribeButtonTapped(_ sender: UIButton) {
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        self.subscribeButtonAction?()
        
    }

    @objc func touchUpInside(sender:UIButton)
    {
        subscribeButtonTapped(sender)
        
        //Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration;
        colorChange.toValue = UIColor.white.cgColor

        //make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = CAMediaTimingFillMode.forwards
        colorChange.isRemovedOnCompletion = false

        //indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        //add the animation
        self.pathLayer.add(colorChange, forKey:"darkColor")

        //change the state of the control to update the shape
        self.isSelected = !self.isSelected

    }

    @objc func sendPicture(sender:UIButton, image:UIImage) {
        
    }

    @objc func touchDown(sender:UIButton)
    {
        //when the user touches the button, the inner shape should change transparency
        //create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration;

        //set the value we want to animate to
        morph.toValue = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5).cgColor

        //ensure the animation does not get reverted once completed
        morph.fillMode = CAMediaTimingFillMode.forwards
        morph.isRemovedOnCompletion = false

        morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.pathLayer.add(morph, forKey:"")
    }

    override func draw(_ rect: CGRect) {
        //always draw the outer ring, the inner control is drawn during the animations
        let outerRing = UIBezierPath(ovalIn: CGRect(x:3, y:3, width:60, height:60))
        outerRing.lineWidth = 6
        UIColor.white.setStroke()
        outerRing.stroke()
    }

    func currentInnerPath () -> UIBezierPath
    {
        //choose the correct inner path based on the control state
        var returnPath:UIBezierPath;
        if (self.isSelected)
        {
            returnPath = self.innerSquarePath()
        }
        else
        {
            returnPath = self.innerCirclePath()
        }

        return returnPath
    }

    func innerCirclePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:8, y:8, width:50, height:50), cornerRadius: 25)
    }

    func innerSquarePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:10, y:10, width:46, height:46), cornerRadius: 23)

    }
}
