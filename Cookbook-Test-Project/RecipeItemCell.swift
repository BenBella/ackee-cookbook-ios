//
//  RecipeItemCell.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import UIKit
import SnapKit

class RecipeItemCell: UITableViewCell {

    private let recipeImageView = UIImageView()
    private let recipeTitleLabel = UILabel()
    private let recipeScoreWrapper = UIView()
    private let recipeDurationWrapper = UIView()
    private let recipeDurationIcon = UIImageView()
    private let recipeDurationLabel = UILabel()
    private let separator = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeConstraints()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        makeConstraints()
    }
    
    func makeConstraints() {
        let superview = self.contentView
        
        superview.addSubview(recipeImageView)
        recipeImageView.layer.cornerRadius = 5
        recipeImageView.image = #imageLiteral(resourceName: "img_small")
        recipeImageView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(86)
            make.centerY.equalTo(superview)
            make.top.equalTo(superview.snp.top).offset(15)
            make.bottom.equalTo(superview.snp.bottom).offset(-15)
            make.left.equalTo(superview.snp.left).offset(15)
        }
        
        superview.addSubview(recipeTitleLabel)
        recipeTitleLabel.numberOfLines = 0
        recipeTitleLabel.textColor = UIColor.theme.blue
        recipeTitleLabel.font = UIFont.theme.titleBold
        recipeTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(superview.snp.top).offset(15)
            make.left.equalTo(recipeImageView.snp.right).offset(15)
            make.right.equalTo(superview.snp.right).offset(-15)
        }
        
        superview.addSubview(recipeScoreWrapper)
        recipeScoreWrapper.backgroundColor = UIColor.theme.white
        recipeScoreWrapper.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(recipeTitleLabel.snp.bottom)
            make.left.equalTo(recipeImageView.snp.right).offset(15)
            make.right.equalTo(superview.snp.right).offset(-15)
            make.height.equalTo(22)
        }
        
        superview.addSubview(recipeDurationWrapper)
        recipeDurationWrapper.backgroundColor = UIColor.theme.white
        recipeDurationWrapper.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(recipeScoreWrapper.snp.bottom).offset(4)
            make.left.equalTo(recipeImageView.snp.right).offset(15)
            make.right.equalTo(superview.snp.right).offset(-15)
            make.height.equalTo(22)
            make.bottom.equalTo(recipeImageView.snp.bottom)
        }
        
        recipeDurationWrapper.addSubview(recipeDurationIcon)
        recipeDurationIcon.image = #imageLiteral(resourceName: "ic_time")
        recipeDurationIcon.snp.makeConstraints{ (make) -> Void in
            make.width.height.equalTo(14)
            make.top.equalTo(recipeDurationWrapper.snp.top).offset(4)
            make.left.equalTo(recipeDurationWrapper.snp.left).offset(4)
        }
        
        recipeDurationWrapper.addSubview(recipeDurationLabel)
        recipeDurationLabel.backgroundColor = UIColor.theme.white
        recipeDurationLabel.textColor = UIColor.theme.darkGray
        recipeDurationLabel.font = UIFont.theme.text
        recipeDurationLabel.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(recipeDurationWrapper)
            make.top.equalTo(recipeDurationWrapper.snp.top)
            make.left.equalTo(recipeDurationIcon.snp.right).offset(4)
            make.right.equalTo(recipeDurationWrapper.snp.right)
        }
        
        superview.addSubview(separator)
        separator.backgroundColor = UIColor.theme.lightGray
        separator.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(1)
            make.width.equalTo(superview.snp.width)
            make.bottom.equalTo(superview.snp.bottom)
        }
    }
    
    func updateName(_ name: String) {
        recipeTitleLabel.text = name
    }
    
    func updateDuration(_ duration: Int) {
        recipeDurationLabel.text = duration.createDurationString()
    }
    
    func updateScoreView(_ score: Double) {
        recipeScoreWrapper.subviews.forEach({ $0.removeFromSuperview() })
        var prevIcon: UIImageView?
        let rounded = Int(score.rounded())
        for index in 0...rounded {
            guard index < 5 else {
                break
            }
            let starIcon = UIImageView()
            starIcon.image = #imageLiteral(resourceName: "ic_star")
            recipeScoreWrapper.addSubview(starIcon)
            if prevIcon == nil {
                starIcon.snp.makeConstraints{ (make) -> Void in
                    make.height.width.equalTo(18)
                    make.centerY.equalTo(recipeScoreWrapper.snp.centerY)
                    make.left.equalTo(recipeScoreWrapper.snp.left)
                }
                prevIcon = starIcon
            } else {
                starIcon.snp.makeConstraints{ (make) -> Void in
                    make.height.width.equalTo(18)
                    make.centerY.equalTo(recipeScoreWrapper.snp.centerY)
                    make.left.equalTo(prevIcon!.snp.right)
                }
                prevIcon = starIcon
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
