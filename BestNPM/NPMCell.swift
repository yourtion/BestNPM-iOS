//
//  NPMCell.swift
//  
//
//  Created by YourtionGuo on 7/31/15.
//
//

import UIKit

class NPMCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var infos: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func drawRect(rect: CGRect) {
        self.icon!.image = self.getIconFrom(self.name.text, size: self.icon!.frame.size.width*2)
        let maskPath = UIBezierPath(roundedRect: self.icon.bounds,
                              byRoundingCorners: .AllCorners,
                                    cornerRadii: CGSize(width: self.icon!.frame.size.width/2, height: self.icon!.frame.width/2))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.icon!.bounds
        maskLayer.path = maskPath.CGPath
        self.icon.layer.mask = maskLayer
    }
    
    func getIconFrom(var str:String!,size:CGFloat) -> UIImage{
        if (str == nil){ str = "*"}
        let label = UILabel(frame: CGRectMake(0, 0, size, size))
        label.font = UIFont.boldSystemFontOfSize(0.6*size)
        label.text = NSString(string:str).substringToIndex(1).uppercaseString as String
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.backgroundColor = UIColor.lightGrayColor()
        UIGraphicsBeginImageContext(label.frame.size);
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }

}
